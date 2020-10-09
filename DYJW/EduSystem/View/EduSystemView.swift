//
//  EduSystemView.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/29.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

enum EduModuleType: Int, CaseIterable {
    case course
    case score
    case rebuild
    case resit
    case project
}

protocol EduSystemViewDelegate: AnyObject {
    func eduSystemView(_ view: EduSystemView, didClickButton type: EduModuleType)
}

class EduSystemView: UIView {
    
    weak var delegate: EduSystemViewDelegate?
    
    var name: String = "" {
        didSet {
            welcomeLabel.text = "Hi，\(name)"
        }
    }
    
    func updateStyle(isLogined: Bool) {
        scrollView.snp.updateConstraints { (make) in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(isLogined ? 16 : 180)
        }
        layoutIfNeeded()
    }

    private let welcomeLabel: UILabel = UILabel()
    private let scrollView: UIScrollView = UIScrollView()
    
    private typealias Item = (icon: UIImage?, title: String, colorName: MDColorContainer.ColorName)
    private let itemViews: [EduSystemItemView] = {
        return EduModuleType.allCases.map { (type) -> EduSystemItemView in
            let view = EduSystemItemView()
            view.tag = type.rawValue
            view.icon = type.icon
            view.title = type.title
            view.gradientColorName = type.colorName
            return view
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
        welcomeLabel.text = "Hi，"
        welcomeLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
        welcomeLabel.font = UIFont.systemFont(ofSize: 15)
        
        scrollView.alwaysBounceVertical = false
        
        addSubview(welcomeLabel)
        addSubview(scrollView)
        
        itemViews.enumerated().forEach { (index, item) in
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemViewDidClicked))
            item.addGestureRecognizer(tap)
            scrollView.addSubview(item)
            item.snp.makeConstraints { (make) in
                if index == 0 {
                    make.top.equalToSuperview().offset(16)
                } else {
                    make.top.equalTo(itemViews[index - 1].snp.bottom).offset(16)
                }
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.width.equalToSuperview().offset(-32)
                make.height.equalTo(96)
                if index == itemViews.count - 1 {
                    make.bottom.equalToSuperview().offset(-16)
                }
            }
        }
        
        welcomeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(180)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    @objc private func itemViewDidClicked(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view, let type = EduModuleType(rawValue: view.tag) else { return }
        delegate?.eduSystemView(self, didClickButton: type)
    }

}

private extension EduModuleType {
    var icon: UIImage? {
        switch self {
        case .course: return UIImage(named: "edu_course")
        case .score: return UIImage(named: "edu_score")
        case .rebuild: return UIImage(named: "edu_rebuild")
        case .resit: return UIImage(named: "edu_resit")
        case .project: return UIImage(named: "edu_project")
        }
    }
    
    var title: String {
        switch self {
        case .course: return "课表查询"
        case .score: return "成绩查询"
        case .rebuild: return "重修报名"
        case .resit: return "补考报名"
        case .project: return "教学计划"
        }
    }
    
    var colorName: MDColorContainer.ColorName {
        switch self {
        case .course: return .cyan
        case .score: return .teal
        case .rebuild: return .green
        case .resit: return .lightGreen
        case .project: return .lime
        }
    }
}

private class EduSystemItemView: UIView {
    
    var icon: UIImage? {
        get { return iconView.image }
        set { iconView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var gradientColorName: MDColorContainer.ColorName = .lightBlue {
        didSet {
            layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                            UIColor.md.color(named: gradientColorName, .level900).cgColor]
        }
    }
    
    private let darkMask: UIView = UIView()
    private let iconView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                        UIColor.md.color(named: gradientColorName, .level900).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 16
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        darkMask.backgroundColor = .dynamic(light: .clear, dark: UIColor(white: 0, alpha: 0.4))
        darkMask.layer.cornerRadius = 16
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = .dynamic(light: .white, dark: UIColor.md.grey(.level50))
        
        let rightArrow = UIImageView()
        rightArrow.image = UIImage(named: "edu_button_right")
        
        addSubview(darkMask)
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(rightArrow)
        
        darkMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        rightArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        layer.colors = [UIColor.md.color(named: gradientColorName, .level300).cgColor,
                        UIColor.md.color(named: gradientColorName, .level900).cgColor]
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        if bounds.contains(touch.location(in: self)) {
            layer.colors = [UIColor.md.color(named: gradientColorName, .level300).cgColor,
                            UIColor.md.color(named: gradientColorName, .level900).cgColor]
        } else {
            layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                            UIColor.md.color(named: gradientColorName, .level900).cgColor]
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                        UIColor.md.color(named: gradientColorName, .level900).cgColor]
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                        UIColor.md.color(named: gradientColorName, .level900).cgColor]
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
}
