//
//  KeyboardLayout.swift
//  KeyboardExtension
//
//  Defines keyboard structures, key actions, and alternate symbols popup data.
//

import SwiftUI

enum KeyboardLayer: String, Equatable {
    case letters
    case numbers
    case symbols
}

enum ShiftState: Equatable {
    case off
    case shifted
    case capsLock

    var isShifted: Bool {
        return self != .off
    }
}

enum KeyAction: Equatable {
    case character(String)
    case shift
    case backspace
    case switchLayer(KeyboardLayer)
    case space
    case returnKey
    case globe
    case dismiss
    case clipboardToggle
}

enum KeyType {
    case standard
    case modifier
    case action
}

struct KeyItem: Identifiable, Equatable {
    let id: String
    let label: String
    let action: KeyAction
    let alternates: [String]
    let widthRatio: CGFloat
    let keyType: KeyType

    init(
        id: String? = nil,
        label: String,
        action: KeyAction,
        alternates: [String] = [],
        widthRatio: CGFloat = 1.0,
        keyType: KeyType = .standard
    ) {
        self.id = id ?? label
        self.label = label
        self.action = action
        self.alternates = alternates
        self.widthRatio = widthRatio
        self.keyType = keyType
    }
}

struct KeyboardRow: Identifiable {
    let id = UUID()
    let keys: [KeyItem]
}

struct KeyboardLayout {
    static let alternateKeyMap: [String: [String]] = [
        // Top row letters -> numbers and symbols
        "q": ["1", "!", "œ"],
        "w": ["2", "@", "ŵ"],
        "e": ["3", "é", "è", "ê", "ë", "ē", "ė", "ę", "€"],
        "r": ["4", "#", "ř"],
        "t": ["5", "%", "þ", "ť"],
        "y": ["6", "^", "ý", "ÿ"],
        "u": ["7", "&", "û", "ü", "ù", "ú", "ū"],
        "i": ["8", "*", "î", "ï", "í", "ī", "į", "ì"],
        "o": ["9", "(", "ô", "ö", "ò", "ó", "œ", "ø", "ō", "õ"],
        "p": ["0", ")", "π"],

        // Middle row letters -> symbols and accents
        "a": ["@", "à", "á", "â", "ä", "æ", "ã", "å", "ā"],
        "s": ["$", "ß", "ś", "š"],
        "d": ["&", "ð", "ď"],
        "f": ["_"],
        "g": ["/"],
        "h": [":"],
        "j": [";"],
        "k": ["'"],
        "l": ["\""],

        // Bottom row letters -> punctuation and marks
        "z": ["*"],
        "x": ["-"],
        "c": ["ç", "ć", "č"],
        "v": ["+"],
        "b": ["="],
        "n": ["ñ", "ń"],
        "m": ["?", "!", ","],

        // Number keys alternates
        "1": ["1st", "¹", "½", "⅓", "¼"],
        "2": ["2nd", "²"],
        "3": ["3rd", "³", "¾"],
        "4": ["4th", "⁴"],
        "5": ["5th", "⅝"],
        "0": ["°", "∅"],

        // Symbol alternates
        "$": ["€", "£", "¥", "₩", "₽", "¢"],
        "-": ["–", "—", "•"],
        "/": ["\\"],
        "?": ["¿"],
        "!": ["¡"],
        "\"": ["“", "”", "„", "«", "»"],
        "'": ["‘", "’", "`"],
        "%": ["‰"]
    ]

    static func letterRows(shiftState: ShiftState) -> [KeyboardRow] {
        let isUpper = shiftState.isShifted

        let row1Keys = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"].map { char -> KeyItem in
            let display = isUpper ? char.uppercased() : char
            let rawAlts = alternateKeyMap[char] ?? []
            let alts = isUpper ? rawAlts.map { $0.count == 1 && $0.first?.isLetter == true ? $0.uppercased() : $0 } : rawAlts
            return KeyItem(label: display, action: .character(display), alternates: alts)
        }

        let row2Keys = ["a", "s", "d", "f", "g", "h", "j", "k", "l"].map { char -> KeyItem in
            let display = isUpper ? char.uppercased() : char
            let rawAlts = alternateKeyMap[char] ?? []
            let alts = isUpper ? rawAlts.map { $0.count == 1 && $0.first?.isLetter == true ? $0.uppercased() : $0 } : rawAlts
            return KeyItem(label: display, action: .character(display), alternates: alts)
        }

        var row3Keys: [KeyItem] = []
        row3Keys.append(
            KeyItem(
                id: "shift",
                label: shiftState == .capsLock ? "caps.fill" : (shiftState == .shifted ? "shift.fill" : "shift"),
                action: .shift,
                widthRatio: 1.4,
                keyType: .modifier
            )
        )
        for char in ["z", "x", "c", "v", "b", "n", "m"] {
            let display = isUpper ? char.uppercased() : char
            let rawAlts = alternateKeyMap[char] ?? []
            let alts = isUpper ? rawAlts.map { $0.count == 1 && $0.first?.isLetter == true ? $0.uppercased() : $0 } : rawAlts
            row3Keys.append(KeyItem(label: display, action: .character(display), alternates: alts))
        }
        row3Keys.append(
            KeyItem(
                id: "backspace",
                label: "delete.left",
                action: .backspace,
                widthRatio: 1.4,
                keyType: .modifier
            )
        )

        return [
            KeyboardRow(keys: row1Keys),
            KeyboardRow(keys: row2Keys),
            KeyboardRow(keys: row3Keys)
        ]
    }

    static func numberRows() -> [KeyboardRow] {
        let r1Chars = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let row1 = r1Chars.map { char in
            KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? [])
        }

        let r2Chars = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
        let row2 = r2Chars.map { char in
            KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? [])
        }

        var row3: [KeyItem] = [
            KeyItem(id: "to_symbols", label: "#+=", action: .switchLayer(.symbols), widthRatio: 1.4, keyType: .modifier)
        ]
        let r3Chars = [".", ",", "?", "!", "'"]
        for char in r3Chars {
            row3.append(KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? []))
        }
        row3.append(KeyItem(id: "backspace", label: "delete.left", action: .backspace, widthRatio: 1.4, keyType: .modifier))

        return [
            KeyboardRow(keys: row1),
            KeyboardRow(keys: row2),
            KeyboardRow(keys: row3)
        ]
    }

    static func symbolRows() -> [KeyboardRow] {
        let r1Chars = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
        let row1 = r1Chars.map { char in
            KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? [])
        }

        let r2Chars = ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"]
        let row2 = r2Chars.map { char in
            KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? [])
        }

        var row3: [KeyItem] = [
            KeyItem(id: "to_numbers", label: "123", action: .switchLayer(.numbers), widthRatio: 1.4, keyType: .modifier)
        ]
        let r3Chars = [".", ",", "?", "!", "'"]
        for char in r3Chars {
            row3.append(KeyItem(label: char, action: .character(char), alternates: alternateKeyMap[char] ?? []))
        }
        row3.append(KeyItem(id: "backspace", label: "delete.left", action: .backspace, widthRatio: 1.4, keyType: .modifier))

        return [
            KeyboardRow(keys: row1),
            KeyboardRow(keys: row2),
            KeyboardRow(keys: row3)
        ]
    }
}
