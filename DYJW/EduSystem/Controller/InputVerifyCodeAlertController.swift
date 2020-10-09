//
//  InputVerifyCodeAlertController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import AudioToolbox

class InputVerifyCodeAlertController: UIViewController {
    
    var loginSucceededCallback: (() -> Void)?
    
    private let container: UIView = UIView()
    private let verifycodeField: UITextField = UITextField()
    private let verifycodeView: VerifyCodeView = VerifyCodeView()
    private let errorLabel: UILabel = UILabel()
    private let loginButton: FKButton = FKButton()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadVerifycode()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds,
                                                  cornerRadius: container.layer.cornerRadius).cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifycodeField.becomeFirstResponder()
    }
    
    private func loadVerifycode() {
        verifycodeView.startLoading()
        VerifyCode.loadVerifycodeImage { [weak self] (verifyCode) in
            guard let self = self else { return }
            self.verifycodeField.text = verifyCode?.recognizedCode
            self.verifycodeView.stopLoding(verifycodeImage: verifyCode?.verifycodeImage)
        }
    }
    
    @objc private func loginButtonClicked() {
        guard let user = User.current else { return }
        guard let verifycode = verifycodeField.text, !verifycode.isEmpty else {
            showError(message: "请输入验证码")
            return
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
        startLogin()
        EduSystemManager.shared.login(username: user.username, password: user.password, verifycode: verifycode) { (result) in
            switch result {
            case let .success(loginInfo):
                self.endLogin(succeeded: true)
                user.update(sessionId: loginInfo.sessionId)
                self.dismiss(animated: true) {
                    self.loginSucceededCallback?()
                }
            case let .failure(error):
                self.endLogin(succeeded: false)
                self.showError(message: error.description)
            }
        }
    }
    
    @objc private func closeButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showError(message: String) {
        AudioServicesPlaySystemSound(1521)
        errorLabel.text = message
        errorLabel.isHidden = false
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(10)
                }
                self.container.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(20)
                }
                self.container.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(14)
                }
                self.container.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(16)
                }
                self.container.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    private func startLogin() {
        errorLabel.isHidden = true
        loadingView.isHidden = false
        loadingView.startAnimating()
        loginButton.setImage(nil, for: .normal)
        container.isUserInteractionEnabled = false
    }
    
    private func endLogin(succeeded: Bool) {
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loginButton.setImage(UIImage(named: "arrow_right"), for: .normal)
        container.isUserInteractionEnabled = !succeeded
    }
}

extension InputVerifyCodeAlertController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == verifycodeField {
            loginButtonClicked()
        }
        return true
    }
}

extension InputVerifyCodeAlertController: FloatingPanel {
    func floatingPanelAnimationConfigs() -> AnimationConfig {
        return .default
    }
    
    func floatingPanelWillBeginTransition(type: TransitionType) {
        switch type {
        case .presenting: container.alpha = 0
        case .dismissing: container.alpha = 1
        }
    }
    
    func floatingPanelUpdateViews(for transitionType: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            switch transitionType {
            case .presenting:
                self.container.alpha = 1
                self.container.snp.updateConstraints { (make) in
                    make.centerY.equalToSuperview().offset(-80)
                }
            case .dismissing:
                self.container.alpha = 0
                self.container.snp.updateConstraints { (make) in
                    make.centerY.equalToSuperview().offset(-150)
                }
            }
            self.view.layoutIfNeeded()
        } completion: { (finished) in
            completeCallback()
        }

    }
}

extension InputVerifyCodeAlertController {
    private func setupViews() {
        container.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.cornerRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = "验证"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        
        let closeButton = UIButton()
        closeButton.setTitle("×", for: .normal)
        closeButton.setTitleColor(UIColor.md.grey(.level500), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        verifycodeField.placeholder = "验证码"
        verifycodeField.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        verifycodeField.font = UIFont.systemFont(ofSize: 15)
        verifycodeField.keyboardType = .asciiCapable
        verifycodeField.delegate = self
        verifycodeField.returnKeyType = .go
        
        verifycodeView.clickAction = { [weak self] in
            guard let self = self else { return }
            self.loadVerifycode()
        }
        
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        errorLabel.text = "错误消息"
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.textColor = .dynamic(light: UIColor.md.red(.level500), dark: UIColor.md.red(.level900))
        errorLabel.numberOfLines = 2
        errorLabel.isHidden = true
        
        loginButton.setImage(UIImage(named: "arrow_right"), for: .normal)
        var gradient = GradientBackground()
        gradient.colors = [
            .dynamic(light: 0x00BCD4.rgbColor, dark: 0x263238.rgbColor),
            .dynamic(light: 0x0086DA.rgbColor, dark: 0x111619.rgbColor)
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        loginButton.setBackground(gradient, for: .normal)
        loginButton.layer.cornerRadius = 24
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        
        loadingView.isHidden = true
        
        view.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(closeButton)
        container.addSubview(verifycodeField)
        container.addSubview(verifycodeView)
        container.addSubview(separator)
        container.addSubview(errorLabel)
        container.addSubview(loginButton)
        container.addSubview(loadingView)
        
        container.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
            make.width.equalToSuperview().offset(-32)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        verifycodeField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(48)
        }
        
        verifycodeView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.left.equalTo(verifycodeField.snp.right).offset(16)
            make.bottom.equalTo(verifycodeField)
            make.width.equalTo(90)
            make.height.equalTo(32)
        }
        
        separator.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(verifycodeField)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(loginButton)
            make.right.equalTo(loginButton.snp.left).offset(-16)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(verifycodeField.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(loginButton)
        }
    }
}
