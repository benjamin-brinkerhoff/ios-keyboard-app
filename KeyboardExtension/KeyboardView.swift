//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Main Gboard-style Keyboard UI container integrating Toolbar, One-Handed Mode,
//  Dedicated Number Row, Tool Drawers, and Symbol Popups.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        ZStack {
            // Keyboard Background
            viewModel.currentTheme.backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Gboard Top Action & Prediction Toolbar
                ToolbarView(viewModel: viewModel)

                Divider()
                    .background(Color.black.opacity(0.1))

                // Active Tool Drawer Overlay (Clipboard, Text Edit, Emoji, Themes)
                if viewModel.activeTool != .none {
                    toolDrawer
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Main Keyboard Layout with One-Handed Mode Support
                    HStack(spacing: 0) {
                        // Left Rail for One-Handed Mode (docked to Right)
                        if viewModel.oneHandedState == .right {
                            OneHandedRailView(viewModel: viewModel, isLeftSide: true)
                        }

                        // Main Key Rows Column
                        VStack(spacing: 6) {
                            // Dedicated Number Row (Toggleable, just like in Gboard)
                            if viewModel.showNumberRow && viewModel.currentLayer == .letters {
                                HStack(spacing: 4) {
                                    ForEach(KeyboardLayout.dedicatedNumberRow().keys) { key in
                                        KeyButtonView(viewModel: viewModel, key: key)
                                    }
                                }
                                .padding(.horizontal, 3)
                                .padding(.top, 2)
                            }

                            // Layer Rows
                            ForEach(currentRows) { row in
                                HStack(spacing: 4) {
                                    ForEach(row.keys) { key in
                                        KeyButtonView(viewModel: viewModel, key: key)
                                            .frame(maxWidth: keyWidth(for: key))
                                    }
                                }
                                .padding(.horizontal, 3)
                            }

                            // Bottom Controls Row
                            bottomControlsRow
                                .padding(.horizontal, 3)
                                .padding(.bottom, 3)
                        }
                        .frame(maxWidth: .infinity)

                        // Right Rail for One-Handed Mode (docked to Left)
                        if viewModel.oneHandedState == .left {
                            OneHandedRailView(viewModel: viewModel, isLeftSide: false)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            // Long-press alternate symbols floating popup
            if let activeKey = viewModel.activePopupKey {
                KeyPopupView(
                    key: activeKey,
                    selectedIndex: viewModel.selectedAlternateIndex,
                    anchorFrame: viewModel.popupGlobalFrame
                )
            }
        }
        .frame(height: 290)
    }

    @ViewBuilder
    private var toolDrawer: some View {
        switch viewModel.activeTool {
        case .clipboard:
            ClipboardBarView(viewModel: viewModel, clipboardManager: viewModel.clipboardManager)
        case .textEditing:
            TextEditingPadView(viewModel: viewModel)
        case .emoji:
            EmojiKeyboardView(viewModel: viewModel)
        case .themes:
            ThemePickerView(viewModel: viewModel)
        case .none:
            EmptyView()
        }
    }

    private var currentRows: [KeyboardRow] {
        switch viewModel.currentLayer {
        case .letters:
            return KeyboardLayout.letterRows(shiftState: viewModel.shiftState)
        case .numbers:
            return KeyboardLayout.numberRows()
        case .symbols:
            return KeyboardLayout.symbolRows()
        }
    }

    private func keyWidth(for key: KeyItem) -> CGFloat? {
        if key.widthRatio == 1.0 {
            return .infinity
        }
        return 42.0 * key.widthRatio
    }

    private var bottomControlsRow: some View {
        HStack(spacing: 4) {
            // Layer switcher: ?123 or ABC
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "layer_switch",
                    label: viewModel.currentLayer == .letters ? "?123" : "ABC",
                    action: .switchLayer(viewModel.currentLayer == .letters ? .numbers : .letters),
                    widthRatio: 1.3,
                    keyType: .modifier
                )
            )

            // Emoji / Symbol key
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "emoji_btn",
                    label: "face.smiling",
                    action: .emoji,
                    widthRatio: 1.0,
                    keyType: .modifier
                )
            )

            // Globe key if multiple keyboards enabled
            if viewModel.needsInputModeSwitchKey {
                KeyButtonView(
                    viewModel: viewModel,
                    key: KeyItem(
                        id: "globe",
                        label: "globe",
                        action: .globe,
                        widthRatio: 1.0,
                        keyType: .modifier
                    )
                )
            }

            // Spacebar with Gboard cursor trackpad
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "space",
                    label: "space",
                    action: .space,
                    keyType: .standard
                )
            )

            // Period key with quick alternate symbols
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    label: ".",
                    action: .character("."),
                    alternates: [",", "?", "!", ":", ";", "-"],
                    widthRatio: 1.0,
                    keyType: .standard
                )
            )

            // Return Key
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "return",
                    label: "return",
                    action: .returnKey,
                    widthRatio: 1.5,
                    keyType: .action
                )
            )
        }
    }
}
