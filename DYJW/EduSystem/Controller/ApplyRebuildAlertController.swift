//
//  ApplyRebuildAlertController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class ApplyRebuildAlertController: UIViewController {
    
    enum ApplyType {
        case rebuild
        case resitExam
    }
    
    let course: RebuildCourse
    let applyType: ApplyType
    
    init(course: RebuildCourse, applyType: ApplyType) {
        self.course = course
        self.applyType = applyType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container: UIView = UIView()
    private let bgMask: CAShapeLayer = CAShapeLayer()
    private let titleLabel: UILabel = UILabel()
    private let scrollView: UIScrollView = UIScrollView()
    private let stackView: UIStackView = UIStackView()
    private let applyButton: UIButton = UIButton()
    
    private let loadingMask: UIView = UIView()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    private let taskGroup: DispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        if touch.location(in: container).y < 0 {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgMask.path = UIBezierPath(roundedRect: container.bounds,
                                   byRoundingCorners: [.topLeft, .topRight],
                                   cornerRadii: CGSize(width: 16, height: 16)).cgPath
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        bgMask.fillColor = UIColor.dynamic(light: .white, dark: UIColor.md.grey(.level900)).cgColor
    }
    
    @objc private func cancelButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func applyButtonClicked() {
        switch course.status {
        case .normal:
            showLoading()
            apply()
        case .applied:
            showLoading()
            cancelApply()
        default:
            break
        }
    }
    
    private func showLoading() {
        taskGroup.enter()
        loadingMask.isHidden = false
        loadingView.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loadingMask.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.taskGroup.leave()
        }
    }
    
    private func apply() {
        switch applyType {
        case .rebuild:
            EduSystemManager.shared.applyRebuildCourse(path: course.applyUrl) { (result) in
                self.taskGroup.notify(queue: .main) {
                    if case let .failure(error) = result {
                        print(error)
                        self.showAlert(title: "报名失败", dismissAfterClicked: false)
                    } else {
                        self.showAlert(title: "报名成功", dismissAfterClicked: true)
                    }
                }
            }
        case .resitExam:
            EduSystemManager.shared.applyResit(bmid: course.bmid, isApply: true) { (result) in
                self.taskGroup.notify(queue: .main) {
                    switch result {
                    case let .success(tips):
                        self.showAlert(title: tips, dismissAfterClicked: true)
                    case .failure:
                        self.showAlert(title: "报名失败", dismissAfterClicked: false)
                    }
                }
            }
        }
    }
    
    private func cancelApply() {
        switch applyType {
        case .rebuild:
            EduSystemManager.shared.applyRebuildCourse(path: course.cancelUrl) { (result) in
                self.taskGroup.notify(queue: .main) {
                    if case let .failure(error) = result {
                        print(error)
                        self.showAlert(title: "取消报名失败", dismissAfterClicked: false)
                    } else {
                        self.showAlert(title: "取消报名成功", dismissAfterClicked: true)
                    }
                }
            }
        case .resitExam:
            EduSystemManager.shared.applyResit(bmid: course.bmid, isApply: false) { (result) in
                self.taskGroup.notify(queue: .main) {
                    switch result {
                    case let .success(tips):
                        self.showAlert(title: tips, dismissAfterClicked: true)
                    case .failure:
                        self.showAlert(title: "取消报名失败", dismissAfterClicked: false)
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, dismissAfterClicked: Bool) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            if dismissAfterClicked {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.loadingMask.alpha = 0
        } completion: { (finished) in
            self.loadingView.stopAnimating()
            self.loadingMask.isHidden = true
        }
    }
    
}

extension ApplyRebuildAlertController: FloatingPanel {
    func floatingPanelAnimationConfigs() -> AnimationConfig {
        return .default
    }
    
    func floatingPanelUpdateViews(for transitionType: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            self.container.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                switch transitionType {
                case .presenting:
                    make.bottom.equalToSuperview()
                case .dismissing:
                    make.top.equalTo(self.view.snp.bottom)
                }
            }
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            completeCallback()
        }
    }
}

extension ApplyRebuildAlertController {
    private func setupViews() {
        bgMask.fillColor = UIColor.dynamic(light: .white, dark: UIColor.md.grey(.level900)).cgColor
        
        titleLabel.text = course.courseName
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        
        let topSeparator = UIView()
        topSeparator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        
        for detail in course.details {
            let view = DetailView()
            view.font = .systemFont(ofSize: 16)
            view.title = detail.title
            view.value = detail.value
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(20)
            }
        }
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        let cancelButton = UIButton()
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.md.grey(.level500), for: .normal)
        cancelButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700)), for: .highlighted)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        applyButton.setTitle(course.status.title, for: .normal)
        applyButton.setTitleColor(UIColor.md.lightBlue(.level500), for: .normal)
        applyButton.setTitleColor(.dynamic(light: UIColor.md.lightBlue(.level200), dark: UIColor.md.lightBlue(.level800)), for: .highlighted)
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        applyButton.addTarget(self, action: #selector(applyButtonClicked), for: .touchUpInside)
        
        loadingMask.isHidden = true
        loadingMask.alpha = 0
        loadingMask.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        view.addSubview(container)
        container.layer.addSublayer(bgMask)
        container.addSubview(titleLabel)
        container.addSubview(topSeparator)
        container.addSubview(scrollView)
        scrollView.addSubview(stackView)
        container.addSubview(bottomSeparator)
        container.addSubview(cancelButton)
        container.addSubview(applyButton)
        view.addSubview(loadingMask)
        loadingMask.addSubview(loadingView)
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(64)
        }
        
        topSeparator.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(topSeparator.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(stackView).offset(32).priority(.low)
            make.height.lessThanOrEqualTo(view).multipliedBy(0.45)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalToSuperview().offset(-32)
        }
        
        bottomSeparator.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(scrollView.snp.bottom)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(bottomSeparator.snp.bottom)
            make.bottom.equalTo(container.safeAreaLayoutGuide)
            make.height.equalTo(48)
            make.width.equalTo(applyButton)
        }
        
        applyButton.snp.makeConstraints { (make) in
            make.left.equalTo(cancelButton.snp.right)
            make.top.width.height.equalTo(cancelButton)
            make.right.equalToSuperview().offset(-16)
        }
        
        loadingMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
