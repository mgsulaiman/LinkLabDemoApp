import SwiftUI

enum DeeplinkDestination: Hashable {
    case home
    case profile(id: String)
    case settings
    case product(id: String)
    case search(query: String)
    case offer(code: String)
    case unknown(url: String)
}

@MainActor
final class DeeplinkRouter: ObservableObject {
    @Published var currentDestination: DeeplinkDestination = .home
    @Published var navigationId: UUID = UUID()
    @Published var deeplinkHistory: [(date: Date, url: String, destination: String)] = []

    func handle(_ url: URL) {
        let destination = parse(url)
        currentDestination = destination
        navigationId = UUID()
        deeplinkHistory.insert((date: Date(), url: url.absoluteString, destination: "\(destination)"), at: 0)
        if deeplinkHistory.count > 50 { deeplinkHistory.removeLast() }
    }

    private func parse(_ url: URL) -> DeeplinkDestination {
        let host = url.host ?? ""
        let path = url.path
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
