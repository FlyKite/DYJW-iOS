//
//  LoginPanel.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import AudioToolbox

protocol LoginPanelDelegate: AnyObject {
    func loginPanelDidClickVerifycodeButton(_ panel: LoginPanel)
    func loginPanelDidClickLoginButton(_ panel: LoginPanel)
}

class LoginPanel: UIView {
    
    var username: String? {
        get {
            return usernameField.text
        }
        set {
            usernameField.text = newValue
        }
    }
    
    var password: String? {
        get {
            return passwordField.text
        }
        set {
            passwordField.text = newValue
        }
    }
    
    var verifycode: String? {
        get {
            return verifycodeField.text
        }
        set {
            verifycodeField.text = newValue
        }
    }
    
    func startLoadingVerifycode() {
        verifycodeView.startLoading()
    }
    
    func updateVerifyCode(image: UIImage?, code: String?) {
        verifycodeView.stopLoding(verifycodeImage: image)
        verifycodeField.text = code
    }
    
    func showError(message: String) {
        AudioServicesPlaySystemSound(1521)
        errorLabel.text = message
        errorLabel.isHidden = false
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(10)
                }
                self.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(20)
                }
                self.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(14)
                }
                self.layoutIfNeeded()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.errorLabel.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(16)
                }
                self.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    func startLogin() {
        errorLabel.isHidden = true
        loadingView.isHidden = false
        loadingView.startAnimating()
        loginButton.setImage(nil, for: .normal)
        isUserInteractionEnabled = false
    }
    
    func endLogin(succeeded: Bool) {
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loginButton.setImage(UIImage(named: "arrow_right"), for: .normal)
        isUserInteractionEnabled = !succeeded
    }
    
    func reset() {
        errorLabel.isHidden = true
        username = nil
        password = nil
        verifycode = nil
        isUserInteractionEnabled = true
    }
    
    weak var delegate: LoginPanelDelegate?
    
    private let usernameField: UITextField = UITextField()
    private let passwordField: UITextField = UITextField()
    private let verifycodeField: UITextField = UITextField()
    private let verifycodeView: VerifyCodeView = VerifyCodeView()
    private let errorLabel: UILabel = UILabel()
    private let loginButton: FKButton = FKButton()
    private let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = "登录"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        
        usernameField.placeholder = "学号"
        usernameField.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        usernameField.font = UIFont.systemFont(ofSize: 15)
        usernameField.keyboardType = .asciiCapable
        usernameField.returnKeyType = .next
        usernameField.delegate = self
        usernameField.clearButtonMode = .whileEditing
        
        passwordField.placeholder = "密码"
        passwordField.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        passwordField.font = UIFont.systemFont(ofSize: 15)
        passwordField.isSecureTextEntry = true
        passwordField.keyboardType = .asciiCapable
        passwordField.delegate = self
        passwordField.returnKeyType = .go
        passwordField.clearButtonMode = .whileEditing
        
        verifycodeField.placeholder = "验证码"
        verifycodeField.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        verifycodeField.font = UIFont.systemFont(ofSize: 15)
        verifycodeField.keyboardType = .asciiCapable
        verifycodeField.delegate = self
        verifycodeField.returnKeyType = .go
        
        verifycodeView.clickAction = { [weak self] in
            guard let self = self else { return }
            self.delegate?.loginPanelDidClickVerifycodeButton(self)
        }
        
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
        
        addSubview(titleLabel)
        addSubview(usernameField)
        addSubview(passwordField)
        addSubview(verifycodeField)
        addSubview(verifycodeView)
        addSubview(errorLabel)
        addSubview(loginButton)
        addSubview(loadingView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
        }
        
        usernameField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameField.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        
        verifycodeField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordField.snp.bottom)
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
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(loginButton)
            make.right.equalTo(loginButton.snp.left).offset(-16)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(verifycodeField.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(48)
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(loginButton)
        }
        
        addSeparator(under: usernameField)
        addSeparator(under: passwordField)
        addSeparator(under: verifycodeField)
    }
    
    private func addSeparator(under view: UIView) {
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    @objc private func loginButtonClicked() {
        delegate?.loginPanelDidClickLoginButton(self)
    }

}

extension LoginPanel: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            delegate?.loginPanelDidClickLoginButton(self)
        } else if textField == verifycodeField {
            delegate?.loginPanelDidClickLoginButton(self)
        }
        return true
    }
}

class VerifyCodeView: UIView {
    
    var clickAction: (() -> Void)?
    
    func startLoading() {
        loadingView.isHidden = false
        loadingView.startAnimating()
        imageView.isHidden = true
        button.isHidden = true
    }
    
    func stopLoding(verifycodeImage: UIImage?) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        imageView.isHidden = false
        button.isHidden = false
        imageView.image = verifycodeImage
        button.setBackground(verifycodeImage == nil ? UIColor.dynamic(light: UIColor.md.grey(.level200), dark: UIColor.md.grey(.level300)) : UIColor.clear, for: .normal)
        button.setTitle(verifycodeImage == nil ? "点击刷新" : nil, for: .normal)
    }
    
    private let imageView: UIImageView = UIImageView()
    private let button: FKButton = FKButton()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .white)
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        button.setBackground(UIColor.dynamic(light: UIColor.md.grey(.level200), dark: UIColor.md.grey(.level300)), for: .normal)
        button.setTitle("点击刷新", for: .normal)
        button.setTitleColor(.dynamic(light: UIColor.md.lightBlue(.level500), dark: UIColor.md.grey(.level500)), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        button.isHidden = true
        
        loadingView.isHidden = true
        
        addSubview(imageView)
        addSubview(button)
        addSubview(loadingView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func buttonClicked() {
        clickAction?()
    }
}
