import SwiftUI

@main
struct LinkLabDemoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var deeplinkRouter = DeeplinkRouter()

    init() {
        SampleDefaults.seedIfNeeded()
    }

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

// MARK: - Sample UserDefaults

enum SampleDefaults {
    static func seedIfNeeded() {
        let defaults = UserDefaults.standard
        // Always refresh so values are present for testing
        // Strings
        defaults.set("user_42", forKey: "current_user_id")
        defaults.set("en", forKey: "app_language")
        defaults.set("https://api.example.com/v2", forKey: "api_base_url")
        defaults.set("abc123-token-xyz", forKey: "auth_token")

        // Bools
        defaults.set(true, forKey: "notifications_enabled")
        defaults.set(false, forKey: "dark_mode_override")
        defaults.set(true, forKey: "onboarding_completed")
        defaults.set(false, forKey: "analytics_opt_out")

        // Ints
        defaults.set(5, forKey: "app_launch_count")
        defaults.set(3, forKey: "failed_login_attempts")
        defaults.set(25, forKey: "items_per_page")
        defaults.set(1, forKey: "selected_tab_index")

        // Doubles
        defaults.set(37.7749, forKey: "last_latitude")
        defaults.set(-122.4194, forKey: "last_longitude")
        defaults.set(4.8, forKey: "user_rating")

        // Date
        defaults.set(Date(), forKey: "last_sync_date")

        // Data
        defaults.set("session-data-blob".data(using: .utf8)!, forKey: "cached_session")

        // Array
        defaults.set(["home", "profile", "search", "settings"], forKey: "recent_screens")
        defaults.set([101, 205, 342], forKey: "favorite_product_ids")

        // Dictionary
        defaults.set(["theme": "system", "font_size": "medium", "compact_mode": "false"], forKey: "display_preferences")
    }
}
