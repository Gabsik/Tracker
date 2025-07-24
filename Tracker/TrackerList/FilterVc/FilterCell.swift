
import UIKit
import SnapKit

final class FilterCell: UITableViewCell {
    private let checkmarkImageView = UIImageView()
    private let customSeparator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCheckmark()
        setipCustomSeparator()
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setipCustomSeparator() {
        customSeparator.backgroundColor = .lightGray
        contentView.addSubview(customSeparator)
        
        customSeparator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
    }
    
    private func setupCheckmark() {
        contentView.addSubview(checkmarkImageView)
        checkmarkImageView.image = UIImage(named: "checkmark")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        checkmarkImageView.isHidden = true
    }
    
    func configure(with title: String, showCheckmark: Bool, isLastCell: Bool) {
        textLabel?.text = title
        checkmarkImageView.isHidden = !showCheckmark
        customSeparator.isHidden = isLastCell

    }
}
