
import UIKit
import SnapKit

final class CategoriesViewController: UIViewController {
    private let viewModel: CategoriesViewModel
    private let tableView = UITableView()
    private let addCategoryButton = UIButton()

    var onCategorySelected: ((TrackerCategory) -> Void)?

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
        addSubviews()
        setupConstraints()
        setupBindings()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)

        viewModel.fetchCategories()
    }

    private func setup() {
        view.backgroundColor = .white
        title = NSLocalizedString("categoryTitle", comment: "Заголовок выбора категории")

        tableView.separatorStyle = .none

        addCategoryButton.backgroundColor = .blackCastom
        addCategoryButton.layer.cornerRadius = 16
//        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitle(NSLocalizedString("addCategoryButtonTitle", comment: "Кнопка добавить категорию"), for: .normal)
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(addCategoryButton.snp.top)
        }

        addCategoryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(60)
        }
    }

    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updatePlaceholder(isEmpty: self.viewModel.isEmpty)
        }

        viewModel.onCategorySelected = { [weak self] selectedCategory in
            self?.onCategorySelected?(selectedCategory)
//            self?.dismiss(animated: true)
        }
    }

    @objc private func addButtonTapped() {
        let addVC = AddCategoriesViewController(store: viewModel.categoryStore)
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }

    private func updatePlaceholder(isEmpty: Bool) {
        if isEmpty {
            let placeholderView = UIView()

            let imageView = UIImageView(image: UIImage(named: "placeholder"))
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { $0.height.equalTo(80) }

            let label = UILabel()
            label.text = NSLocalizedString("categoryPlaceholder", comment: "Плейсхолдер при отсутствии категорий")
            label.textColor = .blackCastom
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textAlignment = .center
            label.numberOfLines = 2

            let stackView = UIStackView(arrangedSubviews: [imageView, label])
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.alignment = .center

            placeholderView.addSubview(stackView)
            placeholderView.frame = tableView.bounds

            stackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(32)
            }

            tableView.backgroundView = placeholderView
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }

        let category = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        cell.configure(with: category.title, isSelected: isSelected)

        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.numberOfCategories - 1
        cell.roundCorners(top: isFirst, bottom: isLast)
        cell.customSeparator.isHidden = isLast

        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
