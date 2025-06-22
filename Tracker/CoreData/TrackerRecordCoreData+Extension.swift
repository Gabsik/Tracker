
import Foundation

extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord? {
        guard let id = self.id,
              let date = self.date else {
                  return nil
              }
        return TrackerRecord(id: id, date: date)
    }
}
