
import UIKit
import SnapKit

protocol ScheduleViewCellDelegate: AnyObject {
    func scheduleViewCell(_ cell: ScheduleViewCell, didToggle isOn: Bool)
}

final class ScheduleViewCell: UITableViewCell {
    let dayLabel = UILabel()
    let daySwitch = UISwitch()
    let stackView = UIStackView()
    weak var delegate: ScheduleViewCellDelegate?
    let customSeparator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addView()
        settinUI()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func addView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(daySwitch)
        contentView.addSubview(customSeparator)
        contentView.backgroundColor = .background
    }
    private func settinUI() {
        //MARK: setting stackView
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        //MARK: setting dayLabel
        dayLabel.textColor = .blackCastom
        dayLabel.font = UIFont.systemFont(ofSize: 17)
        
        //MARK: setting daySwitch
        daySwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        daySwitch.onTintColor = .blueCastom
        
        customSeparator.backgroundColor = .lightGray
        selectionStyle = .none
    }
    private func addConstraints() {
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)

            make.top.equalToSuperview().inset(22)
        }
        customSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    func configure(with day: String, isSelected: Bool) {
        dayLabel.text = day
        daySwitch.isOn = isSelected
    }
    @objc private func switchToggled(_ sender: UISwitch) {
        delegate?.scheduleViewCell(self, didToggle: sender.isOn)
    }
    func roundCorners(top: Bool, bottom: Bool) {
        let radius: CGFloat = 16
        contentView.layer.cornerRadius = radius
        contentView.layer.masksToBounds = true
        
        var corners: CACornerMask = []
        if top {
            corners.insert(.layerMinXMinYCorner)
            corners.insert(.layerMaxXMinYCorner)
        }
        if bottom {
            corners.insert(.layerMinXMaxYCorner)
            corners.insert(.layerMaxXMaxYCorner)
        }
        
        contentView.layer.maskedCorners = corners
    }
}
