import UIKit
import SnapKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func trackersCollectionViewCellDidTapCheckMark(_ cell: TrackersCollectionViewCell)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private let titleEmojiesLabel = UILabel()
    private let nameLabel = UILabel()
    private let containerView = UIView()
    private let numberDaysLabel = UILabel()
    private let checkMarkButton = UIButton()
    private let containerButtonView = UIView()
    private let containerEmojiesView = UIView()
    private let overlayImageView = UIImageView()
    
    private var isCompletedToday: Bool = false
    private var daysCount: Int = 0
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    private var tracker: Tracker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        
        titleEmojiesLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        checkMarkButton.imageView?.contentMode = .scaleAspectFit
        
        containerEmojiesView.layer.cornerRadius = 12
        containerEmojiesView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        containerEmojiesView.clipsToBounds = true
        
        contentView.addSubview(containerView)
        containerView.addSubview(containerEmojiesView)
        containerEmojiesView.addSubview(titleEmojiesLabel)
        containerView.addSubview(nameLabel)
        contentView.addSubview(containerButtonView)
        containerButtonView.addSubview(checkMarkButton)
        containerButtonView.addSubview(numberDaysLabel)
        checkMarkButton.addSubview(overlayImageView)
        
        containerButtonView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        numberDaysLabel.textColor = .black
        numberDaysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        numberDaysLabel.numberOfLines = 2
        
        checkMarkButton.layer.cornerRadius = 17
        checkMarkButton.addTarget(self, action: #selector(checkMarkButtonTapped), for: .touchUpInside)
        
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.isUserInteractionEnabled = false
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(58)
        }
        containerEmojiesView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(12)
            
            make.size.equalTo(24)
        }
        titleEmojiesLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
            make.height.equalTo(34)
            make.width.equalTo(34)
        }
        numberDaysLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().offset(12)
        }
        overlayImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(11)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, daysCount: Int, isCompletedToday: Bool, isFutureDate: Bool) {
        self.tracker = tracker
        nameLabel.text = tracker.title
        titleEmojiesLabel.text = tracker.emoji
        numberDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "дней"),
            daysCount
        )
        containerView.backgroundColor = tracker.color
        
        let imageName = isCompletedToday ? "Property" : "checkMarkButton"
        checkMarkButton.setImage(UIImage(named: imageName), for: .normal)
        
        if isCompletedToday {
            let image = UIImage(named: "Property")?.withRenderingMode(.alwaysTemplate)
            checkMarkButton.setImage(image, for: .normal)
            checkMarkButton.tintColor = tracker.color
            checkMarkButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
            checkMarkButton.imageView?.contentMode = .scaleAspectFit
            
            overlayImageView.image = UIImage(named: "Done")
            overlayImageView.isHidden = false
            
        } else {
            let checkmarkImage = UIImage(named: "checkMarkButton")?.withRenderingMode(.alwaysTemplate)
            checkMarkButton.setImage(checkmarkImage, for: .normal)
            checkMarkButton.tintColor = tracker.color
            overlayImageView.isHidden = true
        }
        checkMarkButton.layer.masksToBounds = true
        checkMarkButton.isEnabled = !isFutureDate
        checkMarkButton.alpha = isFutureDate ? 0.3 : 1
    }
    
    @objc private func checkMarkButtonTapped() {
        delegate?.trackersCollectionViewCellDidTapCheckMark(self)
    }
    
    func update(isCompletedToday: Bool, daysCount: Int) {
        self.isCompletedToday = isCompletedToday
        self.daysCount = daysCount
        numberDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "дней"),
            daysCount
        )
        
        if isCompletedToday {
            let baseImage = UIImage(named: "Property")?.withRenderingMode(.alwaysTemplate)
            checkMarkButton.setImage(baseImage, for: .normal)
            
            overlayImageView.image = UIImage(named: "Done")
            overlayImageView.isHidden = false
            
            checkMarkButton.backgroundColor = tracker?.color.withAlphaComponent(0.5)
            checkMarkButton.tintColor = tracker?.color
        } else {
            let baseImage = UIImage(named: "checkMarkButton")?.withRenderingMode(.alwaysTemplate)
            checkMarkButton.setImage(baseImage, for: .normal)
            
            overlayImageView.isHidden = true
            checkMarkButton.backgroundColor = .clear
            checkMarkButton.tintColor = tracker?.color
        }
        
        checkMarkButton.layer.masksToBounds = true
    }
}

