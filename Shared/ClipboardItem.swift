//
//  ClipboardItem.swift
//  Shared
//
//  Shared data model between KeyboardApp and KeyboardExtension.
//

import Foundation

public struct ClipboardItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let text: String
    public let timestamp: Date
    public var isPinned: Bool

    public init(id: UUID = UUID(), text: String, timestamp: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isPinned = isPinned
    }
}
