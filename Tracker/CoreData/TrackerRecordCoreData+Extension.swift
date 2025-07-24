
import Foundation

extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord? {
        guard let id = self.id,
              let trackerID = self.trackerID,
              let date = self.date else {
                  return nil
              }
        return TrackerRecord(id: id, trackerID: trackerID, date: date)
    }
}
