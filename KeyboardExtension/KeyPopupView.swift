//
//  KeyPopupView.swift
//  KeyboardExtension
//
//  Popup callout showing alternate symbols and accented characters on long press.
//

import SwiftUI

struct KeyPopupView: View {
    let key: KeyItem
    let selectedIndex: Int?
    let anchorFrame: CGRect

    private let itemWidth: CGFloat = 36.0
    private let popupHeight: CGFloat = 50.0

    var body: some View {
        let count = key.alternates.count
        let totalWidth = CGFloat(count) * itemWidth + 16

        VStack(spacing: 0) {
            // Popup items horizontal row
            HStack(spacing: 4) {
                ForEach(0..<count, id: \.self) { index in
                    let symbol = key.alternates[index]
                    let isSelected = (index == selectedIndex)

                    Text(symbol)
                        .font(.system(size: 20, weight: isSelected ? .bold : .medium, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primary)
                        .frame(width: itemWidth, height: popupHeight - 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor : Color.clear)
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isSelected)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: popupHeight)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 3)
            )

            // Little downward pointer triangle pointing to the pressed key
            Triangle()
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .frame(width: 16, height: 8)
                .offset(y: -1)
        }
        .frame(width: totalWidth)
        .position(x: clampedCenterX(totalWidth: totalWidth), y: anchorFrame.minY - (popupHeight / 2) - 6)
        .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .bottom)))
    }

    private func clampedCenterX(totalWidth: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let desiredCenter = anchorFrame.midX
        let halfWidth = totalWidth / 2.0
        let padding: CGFloat = 8.0

        if desiredCenter - halfWidth < padding {
            return halfWidth + padding
        } else if desiredCenter + halfWidth > screenWidth - padding {
            return screenWidth - halfWidth - padding
        }
        return desiredCenter
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
