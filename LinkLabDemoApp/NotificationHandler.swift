import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    /// Pending data from a notification tap that arrived before the router was connected.
    var pendingNotificationContent: UNNotificationContent?
    var pendingNotificationUserInfo: [AnyHashable: Any]?
    var pendingDeeplinkURL: URL?

    weak var router: DeeplinkRouter? {
        didSet { deliverPendingIfNeeded() }
    }

    // MARK: - Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set delegate BEFORE the system delivers any queued notification response
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("[LinkLabDemo] Notification permission granted: \(granted)")
        }
        return true
    }

    // MARK: - Foreground notification

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("[LinkLabDemo] Notification received in foreground: \(userInfo)")

        DispatchQueue.main.async { [weak self] in
            self?.router?.recordNotification(notification.request.content, userInfo: userInfo)
        }

        completionHandler([.banner, .badge, .sound])
    }

    // MARK: - Notification tap

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        let userInfo = content.userInfo
        print("[LinkLabDemo] Notification tapped: \(userInfo)")

        let deeplinkURL: URL?
        if let deeplink = userInfo["deeplink"] as? String {
            deeplinkURL = URL(string: deeplink)
        } else {
            deeplinkURL = nil
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let router = self.router {
                // Router is ready — deliver immediately
                router.recordNotification(content, userInfo: userInfo, tapped: true)
                if let url = deeplinkURL {
                    router.handle(url)
                }
            } else {
                // App is cold-launching — stash for later
                self.pendingNotificationContent = content
                self.pendingNotificationUserInfo = userInfo
                self.pendingDeeplinkURL = deeplinkURL
            }
        }

        completionHandler()
    }

    // MARK: - Deliver pending

    private func deliverPendingIfNeeded() {
        guard let router, let content = pendingNotificationContent, let userInfo = pendingNotificationUserInfo else { return }

        router.recordNotification(content, userInfo: userInfo, tapped: true)
        if let url = pendingDeeplinkURL {
            router.handle(url)
        }

        pendingNotificationContent = nil
        pendingNotificationUserInfo = nil
        pendingDeeplinkURL = nil
    }
}
