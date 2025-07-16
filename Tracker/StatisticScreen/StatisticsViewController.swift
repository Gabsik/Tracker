
import UIKit
import SnapKit

extension Notification.Name {
    static let trackerDataDidChange = Notification.Name("trackerDataDidChange")
}

final class StatisticsViewController: UIViewController {
    private let tableView = UITableView()
    private var stats: [StatItem] = []
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
    
    private lazy var statsService: StatsService = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to cast UIApplication delegate to AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        return StatsService(
            trackerStore: TrackerStore(context: context),
            recordStore: TrackerRecordStore(context: context)
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerDataDidChange),
            name: .trackerDataDidChange,
            object: nil
        )
    }
    
    private func setup() {
        title = NSLocalizedString("static_title", comment: "Заголовок экрана")
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(StatCell.self, forCellReuseIdentifier: "StatCell")
        
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        placeholderImageView.image = UIImage(named: "analizPlacholder")
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.isHidden = true
        
        
        placeholderLabel.text = NSLocalizedString("no_data_placeholder", comment: "Нет данных для отображения")
        placeholderLabel.textColor = .blackCastom
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.isHidden = true
        placeholderLabel.numberOfLines = 0
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        placeholderImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func fetchData() {
        stats = statsService.calculateStats()
        tableView.reloadData()
        
        let shouldShowPlaceholder = stats.allSatisfy { $0.number == 0 }
        
        tableView.isHidden = shouldShowPlaceholder
        placeholderImageView.isHidden = !shouldShowPlaceholder
        placeholderLabel.isHidden = !shouldShowPlaceholder
    }
    @objc private func handleTrackerDataDidChange() {
        fetchData()
    }
    deinit {
            NotificationCenter.default.removeObserver(self, name: .trackerDataDidChange, object: nil)
        }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath) as? StatCell else {
            return UITableViewCell()
        }
        
        let stat = stats[indexPath.row]
        cell.configure(number: stat.number, title: stat.title)
        return cell
    }
}


