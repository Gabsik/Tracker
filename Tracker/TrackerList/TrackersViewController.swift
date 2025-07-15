
import UIKit
import SnapKit
import AppMetricaCore

final class TrackersViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs: Set<UUID> = []
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let colors = Colors()
    private let filterButton = UIButton()
    private var currentDate: Date = Date() {
        didSet {
            updateCompletedTrackerIDs()
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    private var visibleCategories: [TrackerCategory] = []
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
    private var currentFilter: TrackerFilter = .default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets.top = 1
        setup()
        setupTopNavigationBar()
        addView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        updatePlaceholderVisibility()
        categories = categoryStore.fetchCategories()
        trackerStore.delegate = self
        let today = currentDate
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) {
            currentDate = tomorrow
            currentDate = today
        }
        updateVisibleCategories()
        completedTrackers = recordStore.fetchRecords()
        updateCompletedTrackerIDs()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logEvent(event: "open", screen: "Main")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logEvent(event: "close", screen: "Main")
    }
    private func logEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            parameters["item"] = item
        }
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters)
        print("AppMetrica LOG: \(parameters)")
    }

    
    private func setup() {
        view.backgroundColor = colors.viewBackgroundColor
    }
    private func setupTopNavigationBar() {
        // MARK:  Left button
        let image = UIImage(named: "plusButton")
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = colors.navigationBarButtonColor
        navigationItem.leftBarButtonItem = addButton
        
        //MARK: setting title
        title = NSLocalizedString("trackers_title", comment: "Заголовок экрана")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // MARK:  Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.viewBackgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        //MARK: setting searchController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "Плейсхолдер в поиске")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        
        //MARK: setting datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.backgroundColor = colors.datePickerBackgroundColor
        updateDatePickerTextColor(datePicker)
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        
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
        
        //MARK: setting filterButton
        filterButton.setTitle(NSLocalizedString("filter_button_title", comment: ""), for: .normal)
        filterButton.backgroundColor = .blueCastom
        filterButton.layer.cornerRadius = 16
        filterButton.addTarget(self, action: #selector(addFilterButtontapped), for: .touchUpInside)
    }
    
    @objc private func addFilterButtontapped() {
        logEvent(event: "click", screen: "Main", item: "filter")

        let vc = FilterViewController(selectedFilter: currentFilter)
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func addButtonTapped() {
        logEvent(event: "click", screen: "Main", item: "add_track")

        let trackerTypeSelectionVC = TrackerTypeSelectionViewController(categoryStore: categoryStore)
        trackerTypeSelectionVC.listVCDelegate = self
        trackerTypeSelectionVC.delegate = self
        trackerTypeSelectionVC.currentDate = self.currentDate
        let navController = UINavigationController(rootViewController: trackerTypeSelectionVC )
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateCompletedTrackerIDs()
        updateVisibleCategories(with: navigationItem.searchController?.searchBar.text ?? "")
    }
    
    private func addView() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(filterButton)
        сonstraints()
    }
    
    private func сonstraints() {
//        collectionView.snp.makeConstraints { make in
//            make.trailing.leading.equalToSuperview().inset(16)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(24)
//            make.bottom.equalToSuperview()
//        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // БЕЗ inset(24)
            make.leading.trailing.equalToSuperview().inset(16)
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
        filterButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.trailing.leading.equalToSuperview().inset(130)
            make.height.equalTo(50)
        }
    }
    private func updateCompletedTrackerIDs() {
        completedTrackerIDs = Set(completedTrackers
                                    .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                                    .map { $0.trackerID })
    }
    private func isTrackerVisible(_ tracker: Tracker) -> Bool {
        if let schedule = tracker.schedule {
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
            .first(where: { $0.trackerID == tracker.id }) {
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
//            completedTrackers.append(TrackerRecord(id: tracker.id, date: currentDate))
//            completedTrackerIDs.insert(tracker.id)
            let newRecord = TrackerRecord(id: UUID(), trackerID: tracker.id, date: currentDate)
            do {
                try recordStore.addRecord(newRecord) // ✅ сохранение в Core Data
                completedTrackers.append(newRecord)
                completedTrackerIDs.insert(tracker.id)
            } catch {
                print("Ошибка при сохранении записи трекера: \(error)")
            }
    }
    }
    
    private func getDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerID == tracker.id }.count
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
    
    private func updateVisibleCategories(with searchText: String = "") {
        let filtered: [TrackerCategory]
        
        if searchText.isEmpty {
            filtered = categories.map { category in
                let trackers = category.trackers.filter { tracker in
                    let visible = isTrackerVisible(tracker)
                    let matchFilter: Bool = {
                        switch currentFilter {
                        case .all, .today:
                            return true
                        case .completed:
                            return completedTrackerIDs.contains(tracker.id)
                        case .notCompleted:
                            return !completedTrackerIDs.contains(tracker.id)
                        }
                    }()
                    return visible && matchFilter
                }
                return TrackerCategory(title: category.title, trackers: trackers.sorted { $0.title < $1.title })
            }.filter { !$0.trackers.isEmpty }
        } else {
            filtered = categories.compactMap { category in
                let trackers = category.trackers.filter { tracker in
                    let visible = isTrackerVisible(tracker)
                    let matchFilter: Bool = {
                        switch currentFilter {
                        case .all, .today:
                            return true
                        case .completed:
                            return completedTrackerIDs.contains(tracker.id)
                        case .notCompleted:
                            return !completedTrackerIDs.contains(tracker.id)
                        }
                    }()
                    return visible && matchFilter && tracker.title.lowercased().contains(searchText.lowercased())
                }
                return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers.sorted { $0.title < $1.title })
            }
        }
        
        visibleCategories = filtered
        collectionView.reloadData()
        updatePlaceholderVisibility()
        filterButton.isHidden = categories.allSatisfy { $0.trackers.filter { isTrackerVisible($0) }.isEmpty }
    }
    
    
    func updateDatePickerTextColor(_ view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                label.textColor = UIColor { trait in
                    switch trait.userInterfaceStyle {
                    case .dark: return .black
                    default: return .label
                    }
                }
            }
            updateDatePickerTextColor(subview)
        }
    }
    private let recordStore: TrackerRecordStore = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        return TrackerRecordStore(context: context)
    }()

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
        logEvent(event: "click", screen: "Main", item: "track")

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        if currentDate > Date() { return }
        toggleCompletion(for: tracker)
        let isCompleted = completedTrackerIDs.contains(tracker.id)
        let daysCount = getDaysCount(for: tracker)
        cell.update(isCompletedToday: isCompleted, daysCount: daysCount)
    }
    
    func trackersCollectionViewCellDidRequestDelete(_ cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let alert = UIAlertController(title: "Уверены что хотите удалить трекер?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            try? self.trackerStore.deleteTracker(tracker)
            self.categories = self.categoryStore.fetchCategories()
            self.updateVisibleCategories()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
        
        logEvent(event: "click", screen: "Main", item: "delete")
    }
    
    func trackersCollectionViewCellDidRequestEdit(_ cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        guard let schedule = tracker.schedule else {
            let alert = UIAlertController(title: NSLocalizedString("edit_not_allowed_title", comment: "Редактирование невозможно"),
                                          message: NSLocalizedString("edit_not_allowed_message", comment: "Нерегулярное событие нельзя редактировать"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let completedCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        let createHabitVC = CreateHabitViewController(
            categoryStore: categoryStore,
            existingTracker: tracker,
            completedDaysCount: completedCount
        )
        
        createHabitVC.listVCDelegate = self
        let navVC = UINavigationController(rootViewController: createHabitVC)
        present(navVC, animated: true)
        logEvent(event: "click", screen: "Main", item: "edit")

    }
}

extension TrackersViewController: CreateHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory) {
        try? trackerStore.add(tracker, to: category)
        
        
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
        try? trackerStore.add(tracker, to: category)
        
        
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
        categories = categoryStore.fetchCategories()
        updateVisibleCategories(with: navigationItem.searchController?.searchBar.text ?? "")
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateVisibleCategories(with: searchController.searchBar.text ?? "")
    }
}

extension TrackersViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didSelect filter: TrackerFilter) {
        if filter == .today {
            currentDate = Date()
            datePicker.setDate(currentDate, animated: true)
        }
        
        currentFilter = filter
        updateCompletedTrackerIDs()
        updateVisibleCategories(with: navigationItem.searchController?.searchBar.text ?? "")
    }
}



