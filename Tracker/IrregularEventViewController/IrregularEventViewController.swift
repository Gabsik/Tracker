
import SnapKit
import UIKit

protocol IrregularEventViewControllerDelegate: AnyObject {
    func didCreatedIrregularevent(_ tracker: Tracker, in category: TrackerCategory)
}

final class IrregularEventViewController: UIViewController {
    private let irregularEventTextField = UITextField()
    private let categoryView = UIView()
    private let categoryLabel = UILabel()
    private let categoryArrow = UIImageView()
    private let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
    private let cancelbutton = UIButton()
    private let createButton = UIButton()
    private let stackView = UIStackView()
    var trackerDate: Date = Date()
    private var selectedCategory: TrackerCategory?
    private let subtitlesCategoryLabel = UILabel()
    
    weak var delegate: IrregularEventViewControllerDelegate?
    
    private let viewModel: CategoriesViewModel
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
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
        updateCreateButtonState()
        irregularEventTextField.delegate = self
    }
    private func setup() {
        view.backgroundColor = .white
        title = NSLocalizedString("new_irregular_event", comment: "")
    }
    private func settingUI() {
        //MARK: setting irregularEventTextField
//        irregularEventTextField.placeholder = "Ведите название трекера"
        irregularEventTextField.placeholder = NSLocalizedString("enter_tracker_name", comment: "")
        irregularEventTextField.layer.cornerRadius = 16
        irregularEventTextField.backgroundColor = .background
        irregularEventTextField.borderStyle = .none
        irregularEventTextField.leftView = paddingView
        irregularEventTextField.leftViewMode = .always
        irregularEventTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //MARK: setting category
//        categoryLabel.text = "Категория"
        categoryLabel.text = NSLocalizedString("category", comment: "")
        categoryLabel.textColor = .blackCastom
        categoryArrow.image = UIImage(named: "chevron")
        let tapGesturecategoryTapped = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryView.addGestureRecognizer(tapGesturecategoryTapped)
        categoryView.backgroundColor = .background
        categoryView.layer.cornerRadius = 16
        categoryView.clipsToBounds = true
        subtitlesCategoryLabel.textColor = .grayCastom
        subtitlesCategoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        //MARK: setting buttonCancel
//        cancelbutton.setTitle("Отменить", for: .normal)
        cancelbutton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelbutton.setTitleColor(.redCastom, for: .normal)
        cancelbutton.backgroundColor = .white
        cancelbutton.layer.borderWidth = 1
        cancelbutton.layer.borderColor = UIColor.redCastom.cgColor
        cancelbutton.layer.cornerRadius = 16
        cancelbutton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        //MARK: setting createButton
//        createButton.setTitle("Создать", for: .normal)
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .grayCastom
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        //MARK: setting stackView
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
    }
    
    private func addView() {
        //view.addSubview(containerView)
        view.addSubview(irregularEventTextField)
        //containerView.addSubview(categoryView)
        view.addSubview(categoryView)
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(categoryArrow)
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(cancelbutton)
        stackView.addArrangedSubview(createButton)
        categoryView.addSubview(subtitlesCategoryLabel)
        
    }
    private func addConstraints() {
        irregularEventTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        
        categoryView.snp.makeConstraints { make in
            make.top.equalTo(irregularEventTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
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
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.height.equalTo(60)
        }
        subtitlesCategoryLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(16)
        }
    }
    @objc private func categoryTapped() {
        print("Категория нажата!")
        let categoriesVC = CategoriesViewController(viewModel: viewModel)
        
        categoriesVC.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
//            self?.categoryLabel.text = "Категория"
            self?.categoryLabel.text = NSLocalizedString("category", comment: "")
            self?.subtitlesCategoryLabel.text = category.title
            self?.updateCreateButtonState()
        }
        
        let nav = UINavigationController(rootViewController: categoriesVC)
        present(nav, animated: true)
    }
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func createTapped() {
        guard let title = irregularEventTextField.text, !title.isEmpty else {
            return
        }
        guard let category = selectedCategory else {
            let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("select_category", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
            return
        }
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: .systemBlue,
            emoji: "🙂",
            schedule: nil,
            createdAt: trackerDate
        )
        delegate?.didCreatedIrregularevent(newTracker, in: category)
        dismiss(animated: true, completion: nil)
    }
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    private func updateCreateButtonState() {
        let isNameFilled = !(irregularEventTextField.text?.isEmpty ?? true)
        let isReady = isNameFilled
        
        createButton.backgroundColor = isReady ? .blackCastom : .grayCastom
        createButton.isEnabled = isReady
    }
}

extension IrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        irregularEventTextField.resignFirstResponder()
        return true
    }
}
