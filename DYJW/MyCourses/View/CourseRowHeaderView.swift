//
//  CourseRowHeaderView.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/6/28.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class CourseRowHeaderView: UIView {

    private let container: UIStackView = UIStackView()
    private let headerLabels: [UILabel] = {
        let days = ["一", "二", "三", "四", "五", "六"]
        return days.map { (title) -> UILabel in
            let label = UILabel()
            label.text = title
            return label
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        container.axis = .vertical
        container.alignment = .fill
        container.distribution = .fillEqually
        
        addSubview(container)
        
        headerLabels.forEach { (label) in
            let view = UIView()
            
            let bg = UIView()
            bg.backgroundColor = .dynamic(light: UIColor.md.grey(.level50), dark: UIColor.md.grey(.level900))
            
            label.textColor = UIColor.md.grey(.level500)
            label.font = UIFont.systemFont(ofSize: 18)
            container.addArrangedSubview(view)
            
            let separator = UIView()
            separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
            
            view.addSubview(bg)
            view.addSubview(label)
            view.addSubview(separator)
            
            bg.snp.makeConstraints { (make) in
                make.top.bottom.left.equalToSuperview()
                make.width.equalTo(24)
            }
            
            label.snp.makeConstraints { (make) in
                make.center.equalTo(bg)
            }
            
            separator.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1 / UIScreen.main.scale)
            }
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
