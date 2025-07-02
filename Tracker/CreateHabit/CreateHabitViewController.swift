

import UIKit
import SnapKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory)
}

final class CreateHabitViewController: UIViewController {
    private let habitNameTextField = UITextField()
    private let containerView = UIView()
    private let categoryView = UIView()
    private let categoryLabel = UILabel()
    private let categoryArrow = UIImageView()
    private let separatorView = UIView()
    private let scheduleView = UIView()
    private let subtitlesScheduleLabel = UILabel()
    private let scheduleLabel = UILabel()
    private let scheduleArrow = UIImageView()
    private let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
    private let collectionEmoji = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionColor = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let cancelbutton = UIButton()
    private let createButton = UIButton()
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    weak var listVCDelegate: CreateHabitViewControllerDelegate?
    private var schedule: [Weekday] = []
    private let arryEmoji = [
        "🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"
    ]
    private let colorArray: [UIColor] = UIColor.trackersPalette
    
    private let categoryStore: TrackerCategoryStore
    private var selectedCategory: TrackerCategory?
    private let subtitlesCategoryLabel = UILabel()
    
    
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        settingUI()
        addView()
        addConstraints()
        collectionEmoji.dataSource = self
        collectionEmoji.delegate = self
        collectionColor.dataSource = self
        collectionColor.delegate = self
        habitNameTextField.delegate = self
        updateCreateButtonState()
        collectionEmoji.register(CreateHabitViewCollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionColor.register(ColorCollectionCell.self, forCellWithReuseIdentifier: "colorCell")
        collectionEmoji.register(HeaderReusableView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: "header")
        collectionColor.register(HeaderReusableView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: "header")
        collectionEmoji.isScrollEnabled = false
        collectionColor.isScrollEnabled = false
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
        habitNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //MARK: setting separatorView
        separatorView.backgroundColor = .grayCastom
        
        //MARK: setting containerView
        containerView.backgroundColor = .background
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        //MARK: setting category
        categoryLabel.text = "Категория"
        categoryLabel.textColor = .blackCastom
        categoryArrow.image = UIImage(named: "chevron")
        subtitlesCategoryLabel.textColor = .grayCastom
        subtitlesCategoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let tapGesturecategoryTapped = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryView.addGestureRecognizer(tapGesturecategoryTapped)
        
        //MARK: setting schedule
        scheduleLabel.text = "Расписание"
        scheduleLabel.textColor = .blackCastom
        scheduleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        scheduleArrow.image = UIImage(named: "chevron")
        scheduleArrow.tintColor = .gray
        subtitlesScheduleLabel.textColor = .grayCastom
        subtitlesScheduleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(habitNameTextField)
        contentView.addSubview(containerView)
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(categoryArrow)
        scheduleView.addSubview(scheduleLabel)
        scheduleView.addSubview(scheduleArrow)
        scheduleView.addSubview(subtitlesScheduleLabel)
        containerView.addSubview(categoryView)
        containerView.addSubview(separatorView)
        containerView.addSubview(scheduleView)
        
        contentView.addSubview(collectionEmoji)
        contentView.addSubview(collectionColor)
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(cancelbutton)
        stackView.addArrangedSubview(createButton)
        categoryView.addSubview(subtitlesCategoryLabel)
        
    }
    private func addConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(stackView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        habitNameTextField.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
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
            make.height.equalTo(1.0 / UIScreen.main.scale)
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
        
        subtitlesScheduleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(scheduleLabel.snp.bottom).offset(2)
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
        
        collectionEmoji.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(222)
        }
        
        collectionColor.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(collectionEmoji.snp.bottom).offset(32)
            make.height.equalTo(222)
            make.bottom.equalTo(contentView.snp.bottom).offset(-16)
        }
        subtitlesCategoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(categoryLabel.snp.bottom).offset(2)
        }
    }
    @objc private func categoryTapped() {
        let viewModel = CategoriesViewModel(categoryStore: categoryStore)
        let categoriesVC = CategoriesViewController(viewModel: viewModel)
        
        categoriesVC.onCategorySelected = { [weak self] selected in
            self?.selectedCategory = selected
            self?.subtitlesCategoryLabel.text = selected.title
            self?.updateCreateButtonState()
        }
        
        let navVC = UINavigationController(rootViewController: categoriesVC)
        present(navVC, animated: true)
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
        guard !schedule.isEmpty else {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Пожалуйста, выберите хотя бы один день для расписания.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let emoji = selectedEmoji else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, выберите эмоджи.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let color = selectedColor else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, выберите цвет.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let selectedCategory = selectedCategory else {
            let alert = UIAlertController(title: "Ошибка", message: "Выберите категорию.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
            return
        }
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: self.schedule,
            createdAt: Date()
        )
        
        listVCDelegate?.didCreateTracker(newTracker, in: selectedCategory)
        
        dismiss(animated: true, completion: nil)
    }
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    private func updateCreateButtonState() {
        let isNameFilled = !(habitNameTextField.text?.isEmpty ?? true)
        let isScheduleFilled = !schedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let isReady = isNameFilled && isScheduleFilled && isEmojiSelected && isColorSelected
        
        createButton.backgroundColor = isReady ? .blackCastom : .grayCastom
        createButton.isEnabled = isReady
    }
}

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday]) {
        print("Выбранные дни: \(days)")
        self.schedule = days
        let shortWeekdays = days.map { $0.shortForm() }
        subtitlesScheduleLabel.text = shortWeekdays.joined(separator: ", ")
        updateCreateButtonState()
    }
}

extension CreateHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionEmoji {
            return arryEmoji.count
        } else if collectionView == collectionColor {
            return colorArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionEmoji {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CreateHabitViewCollectionCell else {
                return UICollectionViewCell()
            }
            let emoji = arryEmoji[indexPath.row]
            cell.titleLabel.text = emoji
            
            if emoji == selectedEmoji {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                cell.layer.cornerRadius = 16
            } else {
                cell.backgroundColor = .clear
            }
            
            return cell
        } else if collectionView == collectionColor {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }
            let color = colorArray[indexPath.row]
            let isSelected = color == selectedColor
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "header",
                                                                     for: indexPath) as! HeaderReusableView
        if collectionView == collectionEmoji {
            header.titleLabel.text = "Emoji"
        } else if collectionView == collectionColor {
            header.titleLabel.text = "Цвета"
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionEmoji {
            selectedEmoji = arryEmoji[indexPath.item]
        } else if collectionView == collectionColor {
            selectedColor = colorArray[indexPath.item]
        }
        collectionView.reloadData()
        updateCreateButtonState()
    }
}

extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        habitNameTextField.resignFirstResponder()
        return true
    }
}
