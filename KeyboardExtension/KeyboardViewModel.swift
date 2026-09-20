//
//  KeyboardViewModel.swift
//  KeyboardExtension
//
//  State coordinator for keyboard extension, gestures, layouts, and system bridge.
//

import SwiftUI
import Combine

class KeyboardViewModel: ObservableObject {
    // Current layout and state
    @Published var currentLayer: KeyboardLayer = .letters
    @Published var shiftState: ShiftState = .off
    @Published var needsInputModeSwitchKey: Bool = false
    @Published var isClipboardDrawerOpen: Bool = false

    // Context from textDocumentProxy
    @Published var contextBefore: String?
    @Published var contextAfter: String?

    // Long press symbol popup state
    @Published var activePopupKey: KeyItem?
    @Published var selectedAlternateIndex: Int?
    @Published var popupGlobalFrame: CGRect = .zero

    // User preferences
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true

    // Managers
    let clipboardManager = ClipboardManager()

    // Callbacks to UIInputViewController
    var onInsertText: ((String) -> Void)?
    var onDeleteBackward: (() -> Void)?
    var onNextKeyboard: (() -> Void)?
    var onDismissKeyboard: (() -> Void)?
    var onRequestAdjustPosition: ((Int) -> Void)?

    // Feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    init() {
        impactLight.prepare()
        impactMedium.prepare()
        selectionFeedback.prepare()
    }

    func updateNeedsInputModeSwitchKey(_ value: Bool) {
        self.needsInputModeSwitchKey = value
    }

    func checkFullAccess() {
        clipboardManager.checkFullAccess()
    }

    func refreshClipboard() {
        clipboardManager.syncFromPasteboard()
    }

    func updateContext(before: String?, after: String?) {
        self.contextBefore = before
        self.contextAfter = after

        // Auto-capitalize after period followed by space
        if currentLayer == .letters && shiftState == .off {
            if let before = before, before.hasSuffix(". ") || before.hasSuffix("! ") || before.hasSuffix("? ") || before.isEmpty {
                shiftState = .shifted
            }
        }
    }

    // MARK: - Key Actions

    func handleKeyTap(_ key: KeyItem) {
        triggerHaptic(style: .light)

        switch key.action {
        case .character(let char):
            onInsertText?(char)
            if shiftState == .shifted {
                shiftState = .off
            }

        case .shift:
            switch shiftState {
            case .off:
                shiftState = .shifted
            case .shifted:
                shiftState = .capsLock
            case .capsLock:
                shiftState = .off
            }

        case .backspace:
            onDeleteBackward?()

        case .switchLayer(let targetLayer):
            currentLayer = targetLayer
            if targetLayer == .letters {
                shiftState = .off
            }

        case .space:
            onInsertText?(" ")

        case .returnKey:
            onInsertText?("\n")

        case .globe:
            onNextKeyboard?()

        case .dismiss:
            onDismissKeyboard?()

        case .clipboardToggle:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isClipboardDrawerOpen.toggle()
            }
        }
    }

    // MARK: - Long Press Alternate Symbols Handling

    func handleLongPressStart(for key: KeyItem, in frame: CGRect) {
        guard !key.alternates.isEmpty else { return }
        triggerHaptic(style: .medium)
        self.activePopupKey = key
        self.popupGlobalFrame = frame
        // Default to first alternate or middle
        self.selectedAlternateIndex = 0
    }

    func handleLongPressDrag(offset: CGFloat, keyWidth: CGFloat) {
        guard let key = activePopupKey, !key.alternates.isEmpty else { return }
        let count = key.alternates.count
        let itemWidth: CGFloat = 36.0
        let totalPopupWidth = CGFloat(count) * itemWidth

        // Map offset relative to popup start
        let relativeX = offset + (totalPopupWidth / 2.0)
        let index = Int(relativeX / itemWidth)
        let clampedIndex = max(0, min(count - 1, index))

        if clampedIndex != selectedAlternateIndex {
            selectedAlternateIndex = clampedIndex
            triggerSelectionFeedback()
        }
    }

    func handleLongPressEnd() {
        if let key = activePopupKey, let selectedIndex = selectedAlternateIndex, selectedIndex < key.alternates.count {
            let symbol = key.alternates[selectedIndex]
            onInsertText?(symbol)
            triggerHaptic(style: .light)
        }

        // Reset popup state
        self.activePopupKey = nil
        self.selectedAlternateIndex = nil
        self.popupGlobalFrame = .zero
    }

    func pasteClipboardText(_ text: String) {
        triggerHaptic(style: .medium)
        onInsertText?(text)
    }

    // MARK: - Feedback

    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        if style == .light {
            impactLight.impactOccurred()
        } else {
            impactMedium.impactOccurred()
        }
    }

    func triggerSelectionFeedback() {
        guard hapticsEnabled else { return }
        selectionFeedback.selectionChanged()
    }
}
