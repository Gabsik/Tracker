

import UIKit
import SnapKit

final class StatisticsViewController: UIViewController {
    private let tableView = UITableView()
    private var stats: [StatItem] = []
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
    
    private let statsService: StatsService = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return StatsService(
            trackerStore: TrackerStore(context: context),
            recordStore: TrackerRecordStore(context: context)
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchData()
        
        
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
            //            $0.width.height.equalTo(80)
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


