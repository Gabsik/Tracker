
import UIKit
import SnapKit

final class AddCategoriesViewController: UIViewController {
    private let textField = UITextField()
    private let readyButton = UIButton()
    private let store: TrackerCategoryStore
    
    init(store: TrackerCategoryStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addView()
        setting()
        сonstraints()
        setupActions()
        updateButtonState()
        textField.delegate = self
    }
    
    private func setup() {
        view.backgroundColor = .white
        title = NSLocalizedString("newCategoryTitle", comment: "Заголовок экрана создания категории")
    }
    
    private func setting() {
        //MARK: textField
        textField.backgroundColor = .background
        textField.layer.cornerRadius = 16
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("enterCategoryPlaceholder", comment: "Плейсхолдер поля ввода категории"),
            attributes: [
                .foregroundColor: UIColor.grayCastom,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        //MARK: readyButton
//        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitle(NSLocalizedString("doneButtonTitle", comment: "Кнопка Готово"), for: .normal)
        readyButton.layer.cornerRadius = 16
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        
    }
    
    private func addView() {
        view.addSubview(textField)
        view.addSubview(readyButton)
    }
    private func сonstraints() {
        textField.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.height.equalTo(75)
        }
        readyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(60)
        }
    }
    private func setupActions() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        let hasText = !(textField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        readyButton.isEnabled = hasText
        readyButton.backgroundColor = hasText ? .black : .gray
    }
    @objc private func readyButtonTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        
        try? store.addNewCategory(title: text)
        dismiss(animated: true)
    }
}

extension AddCategoriesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 38
    }
}
