
import Foundation

enum TrackerFilter: CaseIterable {
    case all, today, completed, notCompleted
    
    var isCustomFilter: Bool {
        switch self {
        case .completed, .notCompleted: return true
        default: return false
        }
    }
    
    static var `default`: TrackerFilter {
        return .all
    }
    
    var title: String {
        switch self {
        case .all: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершённые"
        case .notCompleted: return "Незавершённые"
        }
    }
}
