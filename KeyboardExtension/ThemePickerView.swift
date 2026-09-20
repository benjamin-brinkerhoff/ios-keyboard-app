//
//  ThemePickerView.swift
//  KeyboardExtension
//
//  Inline Theme selector matching Gboard's theme customization.
//

import SwiftUI

struct ThemePickerView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Gboard Themes")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()

                // Key Borders toggle
                Toggle("Key Borders", isOn: $viewModel.showKeyBorders)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .font(.system(size: 12))
                    .frame(width: 140)

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
            .padding(.horizontal, 14)
            .padding(.top, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GboardTheme.allCases) { theme in
                        Button(action: {
                            withAnimation {
                                viewModel.currentTheme = theme
                            }
                            viewModel.triggerHaptic(style: .medium)
                        }) {
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(theme.backgroundColor)
                                    .frame(width: 70, height: 50)
                                    .overlay(
                                        VStack(spacing: 3) {
                                            HStack(spacing: 2) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(theme.keyStandardColor)
                                                    .frame(width: 16, height: 12)
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(theme.keyStandardColor)
                                                    .frame(width: 16, height: 12)
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(theme.keyStandardColor)
                                                    .frame(width: 16, height: 12)
                                            }
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(theme.accentColor)
                                                .frame(width: 32, height: 8)
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.currentTheme == theme ? Color.accentColor : Color.clear, lineWidth: 2.5)
                                    )

                                Text(theme.rawValue)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            .frame(width: 76)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .frame(height: 120)
        .background(Color(UIColor.systemBackground))
    }
}
