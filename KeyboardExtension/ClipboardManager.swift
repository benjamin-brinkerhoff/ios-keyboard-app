//
//  ClipboardManager.swift
//  KeyboardExtension
//
//  Manages clipboard history, pinned snippets, and UIPasteboard synchronization.
//

import UIKit
import Combine

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    var isPinned: Bool

    init(id: UUID = UUID(), text: String, timestamp: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isPinned = isPinned
    }
}

class ClipboardManager: ObservableObject {
    @Published var history: [ClipboardItem] = []
    @Published var hasFullAccess: Bool = false

    private let appGroupSuite = "group.com.ioskeyboard.app"
    private let storageKey = "saved_clipboard_items"
    private let maxHistoryItems = 25

    private var defaults: UserDefaults {
        return UserDefaults(suiteName: appGroupSuite) ?? UserDefaults.standard
    }

    init() {
        loadHistory()
        checkFullAccess()
    }

    func checkFullAccess() {
        // Checking if UIPasteboard is accessible indicates Full Access status in iOS keyboard extension
        if UIPasteboard.general.hasStrings {
            hasFullAccess = true
        } else {
            // Test if we can query general pasteboard
            let test = UIPasteboard.general.string
            hasFullAccess = (test != nil || UIPasteboard.general.hasImages == false)
        }
    }

    func loadHistory() {
        if let data = defaults.data(forKey: storageKey),
           let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            self.history = items
        } else {
            // Seed starter snippets
            self.history = [
                ClipboardItem(text: "Hello! Hope you're having a great day.", isPinned: true),
                ClipboardItem(text: "Thanks for reaching out!", isPinned: true),
                ClipboardItem(text: "On my way! 🚗", isPinned: false)
            ]
            saveHistory()
        }
    }

    func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func syncFromPasteboard() {
        checkFullAccess()
        guard hasFullAccess, let currentString = UIPasteboard.general.string, !currentString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Avoid exact duplicate at the top
        if let first = history.first, first.text == currentString {
            return
        }

        // Insert new item
        let newItem = ClipboardItem(text: currentString)
        history.insert(newItem, at: 0)

        // Prune older unpinned items if exceeding max
        if history.count > maxHistoryItems {
            let pinned = history.filter { $0.isPinned }
            let unpinned = history.filter { !$0.isPinned }
            let keptUnpinned = unpinned.prefix(maxHistoryItems - pinned.count)
            history = pinned + Array(keptUnpinned)
            history.sort { (a, b) -> Bool in
                if a.isPinned != b.isPinned {
                    return a.isPinned
                }
                return a.timestamp > b.timestamp
            }
        }

        saveHistory()
    }

    func addItem(text: String, isPinned: Bool = false) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let item = ClipboardItem(text: text, isPinned: isPinned)
        history.insert(item, at: 0)
        saveHistory()
    }

    func togglePin(for item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history[index].isPinned.toggle()
            history.sort { (a, b) -> Bool in
                if a.isPinned != b.isPinned {
                    return a.isPinned
                }
                return a.timestamp > b.timestamp
            }
            saveHistory()
        }
    }

    func deleteItem(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }

    func deleteItem(id: UUID) {
        history.removeAll { $0.id == id }
        saveHistory()
    }

    func clearUnpinned() {
        history.removeAll { !$0.isPinned }
        saveHistory()
    }
}
