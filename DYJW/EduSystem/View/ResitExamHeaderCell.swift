//
//  ResitExamHeaderCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class ResitExamHeaderCell: UITableViewCell {
    
    var title: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    private let label: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
}

extension ResitExamHeaderCell {
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level100))
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
