//
//  RebuildCourseCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class RebuildCourseCell: UITableViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private let card: UIView = UIView()
    private let titleLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        card.backgroundColor = .dynamic(light: UIColor.md.grey(.level100), dark: UIColor.md.grey(.level800))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
    }
}

extension RebuildCourseCell {
    private func setupViews() {
        selectionStyle = .none
        clipsToBounds = false
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
        card.layer.cornerRadius = 4
        card.layer.shadowRadius = 4
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.2
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.numberOfLines = 0
        
        let viewDetailLabel = UILabel()
        viewDetailLabel.text = "查看详情"
        viewDetailLabel.font = UIFont.systemFont(ofSize: 12)
        viewDetailLabel.textColor = UIColor.md.grey(.level500)
        
        let arrowView = UIImageView()
        arrowView.image = #imageLiteral(resourceName: "expand")
        arrowView.layer.setAffineTransform(CGAffineTransform(rotationAngle: .pi / -2))
        
        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(viewDetailLabel)
        card.addSubview(arrowView)
        
        card.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(viewDetailLabel.snp.left).offset(-8)
        }
        
        viewDetailLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowView.snp.left)
            make.centerY.equalToSuperview()
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
