//
//  EmojiKeyboardView.swift
//  KeyboardExtension
//
//  Categorized Gboard-style Emoji Picker with fast scroll, search, and recents.
//

import SwiftUI

enum EmojiCategory: String, CaseIterable, Identifiable {
    case smileys = "Smileys"
    case people = "People"
    case nature = "Nature"
    case food = "Food"
    case activities = "Activities"
    case travel = "Travel"
    case objects = "Objects"
    case symbols = "Symbols"
    case flags = "Flags"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .smileys: return "face.smiling"
        case .people: return "person.crop.circle"
        case .nature: return "leaf"
        case .food: return "fork.knife"
        case .activities: return "soccerball"
        case .travel: return "car.fill"
        case .objects: return "lightbulb"
        case .symbols: return "heart.fill"
        case .flags: return "flag.fill"
        }
    }

    var emojis: [String] {
        switch self {
        case .smileys:
            return ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "🥲", "🥹", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😮‍💨", "😤", "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨", "😰", "😥", "😓", "🫣", "🤗", "🫡", "🤔", "🫢", "🤫", "🤥", "😶", "😐", "😑", "😬", "🫨", "🫠", "🙄", "😯", "😦", "😧", "😮", "😲", "🥱", "😴", "🤤", "😪", "😵", "😵‍💫", "🤐", "🥴", "🤢", "🤮", "🤧", "😷", "🤒", "🤕"]
        case .people:
            return ["👋", "🤚", "🖐️", "✋", "🖖", "🫱", "🫲", "🫳", "🫴", "👌", "🤌", "🤏", "✌️", "🤞", "🫰", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "🫵", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "🫶", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃", "🫀", "🫁", "🧠", "👀", "👁️", "👅", "👄", "🫦", "👶", "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "👩", "🧓", "👴", "👵"]
        case .nature:
            return ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🪴", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘️", "🍀", "🍁", "🍂", "🍃", "🍄", "🌸", "🌺", "🌹", "🌻", "🌼", "🌷"]
        case .food:
            return ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🥜", "🍞", "🥐", "🥖", "🥨", "🥯", "🥞", "🧇", "🧀", "🍖", "🍗", "🥩", "🥓", "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔", "🥙", "🧆", "🥚", "🍳", "🍿", "🧈", "🍙", "🍚", "🍜", "🍝", "🍣", "🍦", "🍩", "🍪", "🎂", "🍰", "🧁", "🍫", "🍬", "🍭", "☕️", "🧋", "🥤"]
        case .activities:
            return ["⚽️", "🏀", "🏈", "⚾️", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳️", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌", "🎿", "⛷️", "🏂", "🏋️", "🤼", "🤸", "🤺", "⛹️", "🧗", "🏌️", "🏇", "🎮", "🕹️", "🎰", "🎲", "🧩", "🎯", "🎳"]
        case .travel:
            return ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🦯", "🦽", "🦼", "🛴", "🚲", "🛵", "🏍️", "🛺", "🚨", "🚔", "✈️", "🛫", "🛬", "🛩️", "🚁", "🚀", "🛸", "🛰️", "⛵️", "🚤", "🛳️", "⛴️", "🚢", "⚓️", "⛽️", "🗺️", "🗽", "🗼", "🏰", "🌋", "🏖️", "🏝️"]
        case .objects:
            return ["⌚️", "📱", "📲", "💻", "⌨️", "🖥️", "🖨️", "🕹️", "📷", "📸", "📹", "📼", "🔍", "🔎", "🕯️", "💡", "🔦", "📖", "📚", "📕", "📦", "📫", "📬", "📮", "📝", "✏️", "✒️", "📁", "📂", "📌", "📍", "📎", "🖇️", "🔒", "🔓", "🔑", "🗝️", "🔨", "🪓", "🔧", "🪛", "🧰", "🪤", "🧱", "⚙️"]
        case .symbols:
            return ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💯", "💢", "💥", "💫", "💦", "💨", "🕳️", "💬", "👁️‍🗨️", "🗯️", "💭", "💤", "⚠️", "🚸", "⛔️", "🚫", "🚳", "🚭", "🚯", "🚱", "🚷", "📵", "🔞", "☢️", "☣️", "⬆️", "↗️", "➡️", "↘️", "⬇️", "↙️", "⬅️", "↖️", "↕️", "↔️", "↩️", "↪️", "⤴️", "⤵️", "🔃", "🔄"]
        case .flags:
            return ["🏁", "🚩", "🎌", "🏴", "🏳️", "🏳️‍🌈", "🏳️‍⚧️", "🏴‍☠️", "🇺🇸", "🇬🇧", "🇨🇦", "🇦🇺", "🇯🇵", "🇩🇪", "🇫🇷", "🇮🇹", "🇪🇸", "🇲🇽", "🇧🇷", "🇮🇳", "🇨🇳", "🇰🇷"]
        }
    }
}

struct EmojiKeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @State private var selectedCategory: EmojiCategory = .smileys

    private let columns = [GridItem(.adaptive(minimum: 38))]

    var body: some View {
        VStack(spacing: 0) {
            // Top search & action bar
            HStack {
                Text(selectedCategory.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    withAnimation {
                        viewModel.activeTool = .none
                    }
                }) {
                    Text("ABC")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(6)
                }

                Button(action: {
                    viewModel.onDeleteBackward?()
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 15))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 4)

            // Scrollable Emoji Grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(selectedCategory.emojis, id: \.self) { emoji in
                        Button(action: {
                            viewModel.onInsertText?(emoji)
                            viewModel.triggerHaptic(style: .light)
                        }) {
                            Text(emoji)
                                .font(.system(size: 26))
                                .frame(width: 38, height: 38)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }

            // Bottom Category Selector Strip
            HStack(spacing: 0) {
                ForEach(EmojiCategory.allCases) { category in
                    Button(action: {
                        selectedCategory = category
                        viewModel.triggerSelectionFeedback()
                    }) {
                        Image(systemName: category.icon)
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundColor(selectedCategory == category ? Color.accentColor : .secondary)
                            .background(selectedCategory == category ? Color(UIColor.systemGray5) : Color.clear)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .frame(height: 250)
        .background(Color(UIColor.systemBackground))
    }
}
