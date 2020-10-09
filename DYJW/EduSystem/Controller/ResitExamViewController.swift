//
//  ResitExamViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class ResitExamViewController: UIViewController {

    private let headerView: HeaderGradientView = HeaderGradientView()
    private let tableView: UITableView = UITableView()
    
    private var courses: Result<[RebuildCourse], Error>?
    private var appliedCourses: Result<[RebuildCourse], Error>?
    
    private var isCoursesLoading: Bool = false
    private var isAppliedCoursesLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadCourseList()
        loadAppliedCourseList()
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func loadingButtonClicked() {
        loadCourseList()
    }
    
    private func loadCourseList() {
        courses = nil
        EduSystemManager.shared.getResitList(applied: false) { (result) in
            self.courses = result
            self.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    private func loadAppliedCourseList() {
        appliedCourses = nil
        EduSystemManager.shared.getResitList(applied: true) { (result) in
            self.appliedCourses = result
            self.tableView.reloadSections([1], with: .automatic)
        }
    }
}

extension ResitExamViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let result = section == 0 ? courses : appliedCourses else { return 2 }
        if case let .success(courses) = result, !courses.isEmpty {
            return courses.count + 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(ResitExamHeaderCell.self, for: indexPath)
            cell.title = indexPath.section == 0 ? "可报课程" : "已报课程"
            return cell
        } else {
            let result = indexPath.section == 0 ? courses : appliedCourses
            func showStatusCell(isLoading: Bool, isButtonEnabled: Bool, title: String) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(ResitExamStatusCell.self, for: indexPath)
                cell.isLoading = isLoading
                cell.isButtonEnabled = isButtonEnabled
                cell.title = title
                cell.delegate = self
                return cell
            }
            if let result = result {
                switch result {
                case let .success(courses):
                    if courses.isEmpty {
                        return showStatusCell(isLoading: false,
                                              isButtonEnabled: false,
                                              title: "暂无\(indexPath.section == 0 ? "可报课程" : "已报课程")")
                    } else {
                        let cell = tableView.dequeueReusableCell(RebuildCourseCell.self, for: indexPath)
                        cell.title = courses[indexPath.row - 1].courseName
                        return cell
                    }
                case .failure:
                    return showStatusCell(isLoading: false,
                                          isButtonEnabled: true,
                                          title: "加载失败，点击重试")
                }
            } else {
                return showStatusCell(isLoading: true,
                                      isButtonEnabled: false,
                                      title: "正在加载\(indexPath.section == 0 ? "可报课程" : "已报课程")")
            }
        }
    }
}

extension ResitExamViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = indexPath.section == 0 ? courses : appliedCourses
        if let result = result, case let .success(courses) = result {
            let alert = ApplyRebuildAlertController(course: courses[indexPath.row - 1], applyType: .rebuild)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 56
        }
        let result = indexPath.section == 0 ? courses : appliedCourses
        if let result = result, case let .success(courses) = result, !courses.isEmpty {
            return 88
        } else {
            return 56
        }
    }
}

extension ResitExamViewController: ResitExamStatusCellDelegate {
    func resitExamStatusCellDidClickRetryButton(_ cell: ResitExamStatusCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if indexPath.section == 0 {
            loadCourseList()
        } else {
            loadAppliedCourseList()
        }
        tableView.reloadSections([indexPath.section], with: .automatic)
    }
}

extension ResitExamViewController {
    private func setupViews() {
        view.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "补考报名"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        tableView.register(RebuildCourseCell.self)
        tableView.register(ResitExamHeaderCell.self)
        tableView.register(ResitExamStatusCell.self)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        view.addSubview(headerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
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
    }
}
