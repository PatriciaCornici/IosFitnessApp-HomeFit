import SwiftUI

struct RoundedButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.homefitAccent)
                .foregroundColor(.black)
                .clipShape(Capsule()) // Full rounded button
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

