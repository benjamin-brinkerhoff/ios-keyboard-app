//
//  ToolbarView.swift
//  KeyboardExtension
//
//  Gboard-style Action Toolbar with chevron toggle, predictive word chips, and tool shortcuts.
//

import SwiftUI

enum GboardTool: Equatable {
    case none
    case clipboard
    case textEditing
    case emoji
    case themes
}

struct ToolbarView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @State private var isShowingTools: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Expand / Collapse Chevron Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isShowingTools.toggle()
                }
            }) {
                Image(systemName: isShowingTools ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isShowingTools ? Color.accentColor : .secondary)
                    .padding(.horizontal, 8)
            }

            if isShowingTools {
                // Tools list (Text Edit, Clipboard, Themes, One-Handed, Number Row)
                toolsStrip
                    .transition(.move(edge: .leading).combined(with: .opacity))
            } else {
                // Predictive word suggestions strip
                predictionsStrip
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(height: 38)
        .background(viewModel.currentTheme.backgroundColor.opacity(0.95))
    }

    private var toolsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                toolIcon(title: "Clipboard", icon: "doc.on.clipboard", tool: .clipboard)
                toolIcon(title: "Text Edit", icon: "arrow.up.and.down.and.arrow.left.and.right", tool: .textEditing)
                toolIcon(title: "Themes", icon: "paintpalette", tool: .themes)
                toolIcon(title: "Emoji", icon: "face.smiling", tool: .emoji)

                // Toggle Number Row
                Button(action: {
                    withAnimation {
                        viewModel.showNumberRow.toggle()
                    }
                    viewModel.triggerHaptic(style: .light)
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "number")
                            .font(.system(size: 13))
                        Text(viewModel.showNumberRow ? "123: ON" : "123: OFF")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(viewModel.showNumberRow ? Color.accentColor : Color(UIColor.systemGray5))
                    .foregroundColor(viewModel.showNumberRow ? .white : .primary)
                    .cornerRadius(8)
                }

                // Toggle One-Handed Mode
                Button(action: {
                    withAnimation {
                        viewModel.oneHandedState = (viewModel.oneHandedState == .none) ? .right : .none
                    }
                    viewModel.triggerHaptic(style: .light)
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "hand.point.up.left")
                            .font(.system(size: 13))
                        Text(viewModel.oneHandedState != .none ? "1-Hand: ON" : "1-Hand")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(viewModel.oneHandedState != .none ? Color.accentColor : Color(UIColor.systemGray5))
                    .foregroundColor(viewModel.oneHandedState != .none ? .white : .primary)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 6)
        }
    }

    private var predictionsStrip: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.currentPredictions, id: \.self) { prediction in
                Button(action: {
                    viewModel.applyPrediction(prediction)
                }) {
                    Text(prediction)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.currentTheme.keyTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(viewModel.currentTheme.keyStandardColor.opacity(0.85))
                        )
                }
            }
        }
        .padding(.horizontal, 6)
    }

    private func toolIcon(title: String, icon: String, tool: GboardTool) -> some View {
        Button(action: {
            withAnimation {
                viewModel.activeTool = (viewModel.activeTool == tool) ? .none : tool
            }
            viewModel.triggerHaptic(style: .light)
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(viewModel.activeTool == tool ? Color.accentColor : Color(UIColor.systemGray5))
            .foregroundColor(viewModel.activeTool == tool ? .white : .primary)
            .cornerRadius(8)
        }
    }
}
