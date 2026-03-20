import SwiftUI

struct SnackView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedFilter = "All"
    @State private var allMeals: [MealCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let filters = ["All", "Vegetarian", "Vegan", "High Protein", "Low Carb"]

    var filteredMeals: [MealCardModel] {
        allMeals
            .filter { $0.mealType.lowercased() == "snack" }
            .filter { meal in
                selectedFilter == "All" ||
                (selectedFilter == "Vegetarian" && meal.isVegetarian) ||
                (selectedFilter == "Vegan" && meal.isVegan) ||
                (selectedFilter == "High Protein" && meal.isHighProtein) ||
                (selectedFilter == "Low Carb" && meal.isLowCarb)
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CompactSegmentedPickerMeals(selection: $selectedFilter, options: filters)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)

                if isLoading {
                    ProgressView("Loading snacks...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else if filteredMeals.isEmpty {
                    Text("No snack meals found for \(selectedFilter).")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredMeals, id: \.id) { meal in
                            NavigationLink(destination: MealDetailView(meal: meal)) {
                                MealCard(meal: meal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Snacks")
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
            loadMeals()
            loadSavedMeals()
        }
    }

    private func loadMeals() {
        isLoading = true
        APIService.fetchMeals { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let meals):
                    self.allMeals = meals
                case .failure(let error):
                    self.errorMessage = "Failed to load meals: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadSavedMeals() {
        guard let token = userVM.token ?? UserDefaults.standard.string(forKey: "accessToken") else { return }

        APIService.fetchSavedMeals(token: token) { result in
            DispatchQueue.main.async {
                if case .success(let savedMeals) = result {
                    userVM.savedMealIDs = Set(savedMeals.map { $0.id })
                }
            }
        }
    }
}

