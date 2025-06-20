import Foundation
import CoreData

extension TrackerCategoryCoreData {
    func toTrackerCategory() -> TrackerCategory? {
        guard let title = self.title,
              let trackers = self.trackers as? Set<TrackerCoreData> else {
            return nil
        }

        let trackerModels = trackers.compactMap { $0.toTracker() }
        return TrackerCategory(title: title, trackers: trackerModels)
    }
}
