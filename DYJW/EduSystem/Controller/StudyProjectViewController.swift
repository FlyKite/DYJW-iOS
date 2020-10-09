//
//  StudyProjectViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class StudyProjectViewController: UIViewController {
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let tableView: UITableView = UITableView()
    
    private let loadingContainer: UIStackView = UIStackView()
    private let loadingButton: UIButton = UIButton()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }()
    
    private var studyProjects: [StudyProject] = []
    private var cellExpandStatus: [IndexPath: Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadStudyProject()
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func loadingButtonClicked() {
        loadStudyProject()
    }
    
    private func loadStudyProject() {
        loadingContainer.isHidden = false
        loadingView.isHidden = false
        loadingView.startAnimating()
        loadingButton.isEnabled = false
        EduSystemManager.shared.getStudyProject { (result) in
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            switch result {
            case let .success(projects):
                self.loadingContainer.isHidden = true
                self.studyProjects = projects
                self.tableView.reloadData()
                self.tableView.isHidden = false
            case let .failure(error):
                self.loadingButton.isEnabled = true
                print(error)
            }
        }
    }

}

extension StudyProjectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studyProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(StudyProjectCell.self, for: indexPath)
        cell.project = studyProjects[indexPath.row]
        cell.setExpand(cellExpandStatus[indexPath] ?? false, animated: false)
        return cell
    }
}

extension StudyProjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let isExpanded = cellExpandStatus[indexPath] ?? false
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath) as? StudyProjectCell
        cell?.setExpand(!isExpanded, animated: true)
        cellExpandStatus[indexPath] = !isExpanded
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = cellExpandStatus[indexPath] ?? false
        if isExpanded {
            return 88 + 8 * 32 + 16
        } else {
            return 88
        }
    }
}

extension StudyProjectViewController {
    private func setupViews() {
        view.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "教学计划"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        tableView.isHidden = true
        tableView.register(StudyProjectCell.self)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        loadingButton.setTitle("点击重试", for: .normal)
        loadingButton.setTitle("正在加载教学计划", for: .disabled)
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
    }
}
