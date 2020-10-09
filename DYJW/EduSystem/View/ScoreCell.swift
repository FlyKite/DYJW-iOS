//
//  ScoreCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol ScoreCellDelegate: AnyObject {
    func scoreCellDidClickLoadDetail(_ cell: ScoreCell)
}

class ScoreCell: UITableViewCell {
    
    weak var delegate: ScoreCellDelegate?
    
    var score: Score? { didSet { updateScore() } }
    
    var isLoadingDetail: Bool = false {
        didSet {
            guard oldValue != isLoadingDetail else { return }
            loadDetailButton.isEnabled = !isLoadingDetail
            if isLoadingDetail {
                loadingView.isHidden = false
                loadingView.startAnimating()
            } else {
                loadingView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }
    
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
    private let scoreLabel: UILabel = UILabel()
    private let expandIcon: UIImageView = UIImageView()
    private let detailContainer: UIView = UIView()
    private let detailStack: UIStackView = UIStackView()
    private var detailViews: [DetailView] = []
    
    private let loadDetailButtonContainer: UIView = UIView()
    private let loadDetailButton: UIButton = UIButton()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }()

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
    
    private func updateScore() {
        guard let score = score else { return }
        titleLabel.text = score.courseName
        scoreLabel.text = score.score
        var details: [Score.Detail] = []
        details.append(("成绩标志", score.chengjibiaozhi))
        details.append(("课程性质", score.kechengxingzhi))
        details.append(("课程类别", score.kechengleibie))
        details.append(("学时", score.xueshi))
        details.append(("学分", score.xuefen))
        details.append(("考试性质", score.kaoshixingzhi))
        details.append(("补重学期", score.buchongxueqi))
        if let detailResult = score.details {
            switch detailResult {
            case let .success(extra):
                loadDetailButtonContainer.isHidden = true
                details.append(contentsOf: extra)
            case .failure:
                loadDetailButtonContainer.isHidden = false
            }
        } else {
            loadDetailButtonContainer.isHidden = false
        }
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
    
    @objc private func loadDetailButtonClicked() {
        delegate?.scoreCellDidClickLoadDetail(self)
    }
}

extension ScoreCell {
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
        
        scoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        scoreLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        
        expandIcon.image = #imageLiteral(resourceName: "expand")
        
        detailContainer.alpha = 0
        detailContainer.isHidden = true
        detailContainer.clipsToBounds = true
        
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        detailStack.axis = .vertical
        detailStack.alignment = .fill
        detailStack.spacing = 16
        
        loadingView.isHidden = true
        
        loadDetailButton.setTitle("点击加载成绩结构", for: .normal)
        loadDetailButton.setTitle("正在加载成绩结构", for: .disabled)
        loadDetailButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level300)), for: .normal)
        loadDetailButton.setTitleColor(UIColor.md.grey(.level500), for: .highlighted)
        loadDetailButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level700), dark: UIColor.md.grey(.level300)), for: .disabled)
        loadDetailButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        loadDetailButton.addTarget(self, action: #selector(loadDetailButtonClicked), for: .touchUpInside)
        
        let loadDetailButtonStackContainer = UIStackView()
        loadDetailButtonStackContainer.axis = .horizontal
        loadDetailButtonStackContainer.spacing = 4
        
        contentView.addSubview(card)
        card.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(scoreLabel)
        container.addSubview(expandIcon)
        card.addSubview(detailContainer)
        detailContainer.addSubview(separator)
        detailContainer.addSubview(detailStack)
        detailStack.addArrangedSubview(loadDetailButtonContainer)
        loadDetailButtonContainer.addSubview(loadDetailButtonStackContainer)
        loadDetailButtonStackContainer.addArrangedSubview(loadingView)
        loadDetailButtonStackContainer.addArrangedSubview(loadDetailButton)
        
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
            make.right.lessThanOrEqualTo(scoreLabel.snp.left).offset(8)
        }
        
        scoreLabel.snp.makeConstraints { (make) in
            make.right.equalTo(expandIcon.snp.left).offset(-8)
            make.centerY.equalToSuperview()
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
        
        loadDetailButtonContainer.snp.makeConstraints { (make) in
            make.height.equalTo(24)
        }
        
        loadDetailButtonStackContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
