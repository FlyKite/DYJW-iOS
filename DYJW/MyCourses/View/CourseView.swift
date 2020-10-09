//
//  CourseView.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol CourseViewAnimatable {
    func beforeAnimation()
    func afterAnimation()
}

protocol CourseViewDataSource: AnyObject {
    func courseView(_ courseView: CourseView, coursesAt day: Int, index: Int) -> [CourseView.CourseInfo]
}

protocol CourseViewDelegate: AnyObject {
    func courseView(_ courseView: CourseView, didClickCourseAt day: Int, index: Int)
}

class CourseView: UIView, CourseViewAnimatable {
    
    weak var dataSource: CourseViewDataSource? {
        didSet {
            if oldValue == nil {
                reloadData()
            }
        }
    }
    weak var delegate: CourseViewDelegate?
    
    enum Style {
        case day
        case week
    }

    var style: Style = .day {
        didSet {
            updateStyle()
            layoutIfNeeded()
        }
    }
    
    struct CourseInfo {
        var title: String
        var time: String
        var location: String
        var teacher: String
        var courseClass: String
        var colorName: MDColorContainer.ColorName
    }
    
    func beforeAnimation() {
        rowHeader.isHidden = false
        columnViews.forEach { (view) in
            view.beforeAnimation()
        }
        layoutIfNeeded()
    }
    
    func afterAnimation() {
        rowHeader.isHidden = style == .day
        columnViews.forEach { (view) in
            view.afterAnimation()
        }
    }
    
    func reloadData() {
        loadData()
    }
    
    private let columnHeader: CourseColumnHeaderView = CourseColumnHeaderView()
    private let rowHeader: CourseRowHeaderView = CourseRowHeaderView()
    private let scrollView: UIScrollView = UIScrollView()
    private let container: UIStackView = UIStackView()
    private let columnViews: [CourseColumnView] = {
        var views: [CourseColumnView] = []
        for index in 0 ..< 7 {
            views.append(CourseColumnView())
        }
        return views
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
        clipsToBounds = true
        
        let columnHeaderContainer = UIView()
        columnHeaderContainer.clipsToBounds = true
        
        let rowHeaderContainer = UIView()
        rowHeaderContainer.clipsToBounds = true
        
        container.axis = .horizontal
        container.spacing = 48
        container.alignment = .fill
        container.distribution = .fillEqually
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        
        rowHeader.alpha = 0
        rowHeader.isHidden = true
        
        addSubview(columnHeaderContainer)
        columnHeaderContainer.addSubview(columnHeader)
        addSubview(rowHeaderContainer)
        rowHeaderContainer.addSubview(rowHeader)
        addSubview(scrollView)
        scrollView.addSubview(container)
        
        columnHeaderContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalTo(scrollView)
            make.height.equalTo(25)
        }
        
        columnHeader.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalTo(container)
        }
        
        rowHeaderContainer.snp.makeConstraints { (make) in
            make.top.equalTo(columnHeaderContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        rowHeader.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.bottom.equalTo(container)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(columnHeaderContainer.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        let columnWidth = UIScreen.main.bounds.width - 103
        
        container.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-87)
            make.bottom.equalTo(scrollView.safeAreaLayoutGuide)
            make.width.equalTo(columnWidth * 7 + 48 * 6)
        }
        
        columnViews.forEach { (view) in
            container.addArrangedSubview(view)
        }
    }
    
    private func updateStyle() {
        columnHeader.style = style
        switch style {
        case .day:
            rowHeader.alpha = 0
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.snp.updateConstraints { (make) in
                make.left.equalToSuperview()
            }
            container.spacing = 48
            let columnWidth = UIScreen.main.bounds.width - 103
            container.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-87)
                make.bottom.equalTo(scrollView.safeAreaLayoutGuide)
                make.width.equalTo(columnWidth * 7 + 48 * 6)
            }
            columnViews.forEach { (view) in
                view.style = .card
            }
        case .week:
            rowHeader.alpha = 1
            scrollView.contentInsetAdjustmentBehavior = .always
            scrollView.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(24)
            }
            container.spacing = 0
            let count: CGFloat = UIScreen.main.bounds.width > 375 ? 5.5 : 4.5
            let columnWidth = ceil((UIScreen.main.bounds.width - 24) / count)
            container.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
                make.width.equalTo(columnWidth * 7)
                make.height.equalTo(120 * 6)
            }
            columnViews.forEach { (view) in
                view.style = .grid
            }
        }
    }
    
    private func loadData() {
        for day in 0 ..< 7 {
            var courseColumn: CourseColumnView.CourseColumn = []
            for index in 0 ..< 6 {
                if let infos = dataSource?.courseView(self, coursesAt: day, index: index) {
                    courseColumn.append((index, infos))
                }
            }
            columnViews[day].setCourseColumn(courseColumn)
        }
    }

}

extension CourseView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard style == .day else { return }
        let width = UIScreen.main.bounds.width - 103
        let interval: CGFloat = 48
        let endPoint = targetContentOffset.pointee
        let currentPage = (scrollView.contentOffset.x / (width + interval)).rounded()
        var page = (endPoint.x / (width + interval)).rounded()
        if currentPage == page && velocity.x != 0 {
            page += velocity.x < 0 ? -1 : 1
        }
        targetContentOffset.pointee = CGPoint(x: (width + interval) * page, y: 0)
    }
}
