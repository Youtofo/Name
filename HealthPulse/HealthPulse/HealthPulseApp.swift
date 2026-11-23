import SwiftUI

@main
struct HealthPulseApp: App {
    @StateObject private var store = HealthStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
