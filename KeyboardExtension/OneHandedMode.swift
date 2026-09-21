//
//  OneHandedMode.swift
//  KeyboardExtension
//
//  Gboard-style One-Handed keyboard layout support (Left/Right docking and rails).
//

import SwiftUI
import UIKit

enum OneHandedState: String, CaseIterable {
    case none
    case left
    case right
}

struct OneHandedRailView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let isLeftSide: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Expand back to full width
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.oneHandedState = .none
                }
            }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 38, height: 38)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(Circle())
            }

            // Switch to other side
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.oneHandedState = (viewModel.oneHandedState == .left) ? .right : .left
                }
            }) {
                Image(systemName: isLeftSide ? "chevron.right.2" : "chevron.left.2")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 38, height: 38)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()
        }
        .frame(width: 48)
        .background(Color(UIColor.systemGray4).opacity(0.4))
    }
}
