//
//  RebuildListViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class RebuildListViewController: UIViewController {

    private let headerView: HeaderGradientView = HeaderGradientView()
    private let applyTimeLabel: UILabel = UILabel()
    private let tableView: UITableView = UITableView()
    
    private let loadingContainer: UIStackView = UIStackView()
    private let loadingButton: UIButton = UIButton()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }()
    
    private var rebuildCourses: [RebuildCourse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadRebuildList()
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func loadingButtonClicked() {
        loadRebuildList()
    }
    
    private func loadRebuildList() {
        loadingContainer.isHidden = false
        loadingView.isHidden = false
        loadingView.startAnimating()
        loadingButton.isEnabled = false
        EduSystemManager.shared.getRebuildCourseList { (result) in
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            switch result {
            case let .success(rebuildCourses):
                self.loadingContainer.isHidden = true
                self.rebuildCourses = rebuildCourses.rebuildCourses
                self.applyTimeLabel.text = rebuildCourses.applyTime
                self.tableView.reloadData()
                self.tableView.isHidden = false
            case let .failure(error):
                self.loadingButton.isEnabled = true
                print(error)
            }
        }
    }
}

extension RebuildListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rebuildCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RebuildCourseCell.self, for: indexPath)
        cell.title = rebuildCourses[indexPath.row].courseName
        return cell
    }
}

extension RebuildListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = ApplyRebuildAlertController(course: rebuildCourses[indexPath.row], applyType: .rebuild)
        present(alert, animated: true, completion: nil)
    }
}

extension RebuildListViewController {
    private func setupViews() {
        view.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "重修报名"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        tableView.isHidden = true
        tableView.register(RebuildCourseCell.self)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 64))
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        tableView.rowHeight = 88
        
        applyTimeLabel.font = UIFont.systemFont(ofSize: 15)
        applyTimeLabel.textColor = .dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level300))
        applyTimeLabel.numberOfLines = 0
        
        loadingButton.setTitle("点击重试", for: .normal)
        loadingButton.setTitle("正在加载重修课程", for: .disabled)
        loadingButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50)), for: .normal)
        loadingButton.setTitleColor(UIColor.md.grey(.level500), for: .normal)
        loadingButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50)), for: .disabled)
        loadingButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loadingButton.addTarget(self, action: #selector(loadingButtonClicked), for: .touchUpInside)
        
        loadingContainer.axis = .horizontal
        loadingContainer.alignment = .center
        loadingContainer.spacing = 8
        
        view.addSubview(headerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(loadingContainer)
        loadingContainer.addArrangedSubview(loadingView)
        loadingContainer.addArrangedSubview(loadingButton)
        tableHeaderView.addSubview(applyTimeLabel)
        
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
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
        
        loadingContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        applyTimeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(2)
        }
    }
}
