import UIKit
import UserNotifications

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    weak var router: DeeplinkRouter?

    func requestPermission() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("[LinkLabDemo] Notification permission granted: \(granted)")
        }
    }

    // Show notification banner even when app is in foreground
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

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[LinkLabDemo] Notification tapped: \(userInfo)")

        DispatchQueue.main.async { [weak self] in
            self?.router?.recordNotification(response.notification.request.content, userInfo: userInfo, tapped: true)

            // Route via deeplink if present in the payload
            if let deeplink = userInfo["deeplink"] as? String,
               let url = URL(string: deeplink) {
                self?.router?.handle(url)
            }
        }

        completionHandler()
    }
}
