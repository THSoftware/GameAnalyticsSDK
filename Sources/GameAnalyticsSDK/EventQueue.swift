import Foundation

actor EventQueue {
    private var pending: [AnalyticsEvent] = []
    private let maxSize = 500

    func enqueue(_ event: AnalyticsEvent) {
        if pending.count >= maxSize { pending.removeFirst() }
        pending.append(event)
    }

    func dequeue(max count: Int) -> [AnalyticsEvent] {
        let batch = Array(pending.prefix(count))
        pending.removeFirst(min(count, pending.count))
        return batch
    }

    func requeue(_ events: [AnalyticsEvent]) {
        pending.insert(contentsOf: events, at: 0)
        if pending.count > maxSize {
            pending = Array(pending.prefix(maxSize))
        }
    }
}
