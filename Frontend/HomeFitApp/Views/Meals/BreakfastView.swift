import SwiftUI

struct BreakfastView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedFilter = "All"
    let filters = ["All", "Vegetarian", "Vegan", "High Protein", "Low Carb"]

    @State private var allMeals: [MealCardModel] = []
    @State private var isLoading = true

    var filteredMeals: [MealCardModel] {
        allMeals
            .filter { $0.mealType.lowercased() == "breakfast" }
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
                CompactSegmentedPicker(selection: $selectedFilter, options: filters)
                    .padding(.horizontal)
                    .padding(.top, 20)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if filteredMeals.isEmpty {
                    Text("No breakfast meals found for \(selectedFilter).")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
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
        .navigationTitle("Breakfast")
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
            if allMeals.isEmpty {
                loadMeals()
            }

            if let token = userVM.token {
                APIService.fetchSavedMeals(token: token) { result in
                    DispatchQueue.main.async {
                        if case .success(let savedMeals) = result {
                            userVM.savedMealIDs = Set(savedMeals.map { $0.id })
                        }
                    }
                }
            }
        }
    }

    private func loadMeals() {
        isLoading = true
        APIService.fetchMeals { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let meals) = result {
                    self.allMeals = meals
                }
            }
        }
    }
}

