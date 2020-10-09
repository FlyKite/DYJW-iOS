//
//  CourseColumnView.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/6/28.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class CourseColumnView: UIView, CourseViewAnimatable {
    
    var style: CourseItemView.Style = .card {
        didSet {
            updateStyle()
        }
    }
    
    func beforeAnimation() {
        itemViews.forEach { (itemView) in
            itemView.beforeAnimation()
        }
    }
    
    func afterAnimation() {
        itemViews.forEach { (itemView) in
            itemView.afterAnimation()
        }
    }
    
    typealias CourseColumn = [(index: Int, infos: [CourseView.CourseInfo])]
    
    func setCourseColumn(_ column: CourseColumn) {
        itemViews.forEach { (view) in
            view.removeFromSuperview()
        }
        itemViews = []
        scrollView.isHidden = column.isEmpty
        emptyLabel.isHidden = style == .grid || !column.isEmpty
        for row in column {
            if row.infos.isEmpty {
                continue
            }
            let index = row.index
            let infos = row.infos
            
            let view = CourseItemView()
            view.beforeAnimation()
            view.style = style
            view.afterAnimation()
            view.tag = index
            view.updateInfos(infos)
            container.addSubview(view)
            itemViews.append(view)
        }
        updateItemViews()
    }
    
    private let scrollView: UIScrollView = UIScrollView()
    private let container: UIView = UIView()
    private let emptyLabel: UILabel = UILabel()
    
    private var itemViews: [CourseItemView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.isHidden = true
        scrollView.clipsToBounds = false
        
        emptyLabel.text = "本日无课"
        emptyLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level500))
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        
        addSubview(scrollView)
        scrollView.addSubview(container)
        addSubview(emptyLabel)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(42)
        }
    }
    
    private func updateStyle() {
        switch style {
        case .card:
            emptyLabel.isHidden = !itemViews.isEmpty
            scrollView.isScrollEnabled = true
            scrollView.contentInsetAdjustmentBehavior = .automatic
        case .grid:
            emptyLabel.isHidden = true
            scrollView.isScrollEnabled = false
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        itemViews.forEach { (view) in
            switch style {
            case .card: view.style = .card
            case .grid: view.style = .grid
            }
        }
        updateItemViews()
    }
    
    private func updateItemViews() {
        for (index, view) in itemViews.enumerated() {
            let height: CGFloat
            let interval: CGFloat
            switch style {
            case .card:
                height = 160
                interval = 16
            case .grid:
                height = 120
                interval = 0
            }
            let viewIndex = style == .card ? index : view.tag
            view.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset((height + interval) * CGFloat(viewIndex) + interval)
                make.left.right.equalToSuperview()
                make.height.equalTo(height)
                if index == itemViews.count - 1 {
                    make.bottom.equalToSuperview().offset(-interval)
                }
            }
        }
    }
    
}
