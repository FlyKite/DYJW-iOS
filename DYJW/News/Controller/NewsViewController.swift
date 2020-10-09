//
//  NewsViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let tabView: NewsTabView = NewsTabView()
    private let expandButton: UIButton = UIButton()
    
    private let scrollView: UIScrollView = UIScrollView()
    private lazy var listControllers: [NewsListController] = {
        return tabModels.map { (model) -> NewsListController in
            return NewsListController(tabModel: model)
        }
    }()
    
    private let tabModels: [NewsTabModel] = [
        NewsTabModel(title: "东油要闻", path: "dyyw"),
        NewsTabModel(title: "教学科研", path: "dyyw/jxky"),
        NewsTabModel(title: "党建思政", path: "dyyw/djsz"),
        NewsTabModel(title: "箐箐校园", path: "dyyw/qqxy"),
        NewsTabModel(title: "综合新闻", path: "zhxw"),
        NewsTabModel(title: "交流合作", path: "zhxw/jlhz"),
        NewsTabModel(title: "理论学习", path: "zhxw/llxx"),
        NewsTabModel(title: "创意东油", path: "zhxw/cydy"),
        NewsTabModel(title: "学术动态", path: "xsdt"),
        NewsTabModel(title: "学子天地", path: "xztd"),
//        NewsTabModel(title: "媒体聚焦", path: "mtjj"),
        NewsTabModel(title: "典型宣传", path: "mtjj/dxxc"),
//        NewsTabModel(title: "专题热点", path: "mtjj/ztrd"),
        NewsTabModel(title: "高教视点", path: "mtjj/gjsd"),
        NewsTabModel(title: "东油人物", path: "dyrw1"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    @objc private func expandButtonClicked() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            switch self.tabView.style {
            case .flat:
                self.tabView.style = .expanded
                self.tabView.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().multipliedBy(0.8)
                }
                self.headerView.snp.remakeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                let transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.expandButton.layer.setAffineTransform(transform.scaledBy(x: 1.5, y: 1.5))
                self.expandButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.tabView.snp.bottom).offset(80)
                    make.centerX.equalToSuperview()
                    make.width.height.equalTo(32)
                }
            case .expanded:
                self.tabView.style = .flat
                self.tabView.snp.remakeConstraints { (make) in
                    make.left.right.bottom.equalTo(self.headerView)
                    make.height.equalTo(32)
                }
                self.headerView.snp.remakeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(108)
                }
                self.expandButton.layer.setAffineTransform(CGAffineTransform(rotationAngle: 0))
                self.expandButton.snp.remakeConstraints { (make) in
                    make.centerY.right.equalTo(self.tabView)
                    make.width.height.equalTo(32)
                }
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

extension NewsViewController: NewsTabViewDelegate {
    func newsTabView(_ view: NewsTabView, didClickTabAt index: Int) {
        if view.style == .expanded {
            expandButtonClicked()
        }
        scrollView.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: true)
        tabView.selectedTabIndex = index
        listControllers[index].initialLoad()
    }
}

extension NewsViewController: NewsListControllerDelegate {
    func newsListController(_ controller: NewsListController, didClickNewsItem newsItem: NewsListItem) {
        guard !newsItem.path.isEmpty else { return }
        let newsController = NewsDetailViewController(path: newsItem.path.replacingOccurrences(of: "../", with: ""))
        navigationController?.pushViewController(newsController, animated: true)
    }
}

extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        checkPage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkPage()
    }
    
    private func checkPage() {
        let offsetX = scrollView.contentOffset.x
        var page = Int((offsetX / view.bounds.width).rounded())
        page = max(0, min(tabModels.count - 1, page))
        tabView.selectedTabIndex = page
        listControllers[page].initialLoad()
    }
}

extension NewsViewController {
    private func setupViews() {
        let titleLabel = UILabel()
        titleLabel.text = "新闻"
        titleLabel.font = UIFont.systemFont(ofSize: 36)
        titleLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isPagingEnabled = true
        
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .fill
        container.distribution = .fillEqually
        
        tabView.titles = tabModels.map { $0.title }
        tabView.delegate = self
        
        expandButton.setImage(UIImage(named: "news_tab_plus"), for: .normal)
        expandButton.addTarget(self, action: #selector(expandButtonClicked), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(container)
        listControllers.forEach { (controller) in
            controller.delegate = self
            container.addArrangedSubview(controller.view)
        }
        listControllers[0].initialLoad()
        
        view.addSubview(headerView)
        view.addSubview(titleLabel)
        view.addSubview(tabView)
        view.addSubview(expandButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(tabModels.count)
        }
        
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(108)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(headerView)
            make.height.equalTo(32)
        }
        
        expandButton.snp.makeConstraints { (make) in
            make.centerY.right.equalTo(tabView)
            make.width.height.equalTo(32)
        }
    }
}
