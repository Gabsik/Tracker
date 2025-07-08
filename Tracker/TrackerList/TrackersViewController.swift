
import UIKit
import SnapKit


final class TrackersViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs: Set<UUID> = []
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
    private let datePicker = UIDatePicker()
    private var currentDate: Date = Date() {
        didSet {
            updateCompletedTrackerIDs()
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    private var visibleCategories: [TrackerCategory] {
        categories.map { category in
            let visibleTrackers = category.trackers.filter { isTrackerVisible($0) }
            return TrackerCategory(title: category.title, trackers: visibleTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    private let trackerStore: TrackerStore = {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("Unable to get AppDelegate or its persistentContainer")
        }
        let context = appDelegate.persistentContainer.viewContext
        return TrackerStore(context: context)
    }()
    
    private let categoryStore: TrackerCategoryStore = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate or its persistentContainer")
        }
        let context = appDelegate.persistentContainer.viewContext
        return TrackerCategoryStore(context: context)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTopNavigationBar()
        addView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        updatePlaceholderVisibility()
        categories = categoryStore.fetchCategories()

//        categories = [
//            TrackerCategory(title: "Мои трекеры", trackers: trackerStore.fetchTrackers())
//        ]
        trackerStore.delegate = self
        let today = currentDate
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) {
            currentDate = tomorrow
            currentDate = today
        }
    }
    
    private func setup() {
        view.backgroundColor = .white
    }
    private func setupTopNavigationBar() {
        let image = UIImage(named: "plusButton")
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = addButton
        
        //MARK: setting title
        title = NSLocalizedString("trackers_title", comment: "Заголовок экрана")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        //MARK: setting searchController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "Плейсхолдер в поиске")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //MARK: setting datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        //MARK: setting placeholderImageView
        placeholderImageView.image = UIImage(named: "placeholder")
        placeholderImageView.contentMode = .scaleAspectFit
        
        //MARK: setting placeholderLabel
        placeholderLabel.text = NSLocalizedString("placeholder_text", comment: "Плейсхолдер, если нет трекеров")
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .blackCastom
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderImageView.isHidden = true
        placeholderLabel.isHidden = true
    }
    
    @objc private func addButtonTapped() {
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController(categoryStore: categoryStore)
        trackerTypeSelectionVC.listVCDelegate = self
        trackerTypeSelectionVC.delegate = self
        trackerTypeSelectionVC.currentDate = self.currentDate
        let navController = UINavigationController(rootViewController: trackerTypeSelectionVC )
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    private func addView() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        сonstraints()
    }
    
    private func сonstraints() {
        collectionView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(24)
            make.bottom.equalToSuperview()
        }
        placeholderImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(placeholderImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    private func updateCompletedTrackerIDs() {
        completedTrackerIDs = Set(completedTrackers
                                    .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                                    .map { $0.id })
    }
    private func isTrackerVisible(_ tracker: Tracker) -> Bool {
        if let schedule = tracker.schedule {
            // Привычка по расписанию
            let weekday = weekdayFromDate(currentDate)
            return schedule.contains(weekday)
        }
        guard let createdAt = tracker.createdAt else {
            return false
        }
        let currentDay = Calendar.current.startOfDay(for: currentDate)
        let createdDay = Calendar.current.startOfDay(for: createdAt)
        if currentDay < createdDay {
            return false
        }
        if let completion = completedTrackers
            .first(where: { $0.id == tracker.id }) {
            let completedDay = Calendar.current.startOfDay(for: completion.date)
            
            if currentDay > completedDay {
                return false
            }
        }
        return true
    }
    private func weekdayFromDate(_ date: Date) -> Weekday {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekday: Weekday
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: fatalError("Invalid weekday")
        }
        print("Сегодняшний день недели (в модели): \(weekday)")
        return weekday
    }
    
    private func addTracker(_ tracker: Tracker, to categoryName: String) {
        categories = categories.map { category in
            if category.title == categoryName {
                let newTrackers = category.trackers + [tracker]
                return TrackerCategory(title: category.title, trackers: newTrackers)
            } else {
                return category
            }
        }
        collectionView.reloadData()
    }
    
    private func toggleCompletion(for tracker: Tracker) {
        if completedTrackerIDs.contains(tracker.id) {
            completedTrackers.removeAll { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            completedTrackerIDs.remove(tracker.id)
        } else {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: currentDate))
            completedTrackerIDs.insert(tracker.id)
        }
    }
    
    private func getDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedTrackerIDs.contains(tracker.id)
        let daysCount = getDaysCount(for: tracker)
        let isFuture = currentDate > Date()
        cell.configure(with: tracker, daysCount: daysCount, isCompletedToday: isCompleted, isFutureDate: isFuture)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 12, height: 150)
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = visibleCategories[indexPath.section].title
        
        return header
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func trackersCollectionViewCellDidTapCheckMark(_ cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = categories[indexPath.section].trackers.filter { isTrackerVisible($0) }[indexPath.item]
        if currentDate > Date() { return }
        toggleCompletion(for: tracker)
        let isCompleted = completedTrackerIDs.contains(tracker.id)
        let daysCount = getDaysCount(for: tracker)
        cell.update(isCompletedToday: isCompleted, daysCount: daysCount)
    }
}

extension TrackersViewController: CreateHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory) {
        try? trackerStore.addNewTracker(tracker)

        if let index = categories.firstIndex(where: { $0.title == category.title }) {
            let old = categories[index]
            let updated = TrackerCategory(title: old.title, trackers: old.trackers + [tracker])
            categories[index] = updated
        } else {
            categories.append(TrackerCategory(title: category.title, trackers: [tracker]))
        }

        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: IrregularEventViewControllerDelegate {
    func didCreatedIrregularevent(_ tracker: Tracker, in category: TrackerCategory) {
        try? trackerStore.addNewTracker(tracker)
        
        if let index = categories.firstIndex(where: { $0.title == category.title }) {
            let old = categories[index]
            categories[index] = TrackerCategory(title: old.title, trackers: old.trackers + [tracker])
        } else {
            categories.append(TrackerCategory(title: category.title, trackers: [tracker]))
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate() {
//        categories = [
//            TrackerCategory(title: "Мои трекеры", trackers: trackerStore.fetchTrackers())
//        ]
        categories = categoryStore.fetchCategories()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

