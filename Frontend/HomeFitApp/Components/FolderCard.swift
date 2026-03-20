import SwiftUI

struct FolderCard: View {
    let title: String
    let imageName: String

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.homefitTextDark)
                .padding(.top, 4)
        }
        .frame(width: 140)
    }
}

