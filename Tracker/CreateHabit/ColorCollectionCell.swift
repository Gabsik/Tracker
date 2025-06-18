
import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        colorView.backgroundColor = .red
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true
        layer.borderWidth = 3
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        let borderColor = color.withAlphaComponent(0.3)
        layer.borderColor = isSelected ? borderColor.cgColor : UIColor.clear.cgColor
    }
}
