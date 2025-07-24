import UIKit
import SnapKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didSelect filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let filters = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter
    weak var delegate: FilterViewControllerDelegate?
    private let colors = Colors()
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        
        title = "Фильтры"
        addSubView()
        setupTableView()
    }
    
    private func addSubView() {
        view.addSubview(tableView)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = colors.tabelViewColor
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = filters[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        let isLast = indexPath.row == filters.count - 1
        let showCheckmark = filter.isCustomFilter && filter == selectedFilter
        cell.configure(with: filter.title, showCheckmark: showCheckmark, isLastCell: isLast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        delegate?.filterViewController(self, didSelect: filter)
        dismiss(animated: true)
    }
}
