//
//  NewsItemCell.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var detail: String? {
        get { return detailLabel.text }
        set { detailLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = UILabel()
    private let detailLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        
        detailLabel.textColor = .dynamic(light: UIColor.md.grey(.level500), dark: UIColor.md.grey(.level400))
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.numberOfLines = 2
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.bottom.right.equalToSuperview().offset(-16)
        }
    }
    
}
