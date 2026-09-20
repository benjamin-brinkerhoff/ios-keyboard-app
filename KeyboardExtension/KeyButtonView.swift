//
//  KeyButtonView.swift
//  KeyboardExtension
//
//  Interactive key view with theme styling, key borders, tap, long press popup,
//  and spacebar cursor trackpad gesture support.
//

import SwiftUI

struct KeyButtonView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let key: KeyItem

    @State private var isPressed: Bool = false
    @State private var longPressWorkItem: DispatchWorkItem?
    @State private var globalFrame: CGRect = .zero

    private let keyCornerRadius: CGFloat = 7.0
    private let keyHeight: CGFloat = 43.0

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)

            ZStack {
                // Key Background with Key Borders toggle support
                RoundedRectangle(cornerRadius: keyCornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: keyCornerRadius)
                            .stroke(
                                viewModel.showKeyBorders ? Color.black.opacity(0.12) : Color.clear,
                                lineWidth: viewModel.showKeyBorders ? 1.0 : 0
                            )
                    )
                    .shadow(
                        color: viewModel.showKeyBorders ? Color.black.opacity(0.18) : Color.clear,
                        radius: 0,
                        x: 0,
                        y: isPressed ? 0.4 : 1.0
                    )

                // Key label / icon
                keyLabelView
            }
            .frame(height: keyHeight)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if key.action == .space {
                            // Spacebar cursor scrubbing trackpad gesture
                            if abs(value.translation.width) > 8 {
                                viewModel.isSpacebarDragging = true
                                viewModel.handleSpacebarDragChange(translation: value.translation.width)
                            }
                            return
                        }

                        if key.action == .backspace {
                            // Backspace slide to delete gesture
                            viewModel.handleBackspaceSlide(translation: value.translation.width)
                        }

                        if !isPressed {
                            isPressed = true
                            self.globalFrame = frame

                            // Schedule long press detection for alternate symbols popup
                            let workItem = DispatchWorkItem {
                                if self.isPressed {
                                    self.viewModel.handleLongPressStart(for: key, in: self.globalFrame)
                                }
                            }
                            self.longPressWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30, execute: workItem)
                        } else if viewModel.activePopupKey?.id == key.id {
                            // Dragging across alternate popup
                            let dragOffset = value.translation.width
                            viewModel.handleLongPressDrag(offset: dragOffset, keyWidth: frame.width)
                        }
                    }
                    .onEnded { value in
                        if key.action == .space {
                            viewModel.handleSpacebarDragEnd()
                            if abs(value.translation.width) <= 8 {
                                viewModel.handleKeyTap(key)
                            }
                            return
                        }

                        longPressWorkItem?.cancel()
                        longPressWorkItem = nil

                        if viewModel.activePopupKey?.id == key.id {
                            viewModel.handleLongPressEnd()
                        } else if isPressed {
                            viewModel.handleKeyTap(key)
                        }
                        isPressed = false
                    }
            )
        }
        .frame(height: keyHeight)
    }

    @ViewBuilder
    private var keyLabelView: some View {
        switch key.action {
        case .character(let char):
            VStack(spacing: 0) {
                Text(char)
                    .font(.system(size: 21, weight: .regular, design: .default))
                    .foregroundColor(viewModel.currentTheme.keyTextColor)

                if let firstAlt = key.alternates.first, key.keyType == .standard {
                    Text(firstAlt)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(viewModel.currentTheme.keyTextColor.opacity(0.55))
                        .offset(y: -1)
                }
            }

        case .shift:
            Image(systemName: key.label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(viewModel.shiftState != .off ? viewModel.currentTheme.accentColor : viewModel.currentTheme.keyTextColor)

        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(viewModel.currentTheme.keyTextColor)

        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(viewModel.currentTheme.keyTextColor)

        case .emoji:
            Image(systemName: "face.smiling")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(viewModel.currentTheme.keyTextColor)

        case .space:
            Text(viewModel.isSpacebarDragging ? "◄ Scrub Cursor ►" : "English (US)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(viewModel.currentTheme.keyTextColor.opacity(0.7))

        default:
            Text(key.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(viewModel.currentTheme.keyTextColor)
        }
    }

    private var backgroundColor: Color {
        if isPressed {
            return viewModel.currentTheme.keyModifierColor
        }
        switch key.keyType {
        case .standard:
            return viewModel.currentTheme.keyStandardColor
        case .modifier, .action:
            return viewModel.currentTheme.keyModifierColor
        }
    }
}
