import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Drop-in analytics SDK for iOS games.
///
/// Usage:
/// ```swift
/// // In your @main App or AppDelegate:
/// GameAnalytics.configure(apiKey: "your-key", endpoint: "https://your-api.com")
///
/// // Track events anywhere:
/// GameAnalytics.sessionStart()
/// GameAnalytics.levelStart(1)
/// GameAnalytics.track("power_up_collected", properties: ["type": "shield"])
/// ```
public final class GameAnalytics {
    private static let shared = GameAnalytics()

    private var apiKey: String?
    private var ingestURL: URL?
    private let queue = EventQueue()
    private let client = APIClient()
    private var flushTask: Task<Void, Never>?

    private static let playerIdKey = "ga_sdk_player_id"

    private init() {
        observeBackground()
    }

    // MARK: - Configuration

    public static func configure(apiKey: String, endpoint: String) {
        guard let base = URL(string: endpoint) else {
            assertionFailure("GameAnalytics: invalid endpoint URL '\(endpoint)'")
            return
        }
        shared.apiKey = apiKey
        shared.ingestURL = base.appendingPathComponent("ingest")
        shared.startFlushTimer()
    }

    // MARK: - Tracking

    public static func track(_ type: String, properties: [String: PropertyValue]? = nil) {
        guard shared.apiKey != nil else {
            print("[GameAnalytics] Call configure() before tracking events")
            return
        }
        let event = AnalyticsEvent(
            playerId: shared.playerId,
            type: type,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            properties: properties
        )
        Task { await shared.queue.enqueue(event) }
    }

    // MARK: - Convenience methods

    public static func sessionStart() {
        track("session_start")
    }

    public static func sessionEnd() {
        track("session_end")
    }

    public static func levelStart(_ level: Int) {
        track("level_start", properties: ["level": PropertyValue(level)])
    }

    public static func levelComplete(_ level: Int, score: Int? = nil) {
        var props: [String: PropertyValue] = ["level": PropertyValue(level)]
        if let score { props["score"] = PropertyValue(score) }
        track("level_complete", properties: props)
    }

    public static func levelFail(_ level: Int) {
        track("level_fail", properties: ["level": PropertyValue(level)])
    }

    // MARK: - Internal

    private var playerId: String {
        if let id = UserDefaults.standard.string(forKey: Self.playerIdKey) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: Self.playerIdKey)
        return id
    }

    private func startFlushTimer() {
        flushTask?.cancel()
        flushTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                await self?.flush()
            }
        }
    }

    private func observeBackground() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { await self?.flush() }
        }
        #endif
    }

    private func flush() async {
        guard let apiKey, let ingestURL else { return }
        let events = await queue.dequeue(max: 50)
        guard !events.isEmpty else { return }

        do {
            try await client.send(events: events, apiKey: apiKey, to: ingestURL)
        } catch {
            await queue.requeue(events)
        }
    }
}
