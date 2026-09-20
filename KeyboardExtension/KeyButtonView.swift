//
//  KeyButtonView.swift
//  KeyboardExtension
//
//  Interactive key view supporting tap, long press popup, drag selection, and styling.
//

import SwiftUI

struct KeyButtonView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let key: KeyItem

    @State private var isPressed: Bool = false
    @State private var longPressWorkItem: DispatchWorkItem?
    @State private var globalFrame: CGRect = .zero

    private let keyCornerRadius: CGFloat = 8.0
    private let keyHeight: CGFloat = 46.0

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)

            ZStack {
                // Key background
                RoundedRectangle(cornerRadius: keyCornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.18), radius: 0, x: 0, y: isPressed ? 0.5 : 1.2)

                // Key label / icon
                keyLabelView
            }
            .frame(height: keyHeight)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            self.globalFrame = frame

                            // Schedule long press detection
                            let workItem = DispatchWorkItem {
                                if self.isPressed {
                                    self.viewModel.handleLongPressStart(for: key, in: self.globalFrame)
                                }
                            }
                            self.longPressWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32, execute: workItem)
                        } else if viewModel.activePopupKey?.id == key.id {
                            // Dragging while popup is active
                            let dragOffset = value.translation.width
                            viewModel.handleLongPressDrag(offset: dragOffset, keyWidth: frame.width)
                        }
                    }
                    .onEnded { value in
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
                // Primary character
                Text(char)
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .foregroundColor(.primary)

                // Optional subtle preview of primary alternate symbol on the top corner if present
                if let firstAlt = key.alternates.first, key.keyType == .standard {
                    Text(firstAlt)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))
                        .offset(y: -2)
                }
            }

        case .shift:
            Image(systemName: key.label)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(viewModel.shiftState != .off ? Color.accentColor : .primary)

        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.primary)

        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.primary)

        case .clipboardToggle:
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.isClipboardDrawerOpen ? Color.accentColor : .primary)

        default:
            Text(key.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
        }
    }

    private var backgroundColor: Color {
        if isPressed {
            return Color(UIColor.systemGray3)
        }
        switch key.keyType {
        case .standard:
            return Color(UIColor.systemBackground)
        case .modifier, .action:
            return Color(UIColor.systemGray5)
        }
    }
}
