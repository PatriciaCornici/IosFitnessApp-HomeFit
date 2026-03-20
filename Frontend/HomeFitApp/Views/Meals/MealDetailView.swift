import SwiftUI

struct MealDetailView: View {
    let meal: MealCardModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var isSaved: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Async image
                AsyncImage(url: URL(string: meal.imageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

                // Save toggle
                HStack {
                    Spacer()
                    Button(action: toggleSaveMeal) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(.trailing)
                    }
                }

                // Meal information
                Text(meal.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.homefitTextDark)

                Group {
                    Text("Instructor: \(meal.instructorName)")
                    Text("Contact Info: \(meal.instructorEmail)")
                    Text("Calories: \(meal.calories)")
                    Text("Meal Type: \(meal.mealType)")
                    Text("Preparation Time: \(meal.preparationTime)")
                }

                Text("Ingredients:")
                    .font(.headline)
                ForEach(meal.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                }

                Group {
                    Text("Vegetarian: \(meal.isVegetarian ? "Yes" : "No")")
                    Text("Vegan: \(meal.isVegan ? "Yes" : "No")")
                    Text("High Protein: \(meal.isHighProtein ? "Yes" : "No")")
                    Text("Low Carb: \(meal.isLowCarb ? "Yes" : "No")")
                }

                Text("Description:")
                    .font(.headline)
                Text(meal.description)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Meal Details")
        .background(Color.homefitBackground)
        .onAppear {
            isSaved = userVM.savedMealIDs.contains(meal.id)
        }
    }

    private func toggleSaveMeal() {
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
    }
}

