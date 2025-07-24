import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        fetchedResultsController = frc
    }
    
    func fetchTrackers() -> [Tracker] {
        let result = fetchedResultsController?.fetchedObjects?.compactMap { $0.toTracker() } ?? []
        print("Fetched trackers count: \(result.count)")
        return result
    }
    
    func add(_ tracker: Tracker, to category: TrackerCategory) throws {
            let entity = TrackerCoreData(context: context)
            entity.id = tracker.id
            entity.title = tracker.title
            entity.emoji = tracker.emoji
            entity.createdAt = tracker.createdAt
            if let schedule = tracker.schedule {
                entity.schedule = schedule.map { $0.rawValue } as NSArray
            }
            entity.color = UIColorMarshalling.serialize(tracker.color)

            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "title == %@", category.title)

            let fetched = try context.fetch(request)
            let categoryCoreData: TrackerCategoryCoreData

            if let existing = fetched.first {
                categoryCoreData = existing
            } else {
                categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.title = category.title
            }

            entity.category = categoryCoreData

            try context.save()
        }

    
    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let object = try context.fetch(request).first {
            context.delete(object)
            try context.save()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
