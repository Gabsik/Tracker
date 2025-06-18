
import Foundation
import UIKit
import SnapKit

class CreateHabitViewCollectionCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        constraints()
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
}
    private func constraints () {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
