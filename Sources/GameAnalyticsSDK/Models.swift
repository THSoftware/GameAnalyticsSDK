import Foundation

/// A type-safe value that can be used in event properties.
/// Supports string, integer, double, and bool literals.
public struct PropertyValue: Encodable {
    private let _encode: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        _encode = { try value.encode(to: $0) }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

extension PropertyValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self.init(value) }
}

extension PropertyValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self.init(value) }
}

extension PropertyValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self.init(value) }
}

extension PropertyValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self.init(value) }
}

struct AnalyticsEvent: Encodable {
    let playerId: String
    let type: String
    let timestamp: Int64
    let properties: [String: PropertyValue]?

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case type, timestamp, properties
    }
}

struct IngestPayload: Encodable {
    let apiKey: String
    let events: [AnalyticsEvent]

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case events
    }
}
