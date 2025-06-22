
import UIKit
import SnapKit

final class TrackerTypeSelectionViewController: UIViewController {
    let habitButton = UIButton()
    let irregularEventBitton = UIButton()
    let stackView = UIStackView()
    weak var listVCDelegate: CreateHabitViewControllerDelegate?
    weak var delegate: IrregularEventViewControllerDelegate?
    var currentDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        settingUI()
        addView()
        addConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .white
        title = "Создание трекера"
    }
    
    private func settingUI() {
        //MARK: settingHabitButton
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = .blackCastom
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(addHabitButtonTapped), for: .touchUpInside)
        
        //MARK: setting irregularEventBitton
        irregularEventBitton.setTitle("Нерегулярное Событие", for: .normal)
        irregularEventBitton.backgroundColor = .blackCastom
        irregularEventBitton.layer.cornerRadius = 16
        irregularEventBitton.addTarget(self, action: #selector(addirregularEventButtonTapped), for: .touchUpInside)
        
        //MARK: settingstackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
    }
    
    private func addView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventBitton)
    }
    
    private func addConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        habitButton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        irregularEventBitton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    @objc private func addHabitButtonTapped() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.listVCDelegate = listVCDelegate
        let navController = UINavigationController(rootViewController: createHabitVC )
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func addirregularEventButtonTapped() {
        let irregularEventVC = IrregularEventViewController()
        irregularEventVC.delegate = delegate
        irregularEventVC.trackerDate = currentDate
        let navController = UINavigationController(rootViewController: irregularEventVC)
        present(navController, animated: true, completion: nil)
    }
}

extension TrackerTypeSelectionViewController: IrregularEventViewControllerDelegate {
    func didCreatedIrregularevent(_ tracker: Tracker) {
        delegate?.didCreatedIrregularevent(tracker) 
        self.dismiss(animated: true)
    }
}
