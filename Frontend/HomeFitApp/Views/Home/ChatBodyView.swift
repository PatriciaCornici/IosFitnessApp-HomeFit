import SwiftUI

struct ChatBodyView: View {
    @Binding var messages: [ChatMessage]
    @Binding var isAITyping: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser { Spacer() }

                            Text(message.text)
                                .padding(12)
                                .background(message.isUser ? Color.blue : Color.homefitInput)
                                .foregroundColor(message.isUser ? .white : Color.homefitTextDark)
                                .cornerRadius(16)
                                .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)
                                .padding(message.isUser ? .leading : .trailing, 40)

                            if !message.isUser { Spacer() }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if isAITyping {
                        HStack {
                            Text("Typing...")
                                .italic()
                                .foregroundColor(Color.homefitTextLight)
                                .padding(12)
                                .background(Color.homefitInput)
                                .cornerRadius(16)
                                .frame(maxWidth: 150, alignment: .leading)
                            Spacer()
                        }
                        .padding(.trailing, 40)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: messages) { _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
}

