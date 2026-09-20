//
//  KeyboardViewModel.swift
//  KeyboardExtension
//
//  State coordinator for Gboard-style features: Predictions, Text Editing, Themes,
//  One-Handed mode, Spacebar trackpad, and Symbol popups.
//

import SwiftUI
import Combine

class KeyboardViewModel: ObservableObject {
    // Current layout and layer
    @Published var currentLayer: KeyboardLayer = .letters
    @Published var shiftState: ShiftState = .off
    @Published var needsInputModeSwitchKey: Bool = false

    // Gboard Tools and Drawers
    @Published var activeTool: GboardTool = .none
    @Published var showNumberRow: Bool = true
    @Published var oneHandedState: OneHandedState = .none
    @Published var currentTheme: GboardTheme = .system
    @Published var showKeyBorders: Bool = true

    // Predictive text & Suggestions
    @Published var currentPredictions: [String] = ["I", "The", "Thanks"]
    @Published var currentWordPrefix: String = ""
    let predictionEngine = PredictionEngine()

    // Context from textDocumentProxy
    @Published var contextBefore: String?
    @Published var contextAfter: String?

    // Long press symbol popup state
    @Published var activePopupKey: KeyItem?
    @Published var selectedAlternateIndex: Int?
    @Published var popupGlobalFrame: CGRect = .zero

    // Spacebar cursor scrub tracking
    @Published var isSpacebarDragging: Bool = false
    private var lastDragStep: CGFloat = 0

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

        // Extract active word under cursor for predictive completions
        if let before = before {
            let tokens = before.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            let currentWord = tokens.last ?? ""
            self.currentWordPrefix = currentWord

            // Find preceding word for bigram next-word prediction
            let nonEmptyTokens = tokens.filter { !$0.isEmpty }
            let prevWord = nonEmptyTokens.count >= 2 ? nonEmptyTokens[nonEmptyTokens.count - 2] : nil

            let predictions = predictionEngine.getPredictions(for: currentWord, previousWord: prevWord)
            self.currentPredictions = predictions

            // Auto-capitalize after sentence endings
            if currentLayer == .letters && shiftState == .off {
                if before.hasSuffix(". ") || before.hasSuffix("! ") || before.hasSuffix("? ") || before.isEmpty {
                    shiftState = .shifted
                }
            }
        } else {
            self.currentWordPrefix = ""
            self.currentPredictions = ["I", "The", "Thanks"]
        }
    }

    // MARK: - Prediction Application

    func applyPrediction(_ word: String) {
        triggerHaptic(style: .light)

        // Delete currently typed partial prefix
        let charactersToDelete = currentWordPrefix.count
        for _ in 0..<charactersToDelete {
            onDeleteBackward?()
        }

        // Insert full predicted word + trailing space
        let textToInsert = word + " "
        onInsertText?(textToInsert)

        currentWordPrefix = ""
    }

    // MARK: - Spacebar Cursor Scrubbing (Trackpad Mode)

    func handleSpacebarDragChange(translation: CGFloat) {
        let stepThreshold: CGFloat = 11.0
        let delta = translation - lastDragStep

        if abs(delta) >= stepThreshold {
            let characters = Int(delta / stepThreshold)
            onRequestAdjustPosition?(characters)
            lastDragStep += CGFloat(characters) * stepThreshold
            triggerSelectionFeedback()
        }
    }

    func handleSpacebarDragEnd() {
        lastDragStep = 0
        isSpacebarDragging = false
    }

    // MARK: - Backspace Slide-to-Delete

    func handleBackspaceSlide(translation: CGFloat) {
        // Sliding left on backspace deletes multiple words (Gboard feature)
        if translation < -30 {
            // Delete word
            onDeleteBackward?()
            triggerHaptic(style: .medium)
        }
    }

    // MARK: - Cursor Movement

    func moveCursor(by offset: Int) {
        onRequestAdjustPosition?(offset)
        triggerSelectionFeedback()
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
                activeTool = (activeTool == .clipboard) ? .none : .clipboard
            }

        case .emoji:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeTool = (activeTool == .emoji) ? .none : .emoji
            }
        }
    }

    // MARK: - Long Press Alternate Symbols Handling

    func handleLongPressStart(for key: KeyItem, in frame: CGRect) {
        guard !key.alternates.isEmpty else { return }
        triggerHaptic(style: .medium)
        self.activePopupKey = key
        self.popupGlobalFrame = frame
        self.selectedAlternateIndex = 0
    }

    func handleLongPressDrag(offset: CGFloat, keyWidth: CGFloat) {
        guard let key = activePopupKey, !key.alternates.isEmpty else { return }
        let count = key.alternates.count
        let itemWidth: CGFloat = 36.0
        let totalPopupWidth = CGFloat(count) * itemWidth

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
