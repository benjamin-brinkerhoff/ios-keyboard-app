# Gboard-Style iOS Keyboard Application

A custom iOS keyboard extension and companion application implementing the core feature suite of **Google Gboard (Android)** for iOS, built with **SwiftUI** and **UIKit**.

---

## Features

- **Predictive Text & Suggestion Strip**: Trie-based lexicon prefix matching, bigram next-word model, and real-time word chips.
- **Hold for Symbol & Accent Popups**: Interactive callout bubbles over keys revealing numbers, punctuation, and accented characters.
- **Spacebar Cursor Trackpad**: Slide your finger across the spacebar to glide the cursor character-by-character.
- **Backspace Slide-to-Delete**: Swipe left from the backspace key to quickly delete full words.
- **Text Editing D-Pad Tool**: Directional arrows, document start/end jumps, selection mode, select all, cut, copy, and paste.
- **Dedicated Number Row**: Toggleable 1-0 numeric row above QWERTY.
- **One-Handed Mode**: Dock keyboard to left or right side with side rail controls.
- **Themes & Key Borders**: 7 Material You themes with AMOLED Dark, and toggleable key borders.
- **9-Category Emoji Keyboard**: Complete emoji catalog with fast category navigation.
- **Built-In Clipboard Manager & Back Tap Logging**: Quick paste strip, pinned snippets, App Group synchronization, and background Shortcut capture.

---

## Back Tap Shortcut Setup (Log Copies in Background)

Because iOS prevents apps from passively reading the clipboard when closed, this app includes a native **App Intent** (`SaveClipIntent`) that allows you to log copies in the background using Apple's **Back Tap** gesture:

### 1. Create the Shortcut in the iOS Shortcuts App
1. Open the **Shortcuts** app on your iPhone.
2. Tap the **`+`** icon in the top right to create a new shortcut.
3. Rename the shortcut to **"Save to Keyboard"**.
4. Tap **Add Action**, search for **"Save to Keyboard Clips"** (provided by `KeyboardApp`), and add it.
5. In the action parameter, tap **Text** and select **Clipboard** (or leave empty to default to current pasteboard).
6. Tap **Done**.

### 2. Link Shortcut to Back Tap
1. Open **Settings** on your iPhone.
2. Navigate to **Accessibility > Touch > Back Tap**.
3. Select **Double Tap** (or **Triple Tap**).
4. Scroll down to the *Shortcuts* section and select **"Save to Keyboard"**.

**Usage:** Whenever you copy text in Safari, Messages, Notes, or any app, simply double-tap the back of your phone. The shortcut runs headlessly in the background, writing the text directly into the keyboard's shared clip history without opening the app or keyboard.

---

## Building Unsigned IPA via GitHub Actions

This repository is configured with **XcodeGen** and a automated **GitHub Actions Workflow** (`.github/workflows/build.yml`) that compiles the application and extension and packages them into an unsigned `.ipa`.

### How to Download the Unsigned IPA:
1. Go to the **[Actions tab](../../actions)** in this GitHub repository.
2. Select the latest workflow run on the `main` branch (or trigger one via **Run workflow**).
3. Under the **Artifacts** section at the bottom of the summary page, download **`KeyboardApp-unsigned-ipa`**.
4. Extract the downloaded ZIP to get `KeyboardApp-unsigned.ipa`.
5. Install using your preferred sideloading tool:
   - **TrollStore** (permanently signed, full App Group support)
   - **AltStore / SideStore**
   - **Sideloadly**
   - **LiveContainer**

---

## Local Development with XcodeGen

To generate the `.xcodeproj` locally:
```bash
brew install xcodegen
xcodegen generate
open KeyboardApp.xcodeproj
```
