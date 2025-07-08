
import UIKit
import SnapKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday])
}

final class ScheduleViewController: UIViewController {
    private let tableView = UITableView()
    private let readyButton = UIButton()
    let weekdays = Weekday.allCases
    private var selectedDays: [Weekday] = []
    weak var delegate: ScheduleViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        addView()
        setup()
        setupUI()
        addConstraints()
        tableView.register(ScheduleViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }
    
    private func setup() {
        title = NSLocalizedString("schedule_title", comment: "")
        view.backgroundColor = .white
    }
    private func addView() {
        view.addSubview(tableView)
        view.addSubview(readyButton)
    }
    private func setupUI() {
        //MARK: setting readyButton
//        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        readyButton.backgroundColor = .blackCastom
        readyButton.setTitleColor(.white, for: .normal)
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
    }
    private func addConstraints() {
        tableView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.bottom.equalToSuperview().inset(157)
        }
        readyButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(47)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    @objc private func readyButtonTapped() {
        delegate?.scheduleViewController(self, didSelectDays: selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ScheduleViewCell else {
            return UITableViewCell()
        }
        let weekday = weekdays[indexPath.row]
        let isSelected = selectedDays.contains(weekday)
        cell.delegate = self
        cell.configure(with: weekday.russianName, isSelected: isSelected)
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == weekdays.count - 1
        cell.roundCorners(top: isFirst, bottom: isLast)
        
        
        cell.customSeparator.isHidden = isLast
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ScheduleViewController: ScheduleViewCellDelegate {
    func scheduleViewCell(_ cell: ScheduleViewCell, didToggle isOn: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            let weekday = weekdays[indexPath.row]
            if isOn {
                if !selectedDays.contains(weekday) {
                    selectedDays.append(weekday)
                }
            } else {
                selectedDays.removeAll { $0 == weekday }
            }
        }
    }
}
