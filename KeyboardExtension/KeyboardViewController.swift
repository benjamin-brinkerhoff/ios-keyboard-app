//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Custom iOS Keyboard Extension Entry Point
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    private var viewModel = KeyboardViewModel()
    private var hostingController: UIHostingController<KeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModelCallbacks()
        setupSwiftUIKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateNeedsInputModeSwitchKey(needsInputModeSwitchKey)
        viewModel.checkFullAccess()
        viewModel.refreshClipboard()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.updateNeedsInputModeSwitchKey(needsInputModeSwitchKey)
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Context before and after cursor changed
        viewModel.updateContext(
            before: textDocumentProxy.documentContextBeforeInput,
            after: textDocumentProxy.documentContextAfterInput
        )
    }

    // MARK: - Setup

    private func setupViewModelCallbacks() {
        viewModel.onInsertText = { [weak self] text in
            self?.textDocumentProxy.insertText(text)
            self?.playClickSound()
        }

        viewModel.onDeleteBackward = { [weak self] in
            self?.textDocumentProxy.deleteBackward()
            self?.playClickSound()
        }

        viewModel.onNextKeyboard = { [weak self] in
            self?.advanceToNextInputMode()
        }

        viewModel.onDismissKeyboard = { [weak self] in
            self?.dismissKeyboard()
        }

        viewModel.onRequestAdjustPosition = { [weak self] offset in
            self?.textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
        }
    }

    private func setupSwiftUIKeyboard() {
        let keyboardView = KeyboardView(viewModel: viewModel)
        let host = UIHostingController(rootView: keyboardView)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        view.backgroundColor = .clear

        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)

        let heightConstraint = host.view.heightAnchor.constraint(equalToConstant: 290)
        heightConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightConstraint
        ])

        self.hostingController = host
    }

    private func playClickSound() {
        guard viewModel.soundEnabled else { return }
        UIDevice.current.playInputClick()
    }
}

// MARK: - UIInputViewAudioFeedback
extension KeyboardViewController: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        return true
    }
}
