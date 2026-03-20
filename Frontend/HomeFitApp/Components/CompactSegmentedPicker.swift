import SwiftUI

struct CompactSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selection == option ? .white : .homefitTextDark)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selection == option {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.91, green: 0.86, blue: 0.81)) // #E7DACF
                                        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                                }
                            }
                        )
                }
                .contentShape(Rectangle())
            }
        }
        .padding(4)
        .background(Color(red: 241/255, green: 234/255, blue: 227/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

