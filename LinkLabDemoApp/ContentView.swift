import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: DeeplinkRouter

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    destinationView
                        .id(router.navigationId)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: router.navigationId)

                    ScreenTimerView()
                        .id(router.navigationId)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // Deeplink history log
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 12))
                        Text("Deeplink History")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Text("\(router.deeplinkHistory.count)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.blue.opacity(0.15)))
                    }
                    .foregroundStyle(.secondary)

                    if router.deeplinkHistory.isEmpty {
                        Text("No deeplinks received yet. Send one from LinkLab!")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 8)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(Array(router.deeplinkHistory.enumerated()), id: \.offset) { _, entry in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 6, height: 6)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(entry.url)
                                                .font(.system(size: 11, design: .monospaced))
                                                .lineLimit(1)
                                            Text(entry.date.formatted(date: .omitted, time: .standard))
                                                .font(.system(size: 9))
                                                .foregroundStyle(.tertiary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(.ultraThinMaterial))
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }
                .padding(12)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("LinkLab Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch router.currentDestination {
        case .home:
            HomeScreen()
        case .profile(let id):
            ProfileScreen(userId: id)
        case .settings:
            SettingsScreen()
        case .product(let id):
            ProductScreen(productId: id)
        case .search(let query):
            SearchScreen(query: query)
        case .offer(let code):
            OfferScreen(code: code)
        case .unknown(let url):
            UnknownScreen(url: url)
        }
    }
}

// MARK: - Home

struct HomeScreen: View {
    @State private var appeared = false
    @State private var cardsAppeared = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.blue.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(100 + i * 40), height: CGFloat(100 + i * 40))
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(Double(i) * 0.15), value: appeared)
                }

                Image(systemName: "house.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.blue.gradient)
                    .scaleEffect(appeared ? 1 : 0)
                    .rotationEffect(.degrees(appeared ? 0 : -30))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
            }

            Text("Home")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

            Text("Welcome to the demo app")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

            // Animated cards
            HStack(spacing: 12) {
                ForEach(0..<3) { i in
                    let icons = ["star.fill", "heart.fill", "bolt.fill"]
                    let colors: [Color] = [.yellow, .pink, .orange]
                    VStack(spacing: 8) {
                        Image(systemName: icons[i])
                            .font(.system(size: 20))
                            .foregroundStyle(colors[i])
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 50, height: 6)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                    .scaleEffect(cardsAppeared ? 1 : 0.7)
                    .opacity(cardsAppeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + Double(i) * 0.1), value: cardsAppeared)
                }
            }
            .padding(.top, 10)

            Spacer()
        }
        .onAppear {
            appeared = true
            cardsAppeared = true
        }
    }
}

// MARK: - Profile

struct ProfileScreen: View {
    let userId: String
    @State private var appeared = false
    @State private var statsAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Avatar with ring animation
            ZStack {
                Circle()
                    .trim(from: 0, to: appeared ? 1 : 0)
                    .stroke(
                        AngularGradient(colors: [.purple, .blue, .pink, .purple], center: .center),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(appeared ? 0 : -90))
                    .animation(.easeInOut(duration: 0.8), value: appeared)

                Circle()
                    .fill(.purple.gradient.opacity(0.15))
                    .frame(width: 96, height: 96)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.purple.gradient)
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: appeared)
            }

            Text("Profile")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

            Text("User ID: \(userId)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(.purple.opacity(0.1)))
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.4).delay(0.5), value: appeared)

            // Stats row
            HStack(spacing: 24) {
                StatItem(value: "128", label: "Posts", appeared: $statsAppeared, delay: 0)
                StatItem(value: "2.4K", label: "Followers", appeared: $statsAppeared, delay: 0.1)
                StatItem(value: "891", label: "Following", appeared: $statsAppeared, delay: 0.2)
            }
            .padding(.top, 12)

            Spacer()
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                statsAppeared = true
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    @Binding var appeared: Bool
    let delay: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .scaleEffect(appeared ? 1 : 0.5)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay), value: appeared)
    }
}

// MARK: - Product

struct ProductScreen: View {
    let productId: String
    @State private var appeared = false
    @State private var priceVisible = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Product image with bounce
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.orange.gradient.opacity(0.12))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(appeared ? 0 : 12))
                    .scaleEffect(appeared ? 1 : 0.6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: appeared)

                Image(systemName: "bag.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.orange.gradient)
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: appeared)
            }

            Text("Product")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

            Text("ID: \(productId)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.secondary)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.3), value: appeared)

            // Price tag animation
            HStack(spacing: 8) {
                Text("$99.99")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                Text("$149.99")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .strikethrough()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.orange.opacity(0.08))
            )
            .scaleEffect(priceVisible ? 1 : 0.3)
            .opacity(priceVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5), value: priceVisible)

            // Add to cart button
            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(.orange.gradient))
            }
            .scaleEffect(priceVisible ? 1 : 0)
            .opacity(priceVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.7), value: priceVisible)

            Spacer()
        }
        .onAppear {
            appeared = true
            priceVisible = true
        }
    }
}

// MARK: - Search

