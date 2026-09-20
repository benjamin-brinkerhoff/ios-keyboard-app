# iOS Keyboard App with Built-in Clipboard & Symbol Popups

A custom iOS keyboard extension and companion container app built with **SwiftUI** and **UIKit**.

## Features

- **Long-Press Symbol & Accent Popups**:
  - Hold down any letter key to display an interactive popup bubble with associated numbers, symbols, and accented characters (e.g. `q` -> `1`, `!`, `e` -> `3`, `é`, `€`, `a` -> `@`, `à`, `s` -> `$`, `ß`).
  - Slide your finger across the popup to select a character and release to insert.
  - Subtle preview indicators for primary alternates displayed directly on keys.
- **Built-in Clipboard & Snippet Manager**:
  - Horizontal quick-access toolbar directly above the keyboard layout.
  - View recent clips and one-tap paste directly into the active text field.
  - Expandable clipboard drawer to browse full history, pin favorite snippets, and clear unpinned clips.
  - Synchronizes with `UIPasteboard` (requires *Allow Full Access* in iOS Settings).
  - App Group support (`group.com.ioskeyboard.app`) to share snippets seamlessly between the container app and keyboard extension.
- **Modern iOS Keyboard Experience**:
  - QWERTY layout with automatic sentence capitalization.
  - Numbers and symbol layers (`123`, `#+=`, `ABC`).
  - Native tactile haptic feedback using `UIImpactFeedbackGenerator` and `UISelectionFeedbackGenerator`.
  - System key audio clicks conforming to `UIInputViewAudioFeedback`.
  - Dark Mode and Light Mode dynamic styling adapting automatically to the host application.
  - Support for the system keyboard switcher (Globe key) when multiple keyboards are active.

---

## Architecture Overview

The repository is structured into two main components:

```
ios-keyboard-app/
├── KeyboardApp/                  # Container App Target
│   ├── KeyboardApp.swift         # App Entry Point
│   └── ContentView.swift         # Settings, Instructions & Test Playground
│
├── KeyboardExtension/            # Custom Keyboard Extension Target
│   ├── KeyboardViewController.swift # UIInputViewController entry point & system bridge
│   ├── KeyboardViewModel.swift      # State coordinator, gesture tracking, & haptics
│   ├── KeyboardLayout.swift         # Rows, character mappings & alternate symbol definitions
│   ├── KeyboardView.swift           # Root SwiftUI keyboard layout
│   ├── KeyButtonView.swift          # Key button with tap & long-press gesture recognizers
│   ├── KeyPopupView.swift           # Floating callout bubble for alternate symbols
│   ├── ClipboardManager.swift       # Pasteboard sync, persistence & snippet pinning
│   ├── ClipboardBarView.swift       # Quick paste strip & expandable clipboard drawer
│   └── Info.plist                   # Extension configuration (RequestsOpenAccess = YES)
│
└── .github/workflows/
    └── build.yml                 # GitHub Actions CI build workflow
```

---

## Xcode Setup & Running

### 1. Requirements
- macOS with **Xcode 15+**
- iOS 16.0+ deployment target

### 2. Creating the Project Targets in Xcode
If configuring a fresh `.xcodeproj`:
1. Create a new iOS App project named `KeyboardApp` using SwiftUI.
2. In Xcode, go to **File > New > Target...**, choose **Custom Keyboard Extension**, and name it `KeyboardExtension`.
3. Replace the template files with the files provided in this repository.

### 3. Enabling Full Access for Clipboard
In `KeyboardExtension/Info.plist`, ensure:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>RequestsOpenAccess</key>
        <true/>
    </dict>
</dict>
```

### 4. Optional: App Groups for Shared Clipboard
To share snippets between the container app and the extension:
1. Select the `KeyboardApp` target -> **Signing & Capabilities** -> **+ Capability** -> **App Groups**.
2. Add `group.com.ioskeyboard.app`.
3. Select the `KeyboardExtension` target and enable the exact same App Group identifier.

---

## Enabling the Keyboard on Device / Simulator

1. Build and run the `KeyboardApp` scheme on your simulator or connected device.
2. Open the **Settings** app on iOS.
3. Navigate to **General > Keyboard > Keyboards > Add New Keyboard...**.
4. Under *Third-Party Keyboards*, tap **Custom Keyboard**.
5. Tap **Custom Keyboard** in the list and toggle **Allow Full Access** to **ON** (this grants permission to access `UIPasteboard` for clipboard history).
6. Open any app with a text field (Messages, Notes, Safari) or the `KeyboardApp` test ground and switch to your custom keyboard using the globe key!

---

## Customization

- **Add Custom Key Mappings**: Edit `KeyboardLayout.alternateKeyMap` in `KeyboardLayout.swift` to add or modify symbols revealed when holding any letter.
- **Adjust Hold Duration**: In `KeyButtonView.swift`, the long-press delay is set to `0.32` seconds by default.
- **Theming**: Colors in `KeyButtonView.swift` and `KeyboardView.swift` use dynamic `UIColor.systemBackground` and `UIColor.systemGray` values to match iOS native dark/light modes.
