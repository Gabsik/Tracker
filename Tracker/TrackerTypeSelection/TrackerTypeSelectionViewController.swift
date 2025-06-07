
import UIKit
import SnapKit

class TrackerTypeSelectionViewController: UIViewController {
    let habitButton = UIButton()
    let irregularEventBitton = UIButton()
    let stackView = UIStackView()
    weak var listVC: CreateHabitViewControllerDelegate?

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
        habitButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        //MARK: settingirregularEventBitton
        irregularEventBitton.setTitle("Нерегулярное Событие", for: .normal)
        irregularEventBitton.backgroundColor = .blackCastom
        irregularEventBitton.layer.cornerRadius = 16
        
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
    
    @objc private func addButtonTapped() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.listVC = listVC
        let navController = UINavigationController(rootViewController: createHabitVC )
        present(navController, animated: true, completion: nil)
    }
}
