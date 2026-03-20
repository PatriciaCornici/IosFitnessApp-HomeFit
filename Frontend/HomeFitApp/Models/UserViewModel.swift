import Foundation
import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var userProfile: UserProfile = UserProfile(
        id: 0,
        name: "",
        email: "",
        password: nil,
        profileImageName: nil,
        goal: nil,
        userType: .user
    )
    
    @Published var token: String?
    @Published var loginMessage: String = ""
    @Published var workoutListNeedsRefresh: Bool = false
    @Published var savedWorkoutIDs: Set<Int> = []
    @Published var savedMealIDs: Set<Int> = []

    // MARK: - Login
    func login(email: String, password: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        APIService.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    self.token = accessToken

                    APIService.fetchUserProfile(token: accessToken) { profileResult in
                        DispatchQueue.main.async {
                            switch profileResult {
                            case .success(let profile):
                                self.userProfile = profile
                                self.loginMessage = "Logged in as \(profile.userType.rawValue)"
                                onSuccess()
                            case .failure(let error):
                                self.loginMessage = "Failed to fetch profile: \(error.localizedDescription)"
                                onFailure(error)
                            }
                        }
                    }

                case .failure(let error):
                    self.loginMessage = "Login failed: \(error.localizedDescription)"
                    onFailure(error)
                }
            }
        }
    }

    // MARK: - Saved Meals Logic
    func isMealSaved(_ id: Int) -> Bool {
        return savedMealIDs.contains(id)
    }

    func toggleMealSaveState(mealID: Int) {
        guard let token = token else { return }

        APIService.toggleSavedMeal(mealID: mealID, token: token) { added in
            DispatchQueue.main.async {
                if added {
                    self.savedMealIDs.insert(mealID)
                } else {
                    self.savedMealIDs.remove(mealID)
                }
            }
        }
    }

    // MARK: - Saved Workouts Logic (Optional but useful)
    func isWorkoutSaved(_ id: Int) -> Bool {
        return savedWorkoutIDs.contains(id)
    }

    func toggleWorkoutSaveState(workoutID: Int) {
        guard let token = token else { return }

        APIService.toggleSavedWorkout(workoutID: workoutID, token: token) { added in
                DispatchQueue.main.async {
                    if added {
                        self.savedWorkoutIDs.insert(workoutID)
                    } else {
                        self.savedWorkoutIDs.remove(workoutID)
                    }
                }
            }
    }
}

