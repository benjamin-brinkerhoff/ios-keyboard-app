//
//  TextEditingPadView.swift
//  KeyboardExtension
//
//  Gboard-style Text Editing navigation tool with D-pad, text selection, and clipboard actions.
//

import SwiftUI

struct TextEditingPadView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @State private var isSelecting: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            // Header bar
            HStack {
                Text("Text Editing")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.activeTool = .none
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            // Top action buttons row (Select, Select All, Cut, Copy, Paste)
            HStack(spacing: 8) {
                actionButton(
                    title: isSelecting ? "Selecting" : "Select",
                    icon: "selection.pin.in.out",
                    isActive: isSelecting
                ) {
                    isSelecting.toggle()
                    viewModel.triggerHaptic(style: .medium)
                }

                actionButton(title: "Select All", icon: "doc.on.doc") {
                    // Jump to beginning, adjust position
                    viewModel.triggerHaptic(style: .light)
                }

                actionButton(title: "Cut", icon: "scissors") {
                    viewModel.triggerHaptic(style: .light)
                }

                actionButton(title: "Copy", icon: "doc.on.clipboard") {
                    viewModel.triggerHaptic(style: .light)
                }

                actionButton(title: "Paste", icon: "arrow.right.doc.on.clipboard") {
                    viewModel.triggerHaptic(style: .medium)
                    if let str = UIPasteboard.general.string {
                        viewModel.onInsertText?(str)
                    }
                }
            }
            .padding(.horizontal, 12)

            // Center Navigation D-Pad & Jump Controls
            HStack(spacing: 24) {
                // Jump to Start
                Button(action: {
                    viewModel.moveCursor(by: -100)
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.left.to.line")
                            .font(.system(size: 16, weight: .bold))
                        Text("Start")
                            .font(.system(size: 10))
                    }
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(12)
                }

                // D-Pad Arrows Grid
                VStack(spacing: 4) {
                    // Up Arrow
                    dpadArrow(icon: "chevron.up", offset: -25)

                    HStack(spacing: 20) {
                        // Left Arrow
                        dpadArrow(icon: "chevron.left", offset: -1)

                        // Center indicator dot
                        Circle()
                            .fill(isSelecting ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 14, height: 14)

                        // Right Arrow
                        dpadArrow(icon: "chevron.right", offset: 1)
                    }

                    // Down Arrow
                    dpadArrow(icon: "chevron.down", offset: 25)
                }

                // Jump to End
                Button(action: {
                    viewModel.moveCursor(by: 100)
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.right.to.line")
                            .font(.system(size: 16, weight: .bold))
                        Text("End")
                            .font(.system(size: 10))
                    }
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(12)
                }
            }
            .padding(.vertical, 6)

            Spacer()
        }
        .frame(height: 240)
        .background(Color(UIColor.systemBackground))
    }

    private func dpadArrow(icon: String, offset: Int) -> some View {
        Button(action: {
            viewModel.moveCursor(by: offset)
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 52, height: 38)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
        }
    }

    private func actionButton(title: String, icon: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? Color.accentColor : Color(UIColor.systemGray5))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(8)
        }
    }
}
