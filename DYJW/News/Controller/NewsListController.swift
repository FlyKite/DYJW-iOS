//
//  NewsListController.swift
//  DYJW
//
//  Created by FlyKite on 2017/12/6.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

protocol NewsListControllerDelegate: AnyObject {
    func newsListController(_ controller: NewsListController, didClickNewsItem newsItem: NewsListItem)
}

class NewsTabModel {
    let title: String
    let path: String
    let isPersonList: Bool
    
    private(set) var isLoading: Bool = false
    private(set) var totalCount: Int = 0
    private(set) var totalPage: Int = 0
    private(set) var items: [NewsListItem] = []
    private(set) var currentPage: Int = 0
    
    init(title: String, path: String) {
        self.title = title
        self.path = path
        self.isPersonList = path == "dyrw1"
    }
    
    func loadList(isRefresh: Bool, completion: ((Error?) -> Void)?) {
        guard !isLoading else { return }
        isLoading = true
        let path: String
        if isRefresh {
            path = "\(self.path).htm"
        } else {
            path = currentPage > 0 ? "\(self.path)/\(totalPage - currentPage).htm" : "\(self.path).htm"
        }
        NewsManager.loadNewsList(path: path, isPersonList: isPersonList) { (result) in
            self.isLoading = false
            switch result {
            case let .success(listResult):
                if isRefresh || self.currentPage == 0 {
                    self.currentPage = 1
                    self.items = listResult.list
                    self.totalCount = listResult.totalCount
                    self.totalPage = (listResult.totalCount + 9) / (self.isPersonList ? 5 : 10)
                } else {
                    self.currentPage += 1
                    self.items.append(contentsOf: listResult.list)
                }
                completion?(nil)
            case let .failure(error):
                completion?(error)
            }
        }
    }
}

class NewsListController: UIViewController {
    
    weak var delegate: NewsListControllerDelegate?
    
    let tabModel: NewsTabModel
    
    init(tabModel: NewsTabModel) {
        self.tabModel = tabModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = UITableView()
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    private let bottomLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func initialLoad() {
        guard tabModel.items.isEmpty && tabModel.currentPage == 0 else { return }
        loadList(isRefresh: true)
    }
    
    @objc private func refreshControlValueChanged() {
        loadList(isRefresh: true)
    }
    
    private func loadList(isRefresh: Bool) {
        guard !tabModel.isLoading else { return }
        refreshControl.beginRefreshing()
        loadingView.isHidden = false
        loadingView.startAnimating()
        let currentCount = tabModel.items.count
        tabModel.loadList(isRefresh: isRefresh) { (error) in
            self.refreshControl.endRefreshing()
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            if let error = error {
                print(error)
                return
            }
            if self.tabModel.currentPage == self.tabModel.totalPage {
                self.bottomLabel.isHidden = false
            }
            if isRefresh {
                self.tableView.reloadData()
            } else {
                let insertCount = self.tabModel.items.count - currentCount
                var indexPaths: [IndexPath] = []
                for index in 0 ..< insertCount {
                    indexPaths.append(IndexPath(row: currentCount + index, section: 0))
                }
                self.tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print(view.safeAreaInsets)
    }

}

extension NewsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tabModel.isPersonList {
            let cell = tableView.dequeueReusableCell(NewsPersonCell.self, for: indexPath)
            cell.title = tabModel.items[indexPath.row].title
            cell.detail = tabModel.items[indexPath.row].detail
            cell.imageUrl = tabModel.items[indexPath.row].imageUrl
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(NewsItemCell.self, for: indexPath)
            cell.title = tabModel.items[indexPath.row].title
            cell.detail = tabModel.items[indexPath.row].detail
            return cell
        }
    }
}

extension NewsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = tabModel.items[indexPath.row]
        delegate?.newsListController(self, didClickNewsItem: item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !tabModel.isLoading && tabModel.currentPage < tabModel.totalPage && indexPath.row == tabModel.items.count - 1 else { return }
        loadList(isRefresh: false)
    }
}

extension NewsListController {
    private func setupViews() {
        if tabModel.isPersonList {
            tableView.register(NewsPersonCell.self)
            tableView.separatorStyle = .none
            tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        } else {
            tableView.register(NewsItemCell.self)
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            tableView.separatorColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
            tableView.estimatedRowHeight = 90
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48))
        tableView.refreshControl = refreshControl
        tableView.contentInsetAdjustmentBehavior = .always
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        
        loadingView.isHidden = true
        
        bottomLabel.text = "到底了"
        bottomLabel.font = UIFont.systemFont(ofSize: 15)
        bottomLabel.textColor = UIColor.md.grey(.level500)
        bottomLabel.isHidden = true
        
        view.addSubview(tableView)
        tableView.tableFooterView?.addSubview(loadingView)
        tableView.tableFooterView?.addSubview(bottomLabel)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        bottomLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
