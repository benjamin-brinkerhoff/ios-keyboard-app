//
//  KeyboardView.swift
//  KeyboardExtension
//
//  Root SwiftUI container organizing the clipboard bar, key rows, bottom controls, and popup overlay.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        ZStack {
            Color(UIColor.systemGray4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 7) {
                // Top Clipboard Toolbar Bar
                ClipboardBarView(viewModel: viewModel, clipboardManager: viewModel.clipboardManager)

                // Key Rows
                ForEach(currentRows) { row in
                    HStack(spacing: 5) {
                        ForEach(row.keys) { key in
                            KeyButtonView(viewModel: viewModel, key: key)
                                .frame(maxWidth: keyWidth(for: key))
                        }
                    }
                    .padding(.horizontal, 4)
                }

                // Bottom Functional Controls Row (123 / ABC, Globe, Spacebar, Return)
                bottomControlsRow
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
            }

            // Top-layer Popup callout for long-press alternate symbols
            if let activeKey = viewModel.activePopupKey {
                KeyPopupView(
                    key: activeKey,
                    selectedIndex: viewModel.selectedAlternateIndex,
                    anchorFrame: viewModel.popupGlobalFrame
                )
            }
        }
        .frame(height: 275)
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
        // Specific width modifiers
        return 44.0 * key.widthRatio
    }

    private var bottomControlsRow: some View {
        HStack(spacing: 5) {
            // Layer switch button (123 or ABC)
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "layer_switch",
                    label: viewModel.currentLayer == .letters ? "123" : "ABC",
                    action: .switchLayer(viewModel.currentLayer == .letters ? .numbers : .letters),
                    widthRatio: 1.4,
                    keyType: .modifier
                )
            )

            // Globe / next keyboard button (only if multiple keyboards enabled)
            if viewModel.needsInputModeSwitchKey {
                KeyButtonView(
                    viewModel: viewModel,
                    key: KeyItem(
                        id: "globe",
                        label: "globe",
                        action: .globe,
                        widthRatio: 1.1,
                        keyType: .modifier
                    )
                )
            }

            // Spacebar
            KeyButtonView(
                viewModel: viewModel,
                key: KeyItem(
                    id: "space",
                    label: "space",
                    action: .space,
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
                    widthRatio: 1.7,
                    keyType: .action
                )
            )
        }
    }
}
