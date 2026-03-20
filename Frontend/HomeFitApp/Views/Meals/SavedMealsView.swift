import SwiftUI

struct SavedMealsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedFilter = "Breakfast"
    @State private var savedMeals: [MealCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let filters = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var filteredMeals: [MealCardModel] {
        savedMeals.filter { $0.mealType == selectedFilter }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CompactSegmentedPicker(selection: $selectedFilter, options: filters)
                    .padding(.horizontal)
                    .padding(.top, 20)

                if isLoading {
                    ProgressView("Loading saved meals...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredMeals.isEmpty {
                    Text("No saved meals for this category.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredMeals, id: \.id) { meal in
                            NavigationLink(destination: MealDetailView(meal: meal)) {
                                MealCard(meal: meal).environmentObject(userVM)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Saved Meals")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.homefitBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            loadSavedMeals()
        }
    }

    private func loadSavedMeals() {
        guard let token = userVM.token ?? UserDefaults.standard.string(forKey: "accessToken") else {
            self.errorMessage = "Missing access token"
            self.isLoading = false
            return
        }

        APIService.fetchSavedMeals(token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let meals):
                    self.savedMeals = meals
                    userVM.savedMealIDs = Set(meals.map { $0.id })
                case .failure(let error):
                    self.errorMessage = "Failed to load meals: \(error.localizedDescription)"
                }
            }
        }
    }
}

