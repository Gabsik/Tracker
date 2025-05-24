
import UIKit
import SnapKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        //setupNavigation()
        addView()
    }
    
    private func setup() {
        view.backgroundColor = .white
    }
    //    private func setupNavigation() {
    //        let image = UIImage(named: "plusButton")
    //        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
    //        navigationItem.leftBarButtonItem = addButton
    //    }
    //    @objc private func addButtonTapped() {
    //        print("Плюс нажали")
    //    }
    private let addTrackerButton: UIButton = {
        let image = UIImage(named: "plusButton")
        
        let button = UIButton()
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .blackCastom
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let dataButton: UIButton = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: Date())
        
        let button = UIButton()
        button.setTitle("\(formattedDate)", for: .normal)
        button.backgroundColor = UIColor(named: "lightGray")
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
//        label.text = "\(formattedDate)"
//        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        //label.backgroundColor = UIColor(named: "lightGray")
        return button
    }()
    
//    private let containerDataLabel: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(named: "lightGray")
//        view.layer.cornerRadius = 8
//        return view
//    }()
    
    private func addView() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        //view.addSubview(dataLabel)
        view.addSubview(addTrackerButton)
        view.addSubview(dataButton)
        constrtion()
    }
    
    private func constrtion() {
        addTrackerButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.leading.equalToSuperview().offset(6)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(addTrackerButton.snp.bottom).inset(1)
            make.leading.equalToSuperview().offset(16)
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(7)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            //make.leading.trailing.equalToSuperview().inset(16)
        }
        dataButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(49)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}

