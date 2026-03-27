import SwiftUI

@main
struct LinkLabDemoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var deeplinkRouter = DeeplinkRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deeplinkRouter)
                .onOpenURL { url in
                    deeplinkRouter.handle(url)
                }
                .onAppear {
                    // Connect the router — also delivers any pending notification from cold launch
                    appDelegate.router = deeplinkRouter
                }
        }
    }
}
