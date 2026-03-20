import SwiftUI

struct MealCard: View {
    let meal: MealCardModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var isSaved: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: meal.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo").resizable().scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.headline)
                    .foregroundColor(.homefitTextDark)

                Text("\(meal.preparationTime) • \(meal.calories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                guard let token = userVM.token else { return }

                APIService.toggleSavedMeal(mealID: meal.id, token: token) { added in
                    DispatchQueue.main.async {
                        isSaved = added
                        if added {
                            userVM.savedMealIDs.insert(meal.id)
                        } else {
                            userVM.savedMealIDs.remove(meal.id)
                        }
                    }
                }
            }) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            isSaved = userVM.savedMealIDs.contains(meal.id)
        }
    }
}

