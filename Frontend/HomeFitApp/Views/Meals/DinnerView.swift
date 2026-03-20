import SwiftUI

struct DinnerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedFilter = "All"
    let filters = ["All", "Vegetarian", "Vegan", "High Protein", "Low Carb"]

    @State private var allMeals: [MealCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var filteredMeals: [MealCardModel] {
        allMeals
            .filter { $0.mealType.lowercased() == "dinner" }
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
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else if filteredMeals.isEmpty {
                    Text("No dinner meals found for \(selectedFilter).")
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
        .navigationTitle("Dinner")
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
                switch result {
                case .success(let meals):
                    self.allMeals = meals
                case .failure(let error):
                    self.errorMessage = "Failed to load meals: \(error.localizedDescription)"
                }
            }
        }
    }
}

