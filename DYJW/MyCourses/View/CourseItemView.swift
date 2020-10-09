//
//  CourseItemView.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class CourseItemView: UIView, CourseViewAnimatable {
    
    enum Style {
        case card
        case grid
    }
    
    var style: Style = .card {
        didSet {
            switch style {
            case .card:
                card.alpha = 1
            case .grid:
                card.alpha = 0
            }
        }
    }
    
    func beforeAnimation() {
        grid.isHidden = false
        card.isHidden = false
        timer?.invalidate()
    }
    
    func afterAnimation() {
        switch style {
        case .card:
            grid.isHidden = true
        case .grid:
            card.isHidden = true
        }
        if courseInfos.count > 1 {
            startTimer()
        }
    }
    
    func updateInfos(_ infos: [CourseView.CourseInfo]) {
        courseInfos = infos
        currentIndex = 0
        guard let info = infos.first else { return }
        card.updateInfo(info)
        grid.updateInfo(info)
        if infos.count > 1 {
            startTimer()
        }
    }
    
    private let card: CourseCard = CourseCard()
    private let grid: CourseGrid = CourseGrid()
    
    private let animationCard: CourseCard = CourseCard()
    private let animationGrid: CourseGrid = CourseGrid()
    
    private var courseInfos: [CourseView.CourseInfo] = []
    private var currentIndex: Int = 0
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        grid.isHidden = true
        animationGrid.isHidden = true
        animationCard.isHidden = true
        animationGrid.layer.shadowOpacity = 0
        
        addSubview(grid)
        addSubview(card)
        grid.addSubview(animationGrid)
        card.addSubview(animationCard)
        
        card.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        grid.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        animationGrid.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        animationCard.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.showNextInfo()
        })
    }
    
    @objc private func showNextInfo() {
        currentIndex += 1
        if currentIndex >= courseInfos.count {
            currentIndex = 0
        }
        let info = courseInfos[currentIndex]
        animationCard.updateInfo(info)
        animationGrid.updateInfo(info)
        animationCard.isHidden = false
        animationGrid.isHidden = false
        animationCard.alpha = 0
        animationGrid.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.animationCard.alpha = 1
            self.animationGrid.alpha = 1
        } completion: { (finished) in
            self.card.updateInfo(info)
            self.grid.updateInfo(info)
            self.animationCard.isHidden = true
            self.animationGrid.isHidden = true
        }

    }
    
}

private class CourseCard: UIView {
    
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()
    
    func updateInfo(_ info: CourseView.CourseInfo) {
        titleLabel.text = info.title
        timeLabel.text = info.time
        var infoTextArray: [String] = []
        if !info.location.isEmpty {
            infoTextArray.append(info.location)
        }
        if !info.teacher.isEmpty {
            infoTextArray.append(info.teacher)
        }
        if !info.courseClass.isEmpty {
            infoTextArray.append(info.courseClass)
        }
        infoLabel.text = infoTextArray.joined(separator: " | ")
    }

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
        layer.cornerRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.numberOfLines = 2
        
        timeLabel.textColor = .dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level400))
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        
        infoLabel.textColor = UIColor.md.grey(.level500)
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(infoLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
}

private class CourseGrid: UIView {
    
    var gradientColorName: MDColorContainer.ColorName = .lightBlue {
        didSet {
            layer.colors = [UIColor.md.color(named: gradientColorName, .level500).cgColor,
                            UIColor.md.color(named: gradientColorName, .level900).cgColor]
        }
    }
    
    func updateInfo(_ info: CourseView.CourseInfo) {
        titleLabel.text = info.title
        infoLabel.text = info.location
        gradientColorName = info.colorName
    }
    
    private let darkMask: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()

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
        layer.cornerRadius = 4
        
        darkMask.layer.cornerRadius = 4
        darkMask.backgroundColor = UIColor(white: 0, alpha: 0.3)
        if #available(iOS 12.0, *) {
            darkMask.isHidden = traitCollection.userInterfaceStyle != .dark
        } else {
            darkMask.isHidden = true
        }
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 4
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        infoLabel.textColor = .white
        infoLabel.font = UIFont.systemFont(ofSize: 11)
        infoLabel.textAlignment = .center
        
        addSubview(darkMask)
        addSubview(titleLabel)
        addSubview(infoLabel)
        
        darkMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.lessThanOrEqualTo(infoLabel.snp.top)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            darkMask.isHidden = traitCollection.userInterfaceStyle != .dark
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
}
