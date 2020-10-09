//
//  NewsDetailImageCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsDetailImageCell: UITableViewCell {
    
    var imageUrl: URL? {
        didSet {
            detailImageView.image = nil
            if let url = imageUrl {
                detailImageView.kf.setImage(with: url, completionHandler:  { (result) in
                    switch result {
                    case let .success(imageResult):
                        self.updateImageSize(imageResult.image.size)
                    case let .failure(error):
                        print(error)
                    }
                })
            }
        }
    }

    private let detailImageView: UIImageView = UIImageView()
    
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
        
        contentView.addSubview(detailImageView)
        
        detailImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(detailImageView.snp.width).multipliedBy(2 / 3.0)
        }
    }
    
    private func updateImageSize(_ size: CGSize) {
        detailImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(detailImageView.snp.width).multipliedBy(size.height / size.width)
        }
    }

}
