

import UIKit
import SnapKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    private let habitNameTextField = UITextField()
    private let containerView = UIView()
    private let categoryView = UIView()
    private let categoryLabel = UILabel()
    private let categoryArrow = UIImageView()
    private let separatorView = UIView()
    private let scheduleView = UIView()
    private let scheduleLabel = UILabel()
    private let scheduleArrow = UIImageView()
    private let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
    
    private let cancelbutton = UIButton()
    private let createButton = UIButton()
    
    private let stackView = UIStackView()
    weak var listVC: CreateHabitViewControllerDelegate?
    
    private var schedule: [Weekday] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        settingUI()
        addView()
        addConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .white
        title = "Новая привычка"
    }
    private func settingUI() {
        //MARK: setting habitNameTextField
        habitNameTextField.placeholder = "Ведите название трекера"
        habitNameTextField.layer.cornerRadius = 16
        habitNameTextField.backgroundColor = .background
        habitNameTextField.borderStyle = .none
        habitNameTextField.leftView = paddingView
        habitNameTextField.leftViewMode = .always
        
        //MARK: setting separatorView
        separatorView.backgroundColor = .lightGray
        
        //MARK: setting containerView
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        //MARK: setting category
        categoryLabel.text = "Категория"
        categoryLabel.textColor = .blackCastom
        categoryArrow.image = UIImage(named: "chevron")
        let tapGesturecategoryTapped = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryView.addGestureRecognizer(tapGesturecategoryTapped)
        
        //MARK: setting schedule
        scheduleLabel.text = "Расписание"
        scheduleLabel.textColor = .blackCastom
        scheduleArrow.image = UIImage(named: "chevron")
        scheduleArrow.tintColor = .gray
        let tapGesturescheduleTapped = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleView.addGestureRecognizer(tapGesturescheduleTapped)
        
        //MARK: setting stackView
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        //MARK: setting buttonCancel
        cancelbutton.setTitle("Отменить", for: .normal)
        cancelbutton.setTitleColor(.redCastom, for: .normal)
        cancelbutton.backgroundColor = .white
        cancelbutton.layer.borderWidth = 1
        cancelbutton.layer.borderColor = UIColor.redCastom.cgColor
        cancelbutton.layer.cornerRadius = 16
        cancelbutton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        //MARK: setting createButton
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .grayCastom
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    private func addView() {
        view.addSubview(containerView)
        view.addSubview(habitNameTextField)
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(categoryArrow)
        scheduleView.addSubview(scheduleLabel)
        scheduleView.addSubview(scheduleArrow)
        containerView.addSubview(categoryView)
        containerView.addSubview(separatorView)
        containerView.addSubview(scheduleView)
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(cancelbutton)
        stackView.addArrangedSubview(createButton)
        
    }
    private func addConstraints() {
        habitNameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(habitNameTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        categoryView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(75)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        categoryArrow.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        scheduleView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(75)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        scheduleArrow.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.height.equalTo(60)
        }
    }
    @objc private func categoryTapped() {
        print("Категория нажата!")
    }
    
    @objc private func scheduleTapped() {
        let scheduleVC = ScheduleViewController()
        let navController = UINavigationController(rootViewController: scheduleVC )
        scheduleVC.delegate = self
        present(navController, animated: true, completion: nil)
        print("Расписание нажато!")
    }
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func createTapped() {
        guard let title = habitNameTextField.text, !title.isEmpty else {
            return
        }
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: .systemBlue,
            emoji: "📌",
            schedule: self.schedule
        )
        
        listVC?.didCreateTracker(newTracker)
        dismiss(animated: true, completion: nil)
    }
}

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday]) {
        print("Выбранные дни: \(days)")
        self.schedule = days
    }
}
