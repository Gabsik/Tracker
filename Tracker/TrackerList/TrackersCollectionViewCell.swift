import UIKit
import SnapKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func trackersCollectionViewCellDidTapCheckMark(_ cell: TrackersCollectionViewCell)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    let titleEmojiesLabel = UILabel()
    let nameLabel = UILabel()
    let containerView = UIView()
    let numberDaysLabel = UILabel()
    let checkMarkButton = UIButton()
    let containerButtonView = UIView()
    
    private var isCompletedToday: Bool = false
    private var daysCount: Int = 0
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var tracker: Tracker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleEmojiesLabel)
        containerView.addSubview(nameLabel)
        contentView.addSubview(containerButtonView)
        containerButtonView.addSubview(checkMarkButton)
        containerButtonView.addSubview(numberDaysLabel)
        
        containerButtonView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        numberDaysLabel.textColor = .black
        numberDaysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        numberDaysLabel.numberOfLines = 2
        
        let image = UIImage(named: "checkMarkButton")
        checkMarkButton.setImage(image, for: .normal)
        checkMarkButton.addTarget(self, action: #selector(checkMarkButtonTapped), for: .touchUpInside)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(58)
        }
        titleEmojiesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(12)
        }
        containerButtonView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).inset(0)
            make.trailing.equalToSuperview().inset(0)
            make.leading.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(44)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(12)
        }
        checkMarkButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(12)
        }
        numberDaysLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().offset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, daysCount: Int, isCompletedToday: Bool, isFutureDate: Bool) {
        nameLabel.text = tracker.title
        titleEmojiesLabel.text = tracker.emoji
        numberDaysLabel.text = "\(daysCount) дней"
        containerView.backgroundColor = tracker.color
        
        let imageName = isCompletedToday ? "readyButton" : "checkMarkButton"
        checkMarkButton.setImage(UIImage(named: imageName), for: .normal)
        
        checkMarkButton.isEnabled = !isFutureDate
        checkMarkButton.alpha = isFutureDate ? 0.3 : 1
    }
    
    @objc private func checkMarkButtonTapped() {
        delegate?.trackersCollectionViewCellDidTapCheckMark(self)
    }
    
    func update(isCompletedToday: Bool, daysCount: Int) {
        self.isCompletedToday = isCompletedToday
        self.daysCount = daysCount
        let buttonImageName = isCompletedToday ? "readyButton" : "checkMarkButton"
        checkMarkButton.setImage(UIImage(named: buttonImageName), for: .normal)
        numberDaysLabel.text = "\(daysCount) дней"
    }
}

