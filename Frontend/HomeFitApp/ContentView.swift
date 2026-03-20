import SwiftUI

struct ContentView: View {
    @AppStorage("accessToken") private var accessToken: String?
    @State private var isLoggedIn: Bool = false
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        Group {
            if isLoggedIn || accessToken != nil {
                UserMainView(isLoggedIn: $isLoggedIn)
            } else {
                NavigationStack {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .onAppear {
            isLoggedIn = accessToken != nil
        }
    }
}

