# Gboard-Style iOS Keyboard Application

A comprehensive custom iOS keyboard extension and companion application implementing the core feature suite of **Google Gboard (Android)** for iOS, built with **SwiftUI** and **UIKit**.

---

## Complete Gboard Feature Suite

### 1. 🔍 Predictive Text & Auto-Correction Strip
- **Trie-Based Prefix Engine**: Real-time word completions matching high-frequency English lexicon.
- **Next-Word Suggestions**: Bigram language model predicting next words based on preceding context (e.g. *how* -> *are*, *is*; *thank* -> *you*, *so*).
- **One-Tap Suggestion Chips**: Top prediction strip showing 3 candidate completions. Tapping a chip auto-replaces the prefix and appends a space.

### 2. 🔤 Long-Press Symbol & Accent Popups
- Hold down any letter key to display an interactive popup bubble with associated numbers, symbols, and accented characters (e.g. `q` -> `1`, `!`, `e` -> `3`, `é`, `€`, `a` -> `@`, `à`, `s` -> `$`, `ß`).
- Slide your finger across the popup to select a character and release to insert.
- Subtle preview indicators for primary alternates displayed directly on keys.

### 3. 🎯 Spacebar Cursor Trackpad & Gesture Navigation
- **Spacebar Cursor Scrubbing**: Slide your finger horizontally across the spacebar to glide the cursor through text character-by-character with haptic feedback.
- **Backspace Slide-to-Delete**: Swipe left from the backspace key to quickly delete full words.

### 4. 🧭 Text Editing Tool (D-Pad Controller)
- Gboard's signature **Text Editing Navigation Pad**:
  - Full directional D-Pad: Up, Down, Left, Right arrows with continuous press & single-step cursor positioning.
  - Quick document jumps: Jump to Start (`|◀`) and Jump to End (`▶|`).
  - Text actions: Selection mode toggle, Select All, Cut, Copy, and Paste.

### 5. 🔢 Dedicated Number Row
- Dedicated top row (`1 2 3 4 5 6 7 8 9 0`) positioned above the QWERTY keys.
- Can be toggled on/off instantly via the toolbar or companion app settings.

### 6. 🖐️ One-Handed Mode
- Compress the keyboard layout to either the **Left** or **Right** side for easy single-handed typing on larger iPhones.
- Side control rail provides instant side switching (`<` / `>`) and full-width expand (`⤢`).

### 7. 🎨 Gboard Themes & Key Borders
- **7 Built-In Themes**:
  - System Auto (adapts to light/dark mode)
  - Dark AMOLED (deep black)
  - Light (clean white)
  - Dynamic Teal (Material You inspired)
  - Desert Sand (warm earth tone)
  - Forest Mint (soft green)
  - Midnight Lilac (royal purple)
- **Key Borders Toggle**: Toggle Gboard's signature rectangular key borders on or off.

### 8. 😀 Full Categorized Emoji Keyboard
- 9 distinct categories: Smileys & Emotion, People, Nature, Food, Activities, Travel, Objects, Symbols, Flags.
- Category switcher toolbar with instant navigation and quick-return `ABC` button.

### 9. 📋 Integrated Clipboard Manager
- Horizontal quick-access toolbar directly above the keyboard layout.
- View recent clips and one-tap paste directly into the active text field.
- Expandable clipboard drawer to browse full history, pin favorite snippets, and clear unpinned clips.
- Synchronizes with `UIPasteboard` (requires *Allow Full Access* in iOS Settings).
- App Group support (`group.com.ioskeyboard.app`) to share snippets seamlessly between the container app and keyboard extension.

---

## iOS Platform Architectural Considerations vs Android

When porting Android Gboard features to iOS, several platform sandbox differences apply:

1. **Microphone & Voice Typing**:
   - On Android, keyboard apps have direct access to `AudioRecord` and Google Speech Services.
   - On iOS, Apple's third-party keyboard extension sandbox **strictly blocks direct microphone access** (`AVAudioSession` / `AVAudioEngine` cannot record audio in an extension). Voice dictation on iOS is reserved for Apple's system keyboard, or requires redirecting the user to the container app to record audio.
2. **Inline Google Translate & Cloud Search**:
   - Requires network access (`RequestsOpenAccess = true`) and a Google Cloud Translation API key.
3. **Emoji Kitchen**:
   - Google's Emoji Kitchen combines two emojis into a customized sticker image served via WebP sticker URLs. This can be integrated by fetching stickers over network when Full Access is granted.

---

## Project Structure

```
ios-keyboard-app/
├── KeyboardApp/                  # Container App Target
│   ├── KeyboardApp.swift         # SwiftUI App Entry Point
│   └── ContentView.swift         # Gboard Settings, Dashboard & Interactive Playground
│
├── KeyboardExtension/            # Custom Keyboard Extension Target
│   ├── KeyboardViewController.swift # UIInputViewController entry point & system bridge
│   ├── KeyboardViewModel.swift      # Coordinator for predictions, tools, and gestures
│   ├── KeyboardLayout.swift         # QWERTY, Number Row, and symbol mappings
│   ├── KeyButtonView.swift          # Key button with borders, themes & gesture detection
│   ├── KeyPopupView.swift           # Floating callout bubble for alternate symbols
│   ├── PredictionEngine.swift       # Trie-based dictionary & bigram next-word engine
│   ├── ToolbarView.swift            # Top Gboard action strip & word suggestion chips
│   ├── TextEditingPadView.swift     # Gboard Text Editing navigation D-pad tool
│   ├── EmojiKeyboardView.swift      # 9-category Emoji keyboard
│   ├── ThemeManager.swift           # 7 Material You themes & Key Borders settings
│   ├── ThemePickerView.swift        # Inline theme selector drawer
│   ├── OneHandedMode.swift          # One-handed dock layout and side rails
│   ├── ClipboardManager.swift       # UIPasteboard sync, persistence & snippet pinning
│   ├── ClipboardBarView.swift       # Quick paste strip & expandable clipboard drawer
│   └── Info.plist                   # Extension configuration (RequestsOpenAccess = YES)
│
└── .github/workflows/
    └── build.yml                 # CI syntax & build verification
```

---

## Getting Started

1. Open the project in **Xcode 15+**.
2. Select your development team under **Signing & Capabilities** for both targets.
3. Enable the App Group `group.com.ioskeyboard.app` on both targets.
4. Run the `KeyboardApp` scheme on an iOS 16+ Simulator or connected device.
5. In iOS **Settings > General > Keyboard > Keyboards**, add **Custom Keyboard** and enable **Allow Full Access**.