struct SearchScreen: View {
    let query: String
    @State private var appeared = false
    @State private var resultsAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Magnifying glass with pulse
            ZStack {
                Circle()
                    .fill(.green.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .scaleEffect(appeared ? 1.1 : 0.8)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: appeared)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.green.gradient)
                    .scaleEffect(appeared ? 1 : 0)
                    .rotationEffect(.degrees(appeared ? 0 : -45))
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: appeared)
            }

            Text("Search")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: appeared)

            // Search bar mock
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.tertiary)
                Text(query.isEmpty ? "Empty search" : query)
                    .foregroundStyle(query.isEmpty ? .tertiary : .primary)
                Spacer()
            }
            .font(.system(size: 14))
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.green.opacity(0.3), lineWidth: 1.5))
            )
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

            // Fake results
            VStack(spacing: 8) {
                ForEach(0..<3) { i in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.green.opacity(0.4))
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(width: CGFloat.random(in: 80...150), height: 10)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.secondary.opacity(0.08))
                                .frame(width: CGFloat.random(in: 60...120), height: 8)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                    .offset(x: resultsAppeared ? 0 : 60)
                    .opacity(resultsAppeared ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.5 + Double(i) * 0.12), value: resultsAppeared)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            appeared = true
            resultsAppeared = true
        }
    }
}

// MARK: - Settings

struct SettingsScreen: View {
    @State private var appeared = false

    let items: [(icon: String, label: String, color: Color)] = [
        ("person.fill", "Account", .blue),
        ("bell.fill", "Notifications", .red),
        ("lock.fill", "Privacy", .green),
        ("paintbrush.fill", "Appearance", .purple),
        ("globe", "Language", .orange),
        ("info.circle.fill", "About", .gray),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            ZStack {
                Circle()
                    .fill(.gray.gradient.opacity(0.1))
                    .frame(width: 90, height: 90)
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)

                Image(systemName: "gearshape.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.gray.gradient)
                    .rotationEffect(.degrees(appeared ? 0 : -180))
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.5), value: appeared)
            }
            .padding(.top, 30)

            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: appeared)

            // Settings rows
            VStack(spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: 7).fill(item.color.gradient))

                        Text(item.label)
                            .font(.system(size: 15))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                    .offset(x: appeared ? 0 : -50)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3 + Double(i) * 0.08), value: appeared)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Offer

struct OfferScreen: View {
    let code: String
    @State private var appeared = false
    @State private var confetti = false

    var body: some View {
        ZStack {
            // Background confetti particles
            ForEach(0..<12) { i in
                let colors: [Color] = [.red, .yellow, .green, .blue, .pink, .orange]
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                    .offset(
                        x: confetti ? CGFloat.random(in: -160...160) : 0,
                        y: confetti ? CGFloat.random(in: -300...300) : 0
                    )
                    .opacity(confetti ? 0 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.0...2.0)).delay(Double.random(in: 0...0.3)),
                        value: confetti
                    )
            }

            VStack(spacing: 16) {
                Spacer()

                // Tag icon with bounce
                ZStack {
                    Circle()
                        .fill(.red.gradient.opacity(0.12))
                        .frame(width: 110, height: 110)
                        .scaleEffect(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: appeared)

                    Image(systemName: "tag.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.red.gradient)
                        .scaleEffect(appeared ? 1 : 0)
                        .rotationEffect(.degrees(appeared ? -15 : 30))
                        .animation(.spring(response: 0.6, dampingFraction: 0.4).delay(0.15), value: appeared)
                }

                Text("Special Offer!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: appeared)

                // Discount badge
                Text("20% OFF")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(.red.gradient)
                            .shadow(color: .red.opacity(0.4), radius: 12, y: 6)
                    )
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.4), value: appeared)

                // Code
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .foregroundStyle(.red)
                    Text("Code: \(code)")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .foregroundStyle(.red.opacity(0.4))
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)

                Spacer()
            }
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confetti = true
            }
        }
    }
}

// MARK: - Unknown

struct UnknownScreen: View {
    let url: String
    @State private var appeared = false
    @State private var shaking = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(.secondary.opacity(0.5))
                .scaleEffect(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: appeared)
                .offset(x: shaking ? -6 : 0)
                .animation(
                    .linear(duration: 0.06)
                        .repeatCount(6, autoreverses: true)
                        .delay(0.5),
                    value: shaking
                )

            Text("Unknown Route")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: appeared)

            Text(url)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.3), value: appeared)

            Spacer()
        }
        .onAppear {
            appeared = true
            shaking = true
        }
    }
}

// MARK: - Screen Timer

struct ScreenTimerView: View {
    @State private var elapsed: TimeInterval = 0
    @State private var appeared = false
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.red)
                .frame(width: 7, height: 7)
                .opacity(elapsed.truncatingRemainder(dividingBy: 1.0) < 0.5 ? 1 : 0.3)

            Text(formattedTime)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
        .overlay(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 1))
        .scaleEffect(appeared ? 1 : 0.5)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: appeared)
        .onAppear { appeared = true }
        .onReceive(timer) { _ in
            elapsed += 0.01
        }
    }

    private var formattedTime: String {
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        let centiseconds = Int((elapsed * 100).truncatingRemainder(dividingBy: 100))
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}
