import SwiftUI

@main
struct PuttingApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(store)
        }
    }
}
