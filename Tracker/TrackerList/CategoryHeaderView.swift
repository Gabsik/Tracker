
import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        titleLabel.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
