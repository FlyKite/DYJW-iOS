//
//  StudyProjectCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class StudyProjectCell: UITableViewCell {
    
    var project: StudyProject? { didSet { updateProject() } }
    
    func setExpand(_ expand: Bool, animated: Bool) {
        let animations = {
            self.detailContainer.alpha = expand ? 1 : 0
            self.expandIcon.layer.setAffineTransform(CGAffineTransform(rotationAngle: expand ? CGFloat.pi : 0))
        }
        let completion = { (finished: Bool) in
            self.detailContainer.isHidden = !expand
        }
        detailContainer.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.25, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
    
    private let card: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let expandIcon: UIImageView = UIImageView()
    private let detailContainer: UIView = UIView()
    private let detailStack: UIStackView = UIStackView()
    private var detailViews: [DetailView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        card.backgroundColor = .dynamic(light: UIColor.md.grey(.level100), dark: UIColor.md.grey(.level800))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
    }
    
    private func updateProject() {
        guard let project = project else { return }
        titleLabel.text = project.courseName
        var details: [(title: String, value: String)] = []
        details.append(("开课学期", project.kaikexueqi))
        details.append(("课程编码", project.kechengbianma))
        details.append(("总学时", project.zongxueshi))
        details.append(("学分", project.xuefen))
        details.append(("课程体系", project.kechengtixi))
        details.append(("课程属性", project.kechengshuxing))
        details.append(("开课单位", project.kaikedanwei))
        details.append(("考核方式", project.kaohefangshi))
        if details.count > detailViews.count {
            let count = details.count - detailViews.count
            for _ in 0 ... count {
                let view = DetailView()
                detailViews.insert(view, at: 0)
                detailStack.insertArrangedSubview(view, at: 0)
                view.snp.makeConstraints { (make) in
                    make.height.equalTo(16)
                }
            }
        }
        for (index, view) in detailViews.enumerated() {
            if index >= details.count {
                view.isHidden = true
                continue
            }
            view.isHidden = false
            view.title = details[index].title
            view.value = details[index].value
        }
    }
}

extension StudyProjectCell {
    private func setupViews() {
        selectionStyle = .none
        clipsToBounds = false
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let container = UIView()
        
        card.backgroundColor = .dynamic(light: .white, dark: UIColor.md.grey(.level900))
        card.layer.cornerRadius = 4
        card.layer.shadowRadius = 4
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.2
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.numberOfLines = 0
        
        expandIcon.image = #imageLiteral(resourceName: "expand")
        
        detailContainer.alpha = 0
        detailContainer.isHidden = true
        detailContainer.clipsToBounds = true
        
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        detailStack.axis = .vertical
        detailStack.alignment = .fill
        detailStack.spacing = 16
        
        contentView.addSubview(card)
        card.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(expandIcon)
        card.addSubview(detailContainer)
        detailContainer.addSubview(separator)
        detailContainer.addSubview(detailStack)
        
        card.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        container.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(72)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(expandIcon.snp.left).offset(8)
        }
        
        expandIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        detailContainer.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        separator.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        detailStack.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
}
