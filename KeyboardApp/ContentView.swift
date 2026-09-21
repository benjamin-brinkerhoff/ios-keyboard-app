//
//  ContentView.swift
//  KeyboardApp
//
//  Gboard-style Settings, Feature Dashboard, and Testing Playground.
//

import SwiftUI

struct ContentView: View {
    @State private var testInput: String = ""
    @AppStorage("showNumberRow") private var showNumberRow: Bool = true
    @AppStorage("showKeyBorders") private var showKeyBorders: Bool = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("selectedTheme") private var selectedTheme: String = "System Auto"

    // App Group clipboard items
    @State private var savedSnippets: [String] = [
        "Hello! Hope you're having a great day.",
        "Thanks for reaching out!",
        "On my way! 🚗"
    ]
    @State private var newSnippetText: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interactive Playground")) {
                    Text("Tap to test your Gboard-style keyboard with suggestions, text editing, and symbol popups:")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    TextField("Type here to test...", text: $testInput)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    if !testInput.isEmpty {
                        Button("Clear Text") {
                            testInput = ""
                        }
                        .font(.footnote)
                        .foregroundColor(.red)
                    }
                }

                Section(header: Text("Gboard Preferences")) {
                    Toggle("Dedicated Number Row", isOn: $showNumberRow)
                    Toggle("Key Borders", isOn: $showKeyBorders)
                    Toggle("Haptic Feedback on Keypress", isOn: $hapticsEnabled)
                    Toggle("Key Audio Clicks", isOn: $soundEnabled)

                    Picker("Default Theme", selection: $selectedTheme) {
                        Text("System Auto").tag("System Auto")
                        Text("Dark (AMOLED)").tag("Dark (AMOLED)")
                        Text("Light").tag("Light")
                        Text("Dynamic Teal").tag("Dynamic Teal")
                        Text("Desert Sand").tag("Desert Sand")
                        Text("Forest Mint").tag("Forest Mint")
                        Text("Midnight Lilac").tag("Midnight Lilac")
                    }
                }

                Section(header: Text("Gboard Feature Suite Included")) {
                    FeatureRow(
                        icon: "character.textbox",
                        color: .blue,
                        title: "Predictions & Auto-Correction",
                        desc: "Trie-based prefix completions, next-word bigram suggestions, and top prediction strip."
                    )

                    FeatureRow(
                        icon: "arrow.up.and.down.and.arrow.left.and.right",
                        color: .purple,
                        title: "Text Editing Navigation Pad",
                        desc: "Full directional D-pad, text selection mode, Select All, Cut, Copy, Paste, and Jump to Start/End."
                    )

                    FeatureRow(
                        icon: "cursorarrow.motionlines",
                        color: .teal,
                        title: "Spacebar Cursor Scrubbing",
                        desc: "Slide your finger horizontally across the spacebar to glide the cursor precisely."
                    )

                    FeatureRow(
                        icon: "delete.backward.fill",
                        color: .red,
                        title: "Backspace Slide-to-Delete",
                        desc: "Swipe left from the backspace key to quickly delete multiple words."
                    )

                    FeatureRow(
                        icon: "hand.point.up.left.fill",
                        color: .orange,
                        title: "One-Handed Mode",
                        desc: "Dock the keyboard to the left or right with quick resize and switch side buttons."
                    )

                    FeatureRow(
                        icon: "face.smiling.fill",
                        color: .yellow,
                        title: "Categorized Emoji Picker",
                        desc: "9 categorized emoji sections with quick category switcher strip."
                    )

                    FeatureRow(
                        icon: "paintpalette.fill",
                        color: .pink,
                        title: "Material You Themes & Borders",
                        desc: "7 custom themes with AMOLED Dark, Dynamic Teal, and toggleable key borders."
                    )

                    FeatureRow(
                        icon: "doc.on.clipboard.fill",
                        color: .green,
                        title: "Clipboard Manager",
                        desc: "History tracking, quick-paste chips, pinned snippets, and expandable clipboard drawer."
                    )
                }

                Section(header: Text("Setup Instructions")) {
                    StepRow(number: "1", title: "Open Settings", desc: "Settings > General > Keyboard > Keyboards")
                    StepRow(number: "2", title: "Add Custom Keyboard", desc: "Tap 'Add New Keyboard...' and choose 'Custom Keyboard'")
                    StepRow(number: "3", title: "Allow Full Access", desc: "Turn ON 'Allow Full Access' to enable clipboard access and theme syncing")
                }

                Section(header: Text("Saved Clipboard Snippets")) {
                    HStack {
                        TextField("Add new snippet...", text: $newSnippetText)
                        Button(action: addSnippet) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .disabled(newSnippetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    ForEach(savedSnippets, id: \.self) { snippet in
                        Text(snippet)
                            .font(.subheadline)
                    }
                    .onDelete(perform: deleteSnippet)
                }
            }
            .navigationTitle("Gboard for iOS")
        }
    }

    private func addSnippet() {
        let trimmed = newSnippetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        savedSnippets.insert(trimmed, at: 0)
        newSnippetText = ""
    }

    private func deleteSnippet(at offsets: IndexSet) {
        savedSnippets.remove(atOffsets: offsets)
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

struct StepRow: View {
    let number: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.accentColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}
