//
//  EduSystemViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class EduSystemViewController: UIViewController {
    
    private let headerView: HeaderGradientView = HeaderGradientView()
    private let loginPanel: LoginPanel = LoginPanel()
    
    private let logoutButton: UIButton = UIButton()
    private let eduSystemView: EduSystemView = EduSystemView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        if let user = User.current {
            eduSystemView.name = user.name
            setToLoginedState()
            if !user.needRefreshSessionId {
                EduSystemManager.shared.setSessionId(user.sessionId)
                prefetchTermList()
            }
        } else {
            loadVerifyCode()
        }
    }
    
    private func loadVerifyCode() {
        loginPanel.startLoadingVerifycode()
        VerifyCode.loadVerifycodeImage { (verifyCode) in
            self.loginPanel.updateVerifyCode(image: verifyCode?.verifycodeImage, code: verifyCode?.recognizedCode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setToLoginedState() {
        loginPanel.alpha = 0
        loginPanel.isHidden = true
        logoutButton.alpha = 1
        logoutButton.isHidden = false
        eduSystemView.alpha = 1
        eduSystemView.isHidden = false
        updateConstraints(isLogined: true)
    }
    
    private func updateConstraints(isLogined: Bool) {
        eduSystemView.updateStyle(isLogined: isLogined)
        if isLogined {
            loginPanel.snp.updateConstraints { (make) in
                make.centerY.equalToSuperview().offset(view.bounds.height * -0.2)
            }
            headerView.snp.remakeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(180)
            }
        } else {
            loginPanel.snp.updateConstraints { (make) in
                make.centerY.equalToSuperview().offset(view.bounds.height * -0.1)
            }
            headerView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    @objc private func logoutButtonClicked() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
        
        let alert = UIAlertController(title: "注销", message: "确认退出当前账号？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "退出", style: .destructive, handler: { (action) in
            self.loginPanel.reset()
            self.loginPanel.username = User.current?.username
            EduSystemManager.shared.removeSessionId()
            User.logout()
            self.showLoginPanel()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showLoginPanel() {
        loginPanel.isHidden = false
        eduSystemView.isHidden = false
        loadVerifyCode()
        UIView.animate(withDuration: 0.35, animations: {
            self.loginPanel.alpha = 1
            self.logoutButton.alpha = 0
            self.eduSystemView.alpha = 0
            self.updateConstraints(isLogined: false)
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.logoutButton.isHidden = true
            self.eduSystemView.isHidden = true
        }
    }
    
    private func prefetchTermList() {
        EduSystemManager.shared.getSchoolTermList(refresh: true, completion: nil)
    }

}

extension EduSystemViewController: EduSystemViewDelegate {
    func eduSystemView(_ view: EduSystemView, didClickButton type: EduModuleType) {
        checkBeforeEnterNextPage {
            switch type {
            case .course:
                self.navigationController?.pushViewController(CourseViewController(), animated: true)
            case .score:
                self.navigationController?.pushViewController(ScoreViewController(), animated: true)
            case .rebuild:
                self.navigationController?.pushViewController(RebuildListViewController(), animated: true)
            case .resit:
                self.navigationController?.pushViewController(ResitExamViewController(), animated: true)
            case .project:
                self.navigationController?.pushViewController(StudyProjectViewController(), animated: true)
            }
        }
    }
    
    private func checkBeforeEnterNextPage(completion: @escaping () -> Void) {
        guard let user = User.current else { return }
        guard user.needRefreshSessionId else {
            completion()
            return
        }
        let alert = InputVerifyCodeAlertController()
        alert.loginSucceededCallback = { 
            completion()
        }
        present(alert, animated: true, completion: nil)
    }
}

extension EduSystemViewController: LoginPanelDelegate {
    func loginPanelDidClickVerifycodeButton(_ panel: LoginPanel) {
        loadVerifyCode()
    }
    
    func loginPanelDidClickLoginButton(_ panel: LoginPanel) {
        guard let username = panel.username, !username.isEmpty else {
            panel.showError(message: "请输入学号")
            return
        }
        guard let password = panel.password, !password.isEmpty else {
            panel.showError(message: "请输入密码")
            return
        }
        guard let verifycode = panel.verifycode, !verifycode.isEmpty else {
            panel.showError(message: "请输入验证码")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
        panel.startLogin()
        EduSystemManager.shared.login(username: username, password: password, verifycode: verifycode) { (result) in
            switch result {
            case let .success(loginInfo):
                panel.endLogin(succeeded: true)
                User.login(username: username, password: password, name: loginInfo.name, sessionId: loginInfo.sessionId)
                self.eduSystemView.name = loginInfo.name
                self.showEduSystem()
                self.prefetchTermList()
            case let .failure(error):
                panel.endLogin(succeeded: false)
                panel.showError(message: error.description)
            }
        }
    }
    
    private func showEduSystem() {
        logoutButton.isHidden = false
        eduSystemView.isHidden = false
        UIView.animate(withDuration: 0.35, animations: {
            self.loginPanel.alpha = 0
            self.logoutButton.alpha = 1
            self.eduSystemView.alpha = 1
            self.updateConstraints(isLogined: true)
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.loginPanel.isHidden = true
            self.view.endEditing(true)
        }
    }
}

extension EduSystemViewController {
    private func setupViews() {
        let titleLabel = UILabel()
        titleLabel.text = "教务"
        titleLabel.font = UIFont.systemFont(ofSize: 36)
        titleLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
        
        eduSystemView.isHidden = true
        eduSystemView.alpha = 0
        eduSystemView.delegate = self
        
        loginPanel.delegate = self
        
        logoutButton.setTitle("注销", for: .normal)
        logoutButton.setTitleColor(.dynamic(light: .white, dark: UIColor.md.grey(.level50)), for: .normal)
        logoutButton.setTitleColor(.dynamic(light: UIColor(white: 1, alpha: 0.5), dark: UIColor.md.grey(.level50).withAlphaComponent(0.5)), for: .highlighted)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        logoutButton.addTarget(self, action: #selector(logoutButtonClicked), for: .touchUpInside)
        logoutButton.alpha = 0
        logoutButton.isHidden = true
        
        view.addSubview(headerView)
        view.addSubview(titleLabel)
        view.addSubview(eduSystemView)
        view.addSubview(loginPanel)
        view.addSubview(logoutButton)
        
        headerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        eduSystemView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.bottom.right.equalToSuperview()
        }
        
        loginPanel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(view.bounds.height * -0.1)
            make.height.equalTo(280)
        }
        
        logoutButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel)
        }
    }
}
