
import AppMetricaCore

enum AppMetricaEvent {
    static func logOpen(screen: String) {
        AppMetrica.reportEvent(name: "analytics_event", parameters: [
            "event": "open",
            "screen": screen
        ])
        print("AppMetrica [open] screen: \(screen)")
    }

    static func logClose(screen: String) {
        AppMetrica.reportEvent(name: "analytics_event", parameters: [
            "event": "close",
            "screen": screen
        ])
        print("AppMetrica [close] screen: \(screen)")
    }

    static func logClick(screen: String, item: String) {
        AppMetrica.reportEvent(name: "analytics_event", parameters: [
            "event": "click",
            "screen": screen,
            "item": item
        ])
        print("AppMetrica [click] screen: \(screen), item: \(item)")
    }
}
