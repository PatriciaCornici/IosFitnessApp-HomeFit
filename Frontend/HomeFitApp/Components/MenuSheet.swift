import SwiftUI

struct MenuSheet: View {
    @Binding var showMenu: Bool
    @Binding var selectedMenu: String?
    @Binding var isLoggedIn: Bool
    @ObservedObject var userVM: UserViewModel

    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)

            VStack {
                VStack(spacing: 20) {
                    Text("Menu")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.homefitTextDark)
                        .padding(.top, 100)
                    
                    VStack(spacing: 12) {
                        menuButton("Saved Workouts") {
                            selectedMenu = "SavedWorkouts"
                            withAnimation { showMenu = false }
                        }

                        menuButton("Saved Meals") {
                            selectedMenu = "SavedMeals"
                            withAnimation { showMenu = false }
                        }

                        // New AI Assistant button
                        menuButton("AI Assistant") {
                            selectedMenu = "AIAssistant"
                            withAnimation { showMenu = false }
                        }

                        // 🚀 Instructor-only buttons
                        if userVM.userProfile.userType == .instructor {
                            Divider()

                            menuButton("My Workouts") {
                                selectedMenu = "MyWorkouts"
                                withAnimation { showMenu = false }
                            }

                            menuButton("Create Workout") {
                                selectedMenu = "CreateWorkout"
                                withAnimation { showMenu = false }
                            }

                            menuButton("My Meals") {
                                selectedMenu = "MyMeals"
                                withAnimation { showMenu = false }
                            }

                            menuButton("Create Meal") {
                                selectedMenu = "CreateMeal"
                                withAnimation { showMenu = false }
                            }
                        }
                    }
                    .padding(.top, 75)

                    Spacer()

                    menuButton("Log Out") {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        isLoggedIn = false
                        withAnimation { showMenu = false }
                    }
                    .padding(.bottom, 80)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 220)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }

    func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.homefitBackground)
                .clipShape(Capsule())
        }
    }
}

