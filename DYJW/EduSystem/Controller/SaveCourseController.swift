//
//  SaveCourseController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import CoreData

class SaveCourseController: UIViewController {
    
    let courses: [Course]
    var callback: ((Error?) -> Void)?
    
    init(courses: [Course]) {
        self.courses = courses
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = UIView()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    private let taskGroup: DispatchGroup = DispatchGroup()
    private var saveError: Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        saveCourses()
        taskGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.taskGroup.leave()
        }
        self.taskGroup.notify(queue: .main) {
            self.tasksFinished()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingView.stopAnimating()
    }
    
    private func saveCourses() {
        guard let context = DBUtil.context else { return }
        taskGroup.enter()
        context.perform {
            let request: NSFetchRequest<DYCourse> = DYCourse.fetchRequest()
            do {
                let currentCourses = try context.fetch(request)
                currentCourses.forEach { (course) in
                    context.delete(course)
                }
            } catch {
                print(error)
            }
            self.courses.forEach { (course) in
                guard let entity = NSEntityDescription.insertNewObject(forEntityName: "DYCourse", into: context) as? DYCourse else { return }
                entity.name = course.name
                entity.nameOfClass = course.className
                entity.teacher = course.teacher
                entity.weeks = course.weeks
                entity.classroom = course.classroom
                entity.weekDay = Int16(course.index.day)
                entity.index = Int16(course.index.index)
                context.insert(entity)
            }
            do {
                try context.save()
            } catch {
                self.saveError = error
            }
            self.taskGroup.leave()
        }
    }
    
    private func tasksFinished() {
        dismiss(animated: true, completion: nil)
        callback?(saveError)
    }
    
}

extension SaveCourseController: FloatingPanel {
    func floatingPanelAnimationConfigs() -> AnimationConfig {
        return .default
    }
    
    func floatingPanelUpdateViews(for transitionType: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        UIView.animate(withDuration: duration) {
            switch transitionType {
            case .presenting: self.container.alpha = 1
            case .dismissing: self.container.alpha = 0
            }
        } completion: { (finished) in
            completeCallback()
        }

    }
}

extension SaveCourseController {
    private func setupViews() {
        container.backgroundColor = UIColor(white: 0, alpha: 0.8)
        container.alpha = 0
        container.layer.cornerRadius = 16
        
        let label = UILabel()
        label.text = "正在保存"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        
        view.addSubview(container)
        container.addSubview(loadingView)
        container.addSubview(label)
        
        container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(128)
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(loadingView.snp.bottom).offset(12)
        }
    }
}
