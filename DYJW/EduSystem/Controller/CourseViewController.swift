//
//  CourseViewController.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/7/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let saveButton: UIButton = UIButton()
    private let termPickerView: TermPickerView = TermPickerView()
    private let courseView: CourseView = CourseView()
    
    private var courses: [Course.Index: [Course]] = [:]
    private var colorIndex: Int = -1
    private var courseColorIndexes: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadTermList()
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadTermList() {
        termPickerView.startLoading(text: "正在加载学期列表")
        EduSystemManager.shared.getSchoolTermList(refresh: false) { (result) in
            switch result {
            case let .success(list):
                var list = list
                if list.first == "请选择" {
                    list.removeFirst()
                }
                self.termPickerView.termList = list
                self.termPickerView.endLoading(displayMode: .selectTerm)
                self.termPickerView.toggleExpandStatus()
            case let .failure(error):
                self.termPickerView.endLoading(displayMode: .retry)
                print(error)
            }
        }
    }
    
    @objc private func saveButtonClicked() {
        let alert = UIAlertController(title: "保存课表", message: "确认保存当前课表到首页？如已有课表则会覆盖原有课表。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
            self.saveCourses()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func saveCourses() {
        let courses = self.courses.flatMap { (key, value) -> [Course] in
            return value
        }
        let controller = SaveCourseController(courses: courses)
        controller.callback = { error in
            let title: String
            if let error = error {
                print(error)
                title = "保存失败"
            } else {
                title = "保存成功"
                NotificationCenter.default.post(NeedRefreshCoursesNotification())
            }
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
    
}

extension CourseViewController: CourseViewDataSource {
    func courseView(_ courseView: CourseView, coursesAt day: Int, index: Int) -> [CourseView.CourseInfo] {
        let courseIndex = Course.Index(day: day, index: index)
        let courses = self.courses[courseIndex] ?? []
        return courses.map { (course) -> CourseView.CourseInfo in
            let colorName = getColorName(of: course.name)
            return CourseView.CourseInfo(title: course.name,
                                         time: course.time,
                                         location: course.classroom,
                                         teacher: course.teacher,
                                         courseClass: course.className,
                                         colorName: colorName)
        }
    }
    
    private func getColorName(of courseName: String) -> MDColorContainer.ColorName {
        if let index = courseColorIndexes[courseName] {
            return MDColorContainer.ColorName.allCases[index]
        }
        if colorIndex == -1 {
            let value = courseName.data(using: .utf8)?.count ?? courseName.count
            colorIndex = value % MDColorContainer.ColorName.allCases.count
            courseColorIndexes[courseName] = colorIndex
            return MDColorContainer.ColorName.allCases[colorIndex]
        } else {
            colorIndex += 1
            if colorIndex == MDColorContainer.ColorName.allCases.count {
                colorIndex = 0
            }
            courseColorIndexes[courseName] = colorIndex
            return MDColorContainer.ColorName.allCases[colorIndex]
        }
    }
}

extension CourseViewController: TermPickerViewDelegate {    
    func termPickerView(_ view: TermPickerView, didSelect term: String) {
        loadCourses(term: term)
    }
    
    func termPickerViewDidClickRetry(_ view: TermPickerView) {
        if termPickerView.termList.isEmpty {
            loadTermList()
        } else if let term = view.currentSelectedTerm {
            loadCourses(term: term)
        }
    }
    
    private func loadCourses(term: String) {
        guard let username = User.current?.username else { return }
        termPickerView.startLoading(text: "正在加载课表")
        saveButton.isHidden = true
        EduSystemManager.shared.getCourses(term: term, username: username) { (result) in
            switch result {
            case let .success(courses):
                self.courses = courses
                self.courseView.reloadData()
                self.saveButton.isHidden = false
                self.termPickerView.endLoading(displayMode: .content)
            case let .failure(error):
                self.termPickerView.endLoading(displayMode: .retry)
                print(error)
            }
        }
    }
}

extension CourseViewController {
    private func setupViews() {
        view.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "课表查询"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        saveButton.setImage(UIImage(named: "save_course"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        saveButton.isHidden = true
        
        termPickerView.delegate = self
        
        let courseHeaderBg = UIView()
        courseHeaderBg.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level900))
        
        courseView.beforeAnimation()
        courseView.style = .week
        courseView.afterAnimation()
        courseView.dataSource = self
        
        view.addSubview(headerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        termPickerView.contentView.addSubview(courseView)
        courseView.insertSubview(courseHeaderBg, at: 0)
        view.addSubview(termPickerView)
        
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
        
        saveButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalTo(headerView)
            make.width.height.equalTo(44)
        }
        
        termPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        courseView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        courseHeaderBg.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(25)
        }
    }
}
