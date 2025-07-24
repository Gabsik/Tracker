import Foundation

final class StatsService {
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    init(trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
    }
    
    func calculateStats() -> [StatItem] {
        let trackers = trackerStore.fetchTrackers()
        let records = recordStore.fetchRecords()
        
        return [
            StatItem(number: bestStreak(records: records), title: "Лучший период"),
            StatItem(number: perfectDays(records: records, trackers: trackers), title: "Идеальные дни"),
            StatItem(number: totalCompleted(records: records), title: "Трекеров завершено"),
            StatItem(number: averagePerDay(records: records), title: "Среднее значение")
        ]
    }
    
    private func bestStreak(records: [TrackerRecord]) -> Int {
        let dates = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        var streak = 0
        var maxStreak = 0
        var prevDate: Date?
        
        for date in dates {
            if let prev = prevDate,
               Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prev)!) {
                streak += 1
            } else {
                streak = 1
            }
            maxStreak = max(maxStreak, streak)
            prevDate = date
        }
        return maxStreak
    }
    
    private func perfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let grouped = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        var perfectCount = 0
        
        for (date, dayRecords) in grouped {
            let calendarWeekday = Calendar.current.component(.weekday, from: date)
            guard let weekday = mapCalendarWeekdayToWeekday(calendarWeekday) else { continue }
            
            let scheduledTrackers = trackers.filter {
                $0.schedule?.contains(weekday) ?? false
            }
            
            let completedIDs = Set(dayRecords.map { $0.trackerID })
            
            if scheduledTrackers.allSatisfy({ completedIDs.contains($0.id) }) {
                perfectCount += 1
            }
        }
        
        return perfectCount
    }
    
    
    private func totalCompleted(records: [TrackerRecord]) -> Int {
        return records.count
    }
    
    private func averagePerDay(records: [TrackerRecord]) -> Int {
        let grouped = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        guard !grouped.isEmpty else { return 0 }
        return Int(round(Double(records.count) / Double(grouped.count)))
    }
    
    private func mapCalendarWeekdayToWeekday(_ value: Int) -> Weekday? {
        switch value {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
