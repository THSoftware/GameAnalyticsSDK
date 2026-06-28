import Foundation

struct APIClient {
    enum APIError: Error {
        case badResponse(Int)
    }

    func send(events: [AnalyticsEvent], apiKey: String, to url: URL) async throws {
        let payload = IngestPayload(apiKey: apiKey, events: events)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        request.timeoutInterval = 10

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw APIError.badResponse(code)
        }
    }
}
