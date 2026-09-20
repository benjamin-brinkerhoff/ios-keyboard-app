//
//  ContentView.swift
//  KeyboardApp
//
//  Dashboard providing setup instructions, test input field, and clipboard manager.
//

import SwiftUI

struct ContentView: View {
    @State private var testInput: String = ""
    @State private var isKeyboardEnabled: Bool = false
    @State private var hasFullAccess: Bool = false

    // App Group clipboard items shared with extension
    @State private var savedSnippets: [String] = [
        "Hello! Hope you're having a great day.",
        "Thanks for reaching out!",
        "On my way! 🚗"
    ]
    @State private var newSnippetText: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interactive Test Ground")) {
                    Text("Tap the text field below to test your custom keyboard:")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    TextField("Type here to test keyboard...", text: $testInput)
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

                Section(header: Text("Features Overview")) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Hold for Symbols & Accents")
                                .font(.headline)
                            Text("Press and hold any letter to reveal numbers, punctuation, and accented characters. Drag to select.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: "doc.on.clipboard.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Built-in Clipboard & Snippets")
                                .font(.headline)
                            Text("Instant access to recent clips, saved snippets, and one-tap paste directly above the keys.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Haptics & Audio")
                                .font(.headline)
                            Text("Responsive native tactile feedback and system key clicks on touch.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Setup Instructions")) {
                    StepRow(number: "1", title: "Open iOS Settings", desc: "Go to Settings > General > Keyboard > Keyboards")
                    StepRow(number: "2", title: "Add New Keyboard", desc: "Tap 'Add New Keyboard...' and select 'Custom Keyboard'")
                    StepRow(number: "3", title: "Enable Full Access", desc: "Tap 'Custom Keyboard' and turn on 'Allow Full Access' (required for clipboard read/paste)")
                }

                Section(header: Text("Clipboard Quick Snippets")) {
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
            .navigationTitle("iOS Keyboard App")
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

struct StepRow: View {
    let number: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
