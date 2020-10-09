//
//  NewsPersonCell.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import Kingfisher

class NewsPersonCell: UITableViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var detail: String? {
        get { return detailLabel.text }
        set { detailLabel.text = newValue }
    }
    
    var imageUrl: URL? {
        didSet {
            headImageView.image = nil
            if let url = imageUrl {
                headImageView.kf.setImage(with: url)
            }
        }
    }
    
    private let container: UIView = UIView()
    private let headImageView: UIImageView = UIImageView()
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
        selectionStyle = .none
        clipsToBounds = false
        backgroundColor = .clear
        
        container.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
        container.layer.cornerRadius = 4
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        
        let clipView = UIView()
        clipView.layer.cornerRadius = container.layer.cornerRadius
        clipView.clipsToBounds = true
        
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        
        detailLabel.textColor = .dynamic(light: UIColor.md.grey(.level500), dark: UIColor.md.grey(.level400))
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.numberOfLines = 3
        
        contentView.addSubview(container)
        container.addSubview(clipView)
        clipView.addSubview(headImageView)
        clipView.addSubview(titleLabel)
        clipView.addSubview(detailLabel)
        
        container.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        clipView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        headImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headImageView.snp.width).multipliedBy(2 / 3.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headImageView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.bottom.right.equalToSuperview().offset(-16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.layer.cornerRadius).cgPath
    }

}
