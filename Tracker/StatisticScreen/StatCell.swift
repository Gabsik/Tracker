
import Foundation

import UIKit
import SnapKit

final class StatCell: UITableViewCell {
    private let numberLabel = UILabel()
    private let titleLabel = UILabel()
    private let container = UIView()

    private let gradientBorder = CAGradientLayer()
    private let borderShape = CAShapeLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true

        contentView.addSubview(container)
        container.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview()
        }

        numberLabel.font = .boldSystemFont(ofSize: 32)
        numberLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray

        container.addSubview(numberLabel)
        container.addSubview(titleLabel)

        numberLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(4)
            $0.leading.equalTo(numberLabel)
            $0.bottom.equalToSuperview().inset(16)
        }

        addGradientBorder()
    }

    private func addGradientBorder() {
        gradientBorder.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradientBorder.startPoint = CGPoint(x: 0, y: 0)
        gradientBorder.endPoint = CGPoint(x: 1, y: 1)
        gradientBorder.cornerRadius = 12

        container.layer.insertSublayer(gradientBorder, at: 0)

        borderShape.lineWidth = 1.5
        borderShape.fillColor = UIColor.clear.cgColor
        borderShape.strokeColor = UIColor.black.cgColor
        gradientBorder.mask = borderShape
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorder.frame = container.bounds
        let path = UIBezierPath(roundedRect: container.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 12)
        borderShape.path = path.cgPath
    }

    func configure(number: Int, title: String) {
        numberLabel.text = "\(number)"
        titleLabel.text = title
    }
}
