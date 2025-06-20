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
    
//    func fetchTrackers() -> [Tracker] {
//        fetchedResultsController?.fetchedObjects?.compactMap { $0.toTracker() } ?? []
//    }
    func fetchTrackers() -> [Tracker] {
        let result = fetchedResultsController?.fetchedObjects?.compactMap { $0.toTracker() } ?? []
        print("Fetched trackers count: \(result.count)")
        return result
    }
    
    //    func addNewTracker(_ tracker: Tracker) throws {
    //        let entity = TrackerCoreData(context: context)
    //        entity.id = tracker.id
    //        entity.title = tracker.title
    //        entity.emoji = tracker.emoji
    //        entity.createdAt = tracker.createdAt
    //
    //        if let schedule = tracker.schedule {
    //            entity.schedule = schedule.map { $0.rawValue } as NSArray
    //        }
    //
    //        entity.color = UIColorMarshalling.serialize(tracker.color)
    //
    //        try context.save()
    //    }
    func addNewTracker(_ tracker: Tracker) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.emoji = tracker.emoji
        entity.createdAt = tracker.createdAt
        if let schedule = tracker.schedule {
            entity.schedule = schedule.map { $0.rawValue } as NSArray
        }
        entity.color = UIColorMarshalling.serialize(tracker.color)

        // Ищем или создаём категорию
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", "Мои трекеры")

        let categories = try context.fetch(request)
        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = "Мои трекеры"
        }

        // Привязываем категорию к трекеру
        entity.category = category

        try context.save()
    }

}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
