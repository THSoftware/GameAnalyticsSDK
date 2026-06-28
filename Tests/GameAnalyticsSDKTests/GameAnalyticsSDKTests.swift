import XCTest
@testable import GameAnalyticsSDK

final class EventQueueTests: XCTestCase {
    func testEnqueueAndDequeue() async {
        let q = EventQueue()
        let event = AnalyticsEvent(playerId: "p1", type: "session_start", timestamp: 1000, properties: nil)

        await q.enqueue(event)
        let batch = await q.dequeue(max: 10)

        XCTAssertEqual(batch.count, 1)
        XCTAssertEqual(batch[0].type, "session_start")
    }

    func testDequeueRespectsMax() async {
        let q = EventQueue()
        for i in 0..<10 {
            let e = AnalyticsEvent(playerId: "p1", type: "event_\(i)", timestamp: Int64(i), properties: nil)
            await q.enqueue(e)
        }

        let batch = await q.dequeue(max: 3)
        XCTAssertEqual(batch.count, 3)

        let remaining = await q.dequeue(max: 100)
        XCTAssertEqual(remaining.count, 7)
    }

    func testRequeuePutsEventsAtFront() async {
        let q = EventQueue()
        let original = AnalyticsEvent(playerId: "p1", type: "original", timestamp: 1, properties: nil)
        let newer = AnalyticsEvent(playerId: "p1", type: "newer", timestamp: 2, properties: nil)

        await q.enqueue(newer)
        await q.requeue([original])

        let batch = await q.dequeue(max: 2)
        XCTAssertEqual(batch[0].type, "original")
        XCTAssertEqual(batch[1].type, "newer")
    }

    func testQueueDropsOldestWhenFull() async {
        let q = EventQueue()
        for i in 0..<501 {
            let e = AnalyticsEvent(playerId: "p1", type: "event_\(i)", timestamp: Int64(i), properties: nil)
            await q.enqueue(e)
        }

        let batch = await q.dequeue(max: 500)
        XCTAssertEqual(batch.count, 500)
        XCTAssertEqual(batch[0].type, "event_1") // event_0 was dropped
    }
}

final class PropertyValueTests: XCTestCase {
    func testLiteralEncoding() throws {
        let encoder = JSONEncoder()

        struct Wrapper: Encodable {
            let v: PropertyValue
        }

        let intData = try encoder.encode(Wrapper(v: 42))
        XCTAssertEqual(String(data: intData, encoding: .utf8), "{\"v\":42}")

        let strData = try encoder.encode(Wrapper(v: "hello"))
        XCTAssertEqual(String(data: strData, encoding: .utf8), "{\"v\":\"hello\"}")

        let boolData = try encoder.encode(Wrapper(v: true))
        XCTAssertEqual(String(data: boolData, encoding: .utf8), "{\"v\":true}")
    }
}
