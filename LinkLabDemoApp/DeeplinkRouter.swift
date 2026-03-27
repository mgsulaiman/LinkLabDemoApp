import SwiftUI
import UserNotifications

enum DeeplinkDestination: Hashable {
    case home
    case profile(id: String)
    case settings
    case product(id: String)
    case search(query: String)
    case offer(code: String)
    case unknown(url: String)
}

struct NotificationEntry: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let body: String
    let deeplink: String?
    let tapped: Bool
    let payload: String
}

@MainActor
final class DeeplinkRouter: ObservableObject {
    @Published var currentDestination: DeeplinkDestination = .home
    @Published var navigationId: UUID = UUID()
    @Published var deeplinkHistory: [(date: Date, url: String, destination: String)] = []
    @Published var notificationHistory: [NotificationEntry] = []

    func handle(_ url: URL) {
        let destination = parse(url)
        currentDestination = destination
        navigationId = UUID()
        deeplinkHistory.insert((date: Date(), url: url.absoluteString, destination: "\(destination)"), at: 0)
        if deeplinkHistory.count > 50 { deeplinkHistory.removeLast() }
    }

    func recordNotification(_ content: UNNotificationContent, userInfo: [AnyHashable: Any], tapped: Bool = false) {
        let deeplink = userInfo["deeplink"] as? String
        let payloadString: String
        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            payloadString = str
        } else {
            payloadString = "\(userInfo)"
        }

        let entry = NotificationEntry(
            date: Date(),
            title: content.title,
            body: content.body,
            deeplink: deeplink,
            tapped: tapped,
            payload: payloadString
        )
        notificationHistory.insert(entry, at: 0)
        if notificationHistory.count > 50 { notificationHistory.removeLast() }
    }

    private func parse(_ url: URL) -> DeeplinkDestination {
        let host = url.host ?? ""
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        switch host {
        case "home":
            return .home
        case "profile":
            let id = url.pathComponents.dropFirst().first ?? queryItems.first(where: { $0.name == "id" })?.value ?? "unknown"
            return .profile(id: id)
        case "settings":
            return .settings
        case "product":
            let id = url.pathComponents.dropFirst().first ?? queryItems.first(where: { $0.name == "id" })?.value ?? "unknown"
            return .product(id: id)
        case "search":
            let query = queryItems.first(where: { $0.name == "q" })?.value ?? ""
            return .search(query: query)
        case "offer":
            let code = url.pathComponents.dropFirst().first ?? queryItems.first(where: { $0.name == "code" })?.value ?? ""
            return .offer(code: code)
        default:
            return .unknown(url: url.absoluteString)
        }
    }
}
