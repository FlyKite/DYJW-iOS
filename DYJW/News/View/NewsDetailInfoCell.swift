//
//  NewsDetailInfoCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsDetailInfoCell: UITableViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var info: String? {
        get { return infoLabel.text }
        set { infoLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        titleLabel.numberOfLines = 0
        
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        infoLabel.textColor = UIColor.md.grey(.level500)
        infoLabel.numberOfLines = 0
        
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(separator)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(separator.snp.top).offset(-16)
        }
        
        separator.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
}
