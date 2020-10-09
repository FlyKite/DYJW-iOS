//
//  NewsTabView.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol NewsTabViewDelegate: AnyObject {
    func newsTabView(_ view: NewsTabView, didClickTabAt index: Int)
}

class NewsTabView: UIView {
    
    weak var delegate: NewsTabViewDelegate?
    
    enum Style {
        case flat
        case expanded
    }
    
    var style: Style = .flat {
        didSet {
            updateStyle()
        }
    }
    
    var titles: [String] = [] {
        didSet {
            createButtons()
            selectedTabIndex = 0
        }
    }
    
    var selectedTabIndex: Int = 0 {
        didSet {
            guard style == .flat else { return }
            buttons.enumerated().forEach { (index, button) in
                button.isSelected = index == selectedTabIndex
            }
            if buttons[selectedTabIndex].frame.minX - scrollView.contentOffset.x < 0 {
                scrollView.setContentOffset(CGPoint(x: buttons[selectedTabIndex].frame.minX, y: 0), animated: true)
            } else if buttons[selectedTabIndex].frame.maxX - scrollView.contentOffset.x > bounds.width {
                scrollView.setContentOffset(CGPoint(x: buttons[selectedTabIndex].frame.maxX - bounds.width + 32, y: 0), animated: true)
            }
        }
    }
    
    private let gradientMask: GradientMask = GradientMask()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let container: UIView = UIView()
    private var buttons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        mask = gradientMask
        
        scrollView.showsHorizontalScrollIndicator = false
        
        gradientMask.layer.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
        gradientMask.layer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMask.layer.endPoint = CGPoint(x: 1, y: 0.5)
        
        addSubview(scrollView)
        scrollView.addSubview(container)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        buttons.enumerated().forEach { (index, button) in
            container.addSubview(button)
            button.snp.makeConstraints { (make) in
                if index == 0 {
                    make.left.equalToSuperview()
                } else {
                    make.left.equalTo(buttons[index - 1].snp.right).offset(4)
                }
                make.top.bottom.equalToSuperview()
                if index == buttons.count - 1 {
                    make.right.equalToSuperview().offset(-20)
                }
            }
        }
        
    }
    
    private func createButtons() {
        buttons.forEach { (button) in
            button.removeFromSuperview()
        }
        buttons = titles.enumerated().map { (index, title) -> UIButton in
            let button = UIButton()
            button.isSelected = index == 0
            button.tag = index
            button.setTitle(title, for: .normal)
            button.setTitleColor(.dynamic(light: UIColor(white: 1, alpha: 0.5), dark: UIColor.md.grey(.level50).withAlphaComponent(0.5)), for: .normal)
            button.setTitleColor(.dynamic(light: .white, dark: UIColor.md.grey(.level50)), for: .selected)
            button.setTitleColor(.dynamic(light: .white, dark: UIColor.md.grey(.level50)), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            container.addSubview(button)
            return button
        }
        updateStyle()
    }
    
    private func updateStyle() {
        switch style {
        case .flat:
            container.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalToSuperview()
            }
            buttons.enumerated().forEach { (index, button) in
                button.isSelected = index == selectedTabIndex
                button.snp.remakeConstraints { (make) in
                    if index == 0 {
                        make.left.equalToSuperview()
                    } else {
                        make.left.equalTo(buttons[index - 1].snp.right).offset(4)
                    }
                    make.top.bottom.equalToSuperview()
                    if index == buttons.count - 1 {
                        make.right.equalToSuperview().offset(-20)
                    }
                }
            }
        case .expanded:
            container.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
                make.width.height.equalToSuperview()
            }
            buttons.enumerated().forEach { (index, button) in
                button.isSelected = true
                button.snp.remakeConstraints { (make) in
                    let row = index / 3
                    if index == 0 {
                        make.top.left.equalToSuperview()
                        make.right.equalTo(buttons[1].snp.left).offset(-14)
                    } else if index == 1 {
                        make.top.centerX.equalToSuperview()
                    } else if index == 2 {
                        make.left.equalTo(buttons[1].snp.right).offset(14)
                        make.top.right.equalToSuperview()
                    }
                    if row > 0 {
                        make.top.equalTo(buttons[index - 3].snp.bottom).offset(22)
                        make.centerX.equalTo(buttons[index - 3])
                    }
                    if index == buttons.count - 1 {
                        make.bottom.equalToSuperview()
                    }
                    make.height.equalTo(32)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if style == .flat {
            let width = Double(bounds.width)
            let start = (width - 40) / width
            let end = (width - 20) / width
            gradientMask.layer.locations = [NSNumber(value: start), NSNumber(value: end)]
        } else {
            gradientMask.layer.locations = [1, 1]
        }
        gradientMask.frame = bounds
    }
    
    @objc private func buttonClicked(_ button: UIButton) {
        delegate?.newsTabView(self, didClickTabAt: button.tag)
    }

}

private class GradientMask: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
}
