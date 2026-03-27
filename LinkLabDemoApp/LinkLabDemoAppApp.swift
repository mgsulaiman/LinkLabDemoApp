import SwiftUI

@main
struct LinkLabDemoAppApp: App {
    @StateObject private var deeplinkRouter = DeeplinkRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deeplinkRouter)
                .onOpenURL { url in
                    deeplinkRouter.handle(url)
                }
                .onAppear {
                    NotificationHandler.shared.router = deeplinkRouter
                    NotificationHandler.shared.requestPermission()
                }
        }
    }
}
