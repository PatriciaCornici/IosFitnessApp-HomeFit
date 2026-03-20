import SwiftUI

struct UserMainView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var showMenu = false
    @Binding var isLoggedIn: Bool
    @State private var selectedMenu: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout Section
                        Text("Workouts")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.homefitTextDark)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            NavigationLink(destination: PilatesView()) {
                                FolderCard(title: "Pilates", imageName: "pilates")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: PowerPilatesView()) {
                                FolderCard(title: "Power Pilates", imageName: "power_pilates")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: StrengthPilatesView()) {
                                FolderCard(title: "Strength Pilates", imageName: "strength_pilates")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: YogaView()) {
                                FolderCard(title: "Yoga", imageName: "yoga")
                                    .frame(width: 100)
                            }
                        }
                        .padding(.horizontal)

                        // Meals Section
                        Text("Meals")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.homefitTextDark)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            NavigationLink(destination: BreakfastView()) {
                                FolderCard(title: "Breakfast", imageName: "breakfast")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: LunchView()) {
                                FolderCard(title: "Lunch", imageName: "lunch")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: DinnerView()) {
                                FolderCard(title: "Dinner", imageName: "dinner")
                                    .frame(width: 100)
                            }
                            NavigationLink(destination: SnackView()) {
                                FolderCard(title: "Snacks", imageName: "snack")
                                    .frame(width: 100)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 15)
                }
                .background(Color.homefitBackground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Home")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.homefitTextDark)
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation {
                                showMenu = true
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ProfileView(userVM: userVM)) {
                            Image("profile-image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    }
                }

                // Menu Navigation Links (unchanged)
                Group {
                    NavigationLink(destination: SavedWorkoutsView(), isActive: $selectedMenu.isEqual(to: "SavedWorkouts")) { EmptyView() }
                    NavigationLink(destination: SavedMealsView(), isActive: $selectedMenu.isEqual(to: "SavedMeals")) { EmptyView() }
                    NavigationLink(destination: AIAssistantChatView(), isActive: $selectedMenu.isEqual(to: "AIAssistant")) { EmptyView() }
                    NavigationLink(destination: MyWorkoutsView(userVM: userVM), isActive: $selectedMenu.isEqual(to: "MyWorkouts")) { EmptyView() }
                    
                    NavigationLink(destination: CreateWorkoutView(userVM: userVM), isActive: $selectedMenu.isEqual(to: "CreateWorkout")) { EmptyView() }
                    NavigationLink(destination: MyMealsView(userVM: userVM), isActive: $selectedMenu.isEqual(to: "MyMeals")) { EmptyView() }
                    NavigationLink(destination: CreateMealView(userVM: userVM), isActive: $selectedMenu.isEqual(to: "CreateMeal")) { EmptyView() }
                }

                // Dimmed background + Slide-in menu
                if showMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }

                    HStack {
                        MenuSheet(showMenu: $showMenu,
                                  selectedMenu: $selectedMenu,
                                  isLoggedIn: $isLoggedIn,
                                  userVM: userVM)
                            .frame(width: 250)
                            .background(.ultraThinMaterial)
                            .transition(.move(edge: .leading))

                        Spacer()
                    }
                    .zIndex(1)
                }
            }
        }
    }
}

// MARK: - Helper extension
extension Binding where Value == String? {
    func isEqual(to match: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.wrappedValue == match },
            set: { newValue in
                self.wrappedValue = newValue ? match : nil
            }
        )
    }
}

