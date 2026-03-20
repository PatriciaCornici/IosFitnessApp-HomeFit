import SwiftUI

struct MyMealsView: View {
    @ObservedObject var userVM: UserViewModel
    @State private var meals: [MealCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading meals...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                        .padding()
                } else if meals.isEmpty {
                    Text("No meals found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(meals) { meal in
                        MealCard(meal: meal)
                            .environmentObject(userVM)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("My Meals")
        .background(Color.homefitBackground)
        .onAppear {
            if meals.isEmpty {
                fetchInstructorMeals()
            }
        }
    }

    private func fetchInstructorMeals() {
        isLoading = true
        APIService.fetchMeals { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let allMeals):
                    meals = allMeals.filter { $0.instructorEmail == userVM.userProfile.email }
                case .failure(let error):
                    errorMessage = "Failed to load meals: \(error.localizedDescription)"
                }
            }
        }
    }
}

