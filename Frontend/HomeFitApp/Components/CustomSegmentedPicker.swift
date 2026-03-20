import SwiftUI

struct CustomSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                        .fontWeight(.medium)
                        .foregroundColor(selection == option ? .white : .homefitTextDark)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selection == option {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.91, green: 0.86, blue: 0.81)) // #E7DACF
                                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                }
                            }
                        )
                }
                .contentShape(Rectangle())
            }
        }
        .padding(6)
        .background(Color(red: 241/255, green: 234/255, blue: 227/255))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

