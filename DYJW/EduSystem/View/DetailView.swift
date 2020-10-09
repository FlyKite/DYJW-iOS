//
//  DetailView.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var value: String? {
        get { return valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    var font: UIFont = .systemFont(ofSize: 13) {
        didSet {
            titleLabel.font = font
            valueLabel.font = font
        }
    }
    
    private let titleLabel: UILabel = UILabel()
    private let valueLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level300))
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.font = UIFont.systemFont(ofSize: 13)
        valueLabel.textColor = .dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level300))
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(valueLabel.snp.left)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
