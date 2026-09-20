//
//  ClipboardBarView.swift
//  KeyboardExtension
//
//  Toolbar strip above keys providing instant access to clipboard history and quick snippets.
//

import SwiftUI

struct ClipboardBarView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject var clipboardManager: ClipboardManager

    var body: some View {
        VStack(spacing: 0) {
            // Horizontal Quick Bar
            HStack(spacing: 8) {
                // Clipboard drawer toggle button
                Button(action: {
                    viewModel.handleKeyTap(
                        KeyItem(label: "Clipboard", action: .clipboardToggle, keyType: .action)
                    )
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 14))
                        Text("Clipboard")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.isClipboardDrawerOpen ? Color.accentColor : Color(UIColor.systemGray5))
                    .foregroundColor(viewModel.isClipboardDrawerOpen ? .white : .primary)
                    .cornerRadius(8)
                }

                // Recent clipboard items horizontal scroll
                if !clipboardManager.hasFullAccess {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("Enable 'Allow Full Access' in Settings to use Clipboard")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                } else if clipboardManager.history.isEmpty {
                    Text("Clipboard is empty")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(clipboardManager.history.prefix(8)) { item in
                                Button(action: {
                                    viewModel.pasteClipboardText(item.text)
                                }) {
                                    HStack(spacing: 4) {
                                        if item.isPinned {
                                            Image(systemName: "pin.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(.orange)
                                        }
                                        Text(item.text)
                                            .font(.system(size: 13))
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                // Quick Paste button if clipboard has active string
                if clipboardManager.hasFullAccess {
                    Button(action: {
                        clipboardManager.syncFromPasteboard()
                        if let first = clipboardManager.history.first {
                            viewModel.pasteClipboardText(first.text)
                        }
                    }) {
                        Image(systemName: "arrow.right.doc.on.clipboard")
                            .font(.system(size: 14))
                            .padding(6)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 38)

            // Expanded Full Clipboard Drawer
            if viewModel.isClipboardDrawerOpen {
                Divider()
                expandedClipboardDrawer
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
    }

    private var expandedClipboardDrawer: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Saved Clips (\(clipboardManager.history.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    clipboardManager.clearUnpinned()
                }) {
                    Text("Clear Unpinned")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 6) {
                    ForEach(clipboardManager.history) { item in
                        HStack {
                            Button(action: {
                                viewModel.pasteClipboardText(item.text)
                            }) {
                                Text(item.text)
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button(action: {
                                clipboardManager.togglePin(for: item)
                            }) {
                                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                    .font(.system(size: 13))
                                    .foregroundColor(item.isPinned ? .orange : .secondary)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Button(action: {
                                clipboardManager.deleteItem(id: item.id)
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
            }
            .frame(maxHeight: 140)
        }
    }
}
