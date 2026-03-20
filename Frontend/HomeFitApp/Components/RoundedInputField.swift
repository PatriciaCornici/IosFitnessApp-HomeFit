import SwiftUI

struct RoundedInputField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(Color.homefitInput)
                    .cornerRadius(12)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color.homefitInput)
                    .cornerRadius(12)
            }
        }
        .font(.system(size: 16))
        .autocapitalization(.none)
    }
}

