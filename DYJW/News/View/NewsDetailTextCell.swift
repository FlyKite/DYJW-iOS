//
//  NewsDetailTextCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsDetailTextCell: UITableViewCell {

    var detailText: String = "" {
        didSet {
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 6
            label.attributedText = NSAttributedString(string: detailText, attributes: [.paragraphStyle: pStyle])
        }
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
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        label.numberOfLines = 0
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

}
