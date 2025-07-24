
import UIKit
import SnapKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    let customSeparator = UIView()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        contentView.addSubview(customSeparator)
        customSeparator.backgroundColor = .lightGray
        selectionStyle = .none

        backgroundColor = .background
        selectionStyle = .none

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .blackCastom

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .blue
        checkmarkImageView.isHidden = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
    }

    private func layout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        customSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
    }
    
    func roundCorners(top: Bool, bottom: Bool) {
        let radius: CGFloat = 16
        layer.cornerRadius = radius
        layer.masksToBounds = true

        var corners: CACornerMask = []
        if top {
            corners.insert(.layerMinXMinYCorner)
            corners.insert(.layerMaxXMinYCorner)
        }
        if bottom {
            corners.insert(.layerMinXMaxYCorner)
            corners.insert(.layerMaxXMaxYCorner)
        }

        self.layer.maskedCorners = corners
        self.contentView.layer.cornerRadius = 0
    }
}

