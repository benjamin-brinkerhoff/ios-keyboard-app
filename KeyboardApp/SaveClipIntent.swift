//
//  SaveClipIntent.swift
//  KeyboardApp
//
//  AppIntent enabling native iOS Shortcuts and Back Tap execution in the background
//  without opening the main app UI.
//

import AppIntents
import UIKit
import Foundation

@available(iOS 16.0, *)
struct SaveClipIntent: AppIntent {
    static var title: LocalizedStringResource = "Save to Keyboard Clips"
    static var description = IntentDescription("Saves clipboard text or input text directly to the custom keyboard clips in the background.")

    // Runs headlessly in the background without bringing the app into foreground
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Text", description: "Optional text to save. If omitted, takes current clipboard content.")
    var text: String?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let contentToSave: String
        if let input = text, !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentToSave = input
        } else if let clip = UIPasteboard.general.string, !clip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentToSave = clip
        } else {
            return .result(dialog: "Clipboard is currently empty.")
        }

        let appGroupSuite = "group.com.ioskeyboard.app"
        let storageKey = "saved_clipboard_items"
        let defaults = UserDefaults(suiteName: appGroupSuite) ?? UserDefaults.standard

        var history: [ClipboardItem] = []
        if let data = defaults.data(forKey: storageKey),
           let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            history = items
        }

        // Prepend if not duplicate of first item
        if history.first?.text != contentToSave {
            let newItem = ClipboardItem(text: contentToSave)
            history.insert(newItem, at: 0)

            // Defensive history trimming (avoid negative prefix)
            if history.count > 30 {
                let pinned = history.filter { $0.isPinned }
                let unpinned = history.filter { !$0.isPinned }
                let availableSlots = max(0, 30 - pinned.count)
                let kept = Array(unpinned.prefix(availableSlots))
                history = pinned + kept
            }

            if let data = try? JSONEncoder().encode(history) {
                defaults.set(data, forKey: storageKey)
            }
        }

        return .result(dialog: "Saved to Keyboard Clips!")
    }
}

@available(iOS 16.0, *)
struct KeyboardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SaveClipIntent(),
            phrases: [
                "Save to \(.applicationName) Clips",
                "Log clip in \(.applicationName)"
            ],
            shortTitle: "Save Clip",
            systemImageName: "doc.on.clipboard"
        )
    }
}
