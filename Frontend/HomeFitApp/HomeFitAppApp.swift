import SwiftUI

@main
struct HomeFitAppApp: App {
    @StateObject var userViewModel = UserViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
        }
    }
}

