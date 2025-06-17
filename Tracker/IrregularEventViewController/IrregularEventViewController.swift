
import SnapKit
import UIKit

protocol IrregularEventViewControllerDelegate: AnyObject {
    func didCreatedIrregularevent(_ tracker: Tracker)
}

class IrregularEventViewController: UIViewController {
    private let irregularEventTextField = UITextField()
    private let categoryView = UIView()
    private let categoryLabel = UILabel()
    private let categoryArrow = UIImageView()
    private let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
    private let cancelbutton = UIButton()
    private let createButton = UIButton()
    private let stackView = UIStackView()
    var trackerDate: Date = Date()
    
    weak var delegate: IrregularEventViewControllerDelegate?
    
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
        title = "Новое нерегулярное событие"
    }
    private func settingUI() {
        //MARK: setting irregularEventTextField
        irregularEventTextField.placeholder = "Ведите название трекера"
        irregularEventTextField.layer.cornerRadius = 16
        irregularEventTextField.backgroundColor = .background
        irregularEventTextField.borderStyle = .none
        irregularEventTextField.leftView = paddingView
        irregularEventTextField.leftViewMode = .always
        irregularEventTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //MARK: setting category
        categoryLabel.text = "Категория"
        categoryLabel.textColor = .blackCastom
        categoryArrow.image = UIImage(named: "chevron")
        let tapGesturecategoryTapped = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryView.addGestureRecognizer(tapGesturecategoryTapped)
        categoryView.backgroundColor = .background
        categoryView.layer.cornerRadius = 16
        categoryView.clipsToBounds = true
        
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
    }
    @objc private func categoryTapped() {
        print("Категория нажата!")
    }
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func createTapped() {
        guard let title = irregularEventTextField.text, !title.isEmpty else {
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
        delegate?.didCreatedIrregularevent(newTracker)
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
