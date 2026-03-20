import SwiftUI

struct CompactSegmentedPickerMeals: View {
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                        .font(.system(size: 12, weight: .medium)) // Smaller font
                        .foregroundColor(selection == option ? .white : .homefitTextDark)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            ZStack {
                                if selection == option {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.91, green: 0.86, blue: 0.81))
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                        )
                }
                .contentShape(Rectangle())
            }
        }
        .padding(5)
        .background(Color(red: 241/255, green: 234/255, blue: 227/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

