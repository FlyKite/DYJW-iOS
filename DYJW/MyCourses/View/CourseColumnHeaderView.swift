//
//  CourseColumnHeaderView.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/6/28.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class CourseColumnHeaderView: UIView {
    
    var style: CourseView.Style = .day {
        didSet {
            updateStyle()
        }
    }
    
    private let container: UIStackView = UIStackView()
    private let headerLabels: [UILabel] = {
        let days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
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
        container.axis = .horizontal
        container.alignment = .fill
        container.distribution = .fillEqually
        container.spacing = 48
        
        addSubview(container)
        
        headerLabels.forEach { (label) in
            let view = UIView()
            label.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
            label.font = UIFont.systemFont(ofSize: 18)
            container.addArrangedSubview(view)
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func updateStyle() {
        switch style {
        case .day:
            container.spacing = 48
            headerLabels.forEach { (label) in
                label.font = UIFont.systemFont(ofSize: 18)
                label.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                }
            }
        case .week:
            container.spacing = 0
            headerLabels.forEach { (label) in
                label.font = UIFont.systemFont(ofSize: 15)
                label.snp.remakeConstraints { (make) in
                    make.center.equalToSuperview()
                }
            }
        }
    }

}
