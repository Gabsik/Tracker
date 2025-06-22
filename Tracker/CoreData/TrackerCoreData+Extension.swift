import Foundation

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = self.id,
              let title = self.title,
              let colorHex = self.color as? String,
              let emoji = self.emoji else {
            return nil
        }

        let color = UIColorMarshalling.deserialize(colorHex)

        var schedule: [Weekday]? = nil
        if let raw = self.schedule as? [String] {
            schedule = raw.compactMap { Weekday(rawValue: $0) }
        }

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            createdAt: self.createdAt
        )
    }
}
