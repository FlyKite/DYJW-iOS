//
//  HomeCourseViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import CoreData

struct NeedRefreshCoursesNotification: NotificationType { }

class HomeCourseViewController: UIViewController {
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let courseView: CourseView = CourseView()
    private let emptyLabel: UILabel = UILabel()
    
    private var needRefreshCourses: Bool = true
    private var courses: [Course.Index: [Course]] = [:]
    private var colorIndex: Int = -1
    private var courseColorIndexes: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        NotificationCenter.default.register(NeedRefreshCoursesNotification.self) { [weak self] (_) in
            guard let self = self else { return }
            self.needRefreshCourses = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needRefreshCourses {
            needRefreshCourses = false
            fetchCourses()
        }
    }
    
    @objc private func switchButtonClicked(_ button: UIButton) {
        button.isSelected.toggle()
        courseView.beforeAnimation()
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            if button.isSelected {
                self.courseView.style = .week
            } else {
                self.courseView.style = .day
            }
            self.headerView.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(button.isSelected ? 110 : 180)
            }
            self.view.layoutIfNeeded()
        }) { (_) in
            self.courseView.afterAnimation()
        }
    }
    
    private func fetchCourses() {
        DispatchQueue.global().async {
            guard let context = DBUtil.context else { return }
            let request: NSFetchRequest<DYCourse> = DYCourse.fetchRequest()
            do {
                let courses = try context.fetch(request)
                var result: [Course.Index: [Course]] = [:]
                for entity in courses {
                    let index = Course.Index(day: Int(entity.weekDay), index: Int(entity.index))
                    let course = Course(index: index,
                                        name: entity.name ?? "",
                                        className: entity.nameOfClass ?? "",
                                        teacher: entity.teacher ?? "",
                                        weeks: entity.weeks ?? "",
                                        classroom: entity.classroom ?? "")
                    var array = result[index] ?? []
                    array.append(course)
                    result[index] = array
                }
                self.courses = result
                DispatchQueue.main.async {
                    self.courseView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }

}

extension HomeCourseViewController: CourseViewDataSource {
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

extension HomeCourseViewController {
    private func setupViews() {
        let titleLabel = UILabel()
        titleLabel.text = "课表"
        titleLabel.font = UIFont.systemFont(ofSize: 36)
        titleLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
        
        let switchButton = UIButton()
        switchButton.setTitle("日", for: .normal)
        switchButton.setTitle("周", for: .selected)
        switchButton.setTitle("周", for: [.selected, .highlighted])
        switchButton.setTitleColor(.dynamic(light: .white, dark: UIColor.md.grey(.level50)), for: .normal)
        switchButton.setTitleColor(.dynamic(light: UIColor(white: 1, alpha: 0.5), dark: UIColor.md.grey(.level50).withAlphaComponent(0.5)), for: .highlighted)
        switchButton.setTitleColor(.dynamic(light: UIColor(white: 1, alpha: 0.5), dark: UIColor.md.grey(.level50).withAlphaComponent(0.5)), for: [.selected, .highlighted])
        switchButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        switchButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        switchButton.addTarget(self, action: #selector(switchButtonClicked), for: .touchUpInside)
        
        courseView.dataSource = self
        
        emptyLabel.text = "此处空空如也\n先去登录并保存课表吧"
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        emptyLabel.textColor = .dynamic(light: UIColor.md.grey(.level500), dark: UIColor.md.grey(.level600))
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.isHidden = true
        
        view.addSubview(headerView)
        view.addSubview(titleLabel)
        view.addSubview(switchButton)
        view.addSubview(courseView)
        view.addSubview(emptyLabel)
        
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(180)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        switchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
        }
        
        courseView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(85)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
