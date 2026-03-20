import SwiftUI

struct AIAssistantChatView: View {
    @State private var userInput: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "👋 Hello! I'm your AI Assistant. Ask me anything about fitness or nutrition.", isUser: false)
    ]
    @State private var isAITyping = false

    @ObservedObject private var keyboard = KeyboardResponder()

    var body: some View {
        VStack(spacing: 0) {
            ChatBodyView(messages: $messages, isAITyping: $isAITyping)

            Divider()

            HStack(spacing: 8) {
                TextField("Type your question...", text: $userInput)
                    .padding(12)
                    .background(Color.homefitInput)
                    .cornerRadius(20)
                    .foregroundColor(.homefitTextDark)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.homefitBackground)
            .padding(.bottom, keyboard.isKeyboardVisible ? 0 : 0) // Safe for now
        }
        .background(Color.homefitBackground)
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            hideKeyboard()
        }
    }

    func sendMessage() {
        guard !userInput.isEmpty else { return }

        messages.append(ChatMessage(text: userInput, isUser: true))
        let question = userInput
        userInput = ""

        isAITyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAITyping = false
            messages.append(ChatMessage(text: "That's a great question about \"\(question)\"! (Real AI response will come here)", isUser: false))
        }
    }
}

// Helper to hide keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

