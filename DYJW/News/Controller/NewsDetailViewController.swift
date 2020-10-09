//
//  NewsDetailViewController.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    let path: String
    
    init(path: String) {
        self.path = path
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let titleLabel: UILabel = UILabel()
    private let tableView: UITableView = UITableView()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    
    private var newsDetail: NewsDetail?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadNewsDetail()
    }
    
    private func loadNewsDetail() {
        loadingView.isHidden = false
        loadingView.startAnimating()
        NewsManager.loadNewsDetail(path: path) { (result) in
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            switch result {
            case let .success(detail):
                self.newsDetail = detail
                self.titleLabel.text = detail.title
                self.tableView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }

}

extension NewsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let detail = newsDetail else { return 0 }
        return detail.contents.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(NewsDetailInfoCell.self, for: indexPath)
            guard let detail = newsDetail else { return cell }
            cell.title = detail.title
            cell.info = detail.info
            return cell
        } else {
            guard let detail = newsDetail else { return UITableViewCell() }
            let content = detail.contents[indexPath.row - 1]
            switch content {
            case let .text(text):
                let cell = tableView.dequeueReusableCell(NewsDetailTextCell.self, for: indexPath)
                cell.detailText = text
                return cell
            case let .image(url):
                let cell = tableView.dequeueReusableCell(NewsDetailImageCell.self, for: indexPath)
                cell.imageUrl = url
                return cell
            }
        }
    }
}

extension NewsDetailViewController: UITableViewDelegate {
    
}

extension NewsDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension NewsDetailViewController {
    private func setupViews() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsDetailInfoCell.self)
        tableView.register(NewsDetailTextCell.self)
        tableView.register(NewsDetailImageCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        loadingView.isHidden = true
        
        view.addSubview(headerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalTo(headerView)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.bottom.equalTo(headerView)
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
