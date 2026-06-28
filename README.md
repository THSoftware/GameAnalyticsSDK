# GameAnalyticsSDK

A lightweight, zero-dependency analytics SDK for iOS games. Drop it in, call three lines of code, and start seeing real player data in your dashboard.

- Batches and flushes events automatically every 30 seconds
- Flushes immediately when the app backgrounds
- Retries failed requests — no events dropped on a bad connection
- Generates and persists a stable anonymous player ID
- Thread-safe via Swift actors
- Zero external dependencies

## Requirements

- iOS 15+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**, then enter:

```
https://github.com/THSoftware/GameAnalyticsSDK
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/THSoftware/GameAnalyticsSDK", from: "1.0.0")
]
```

## Getting started

Sign up at **[thsoftwareltd.com](https://thsoftwareltd.com)** to get your API key, then add three lines to your app:

```swift
import GameAnalyticsSDK

@main
struct MyApp: App {
    init() {
        GameAnalytics.configure(
            apiKey: "your-api-key",
            endpoint: "https://your-endpoint.com"
        )
        GameAnalytics.sessionStart()
    }
    // ...
}
```

That's it. Events start flowing to your dashboard immediately.

## Tracking events

### Built-in convenience events

```swift
// Session lifecycle
GameAnalytics.sessionStart()
GameAnalytics.sessionEnd()

// Levels
GameAnalytics.levelStart(1)
GameAnalytics.levelComplete(1, score: 4200)
GameAnalytics.levelFail(1)
```

### Custom events with properties

```swift
GameAnalytics.track("power_up_collected", properties: [
    "type": "shield",
    "level": 3,
    "time_remaining": 42.5
])

GameAnalytics.track("iap_initiated", properties: [
    "product_id": "com.example.coins_500"
])
```

`PropertyValue` accepts `String`, `Int`, `Double`, and `Bool` via literal syntax — no casting required.

## How it works

Events are queued in memory and sent in batches of up to 50. The SDK flushes automatically:
- Every 30 seconds while the app is active
- Immediately when the app enters the background
- On the next launch if the previous flush failed (events are re-queued)

The queue holds up to 500 events. If the device is offline for an extended period, the oldest events are dropped to make room for new ones.

## License

MIT
