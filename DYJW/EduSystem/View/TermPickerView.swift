//
//  TermPickerView.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol TermPickerViewDelegate: AnyObject {
    func termPickerView(_ view: TermPickerView, didSelect term: String)
    func termPickerViewDidClickRetry(_ view: TermPickerView)
}

class TermPickerView: UIView {
    
    enum DisplayMode {
        case selectTerm
        case content
        case retry
    }
    
    var termList: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private(set) var isExpanded: Bool = false
    
    private(set) var isLoading: Bool = false
    
    var currentSelectedTerm: String? {
        if currentSelectedIndex >= 0 && currentSelectedIndex < termList.count {
            return termList[currentSelectedIndex]
        }
        return nil
    }
    
    weak var delegate: TermPickerViewDelegate?
    
    let contentView: UIView = UIView()
    
    func startLoading(text: String) {
        isLoading = true
        contentView.isHidden = true
        loadingContainer.isHidden = false
        loadingView.isHidden = false
        loadingView.startAnimating()
        loadingLabel.text = text
        loadingLabel.isUserInteractionEnabled = false
    }
    
    func endLoading(displayMode: DisplayMode) {
        isLoading = false
        loadingView.isHidden = true
        loadingView.stopAnimating()
        switch displayMode {
        case .selectTerm:
            loadingLabel.text = "请选择开课学期"
        case .content:
            loadingContainer.isHidden = true
            contentView.isHidden = false
        case .retry:
            loadingLabel.isUserInteractionEnabled = true
            loadingLabel.text = "加载失败，点击重试"
        }
    }
    
    func toggleExpandStatus() {
        guard !termList.isEmpty else { return }
        isExpanded.toggle()
        termMask.isHidden = false
        tableView.isHidden = false
        layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.termMask.backgroundColor = self.isExpanded ? UIColor(white: 0, alpha: 0.5) : .clear
            self.tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.termContainer.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(self.isExpanded ? 0.5 : 0)
            }
            self.layoutIfNeeded()
        } completion: { (finished) in
            if !self.isExpanded {
                self.termMask.isHidden = true
                self.tableView.isHidden = true
            }
        }
    }
    
    private let termContainer: UIView = UIView()
    private let termButton: UIButton = UIButton()
    private let termMask: UIView = UIView()
    private let tableView: UITableView = UITableView()
    
    private let loadingContainer: UIStackView = UIStackView()
    private let loadingLabel: UILabel = UILabel()
    private let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    
    private var currentSelectedIndex: Int = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let label = UILabel()
        label.text = "开课学期"
        label.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        label.font = UIFont.systemFont(ofSize: 15)
        
        termButton.setTitle("请选择", for: .normal)
        termButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50)), for: .normal)
        termButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900).withAlphaComponent(0.5), dark: UIColor.md.grey(.level50).withAlphaComponent(0.5)), for: .highlighted)
        termButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        termButton.setImage(UIImage(named: "triangle_down"), for: .normal)
        termButton.contentHorizontalAlignment = .right
        termButton.semanticContentAttribute = .forceRightToLeft
        termButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        termButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        termButton.addTarget(self, action: #selector(termButtonClicked), for: .touchUpInside)
        
        let separator = UIView()
        separator.backgroundColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        
        tableView.isHidden = true
        tableView.register(TermCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .dynamic(light: UIColor.md.grey(.level300), dark: UIColor.md.grey(.level700))
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 56
        tableView.estimatedRowHeight = 56
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        loadingContainer.axis = .horizontal
        loadingContainer.alignment = .center
        loadingContainer.spacing = 8
        loadingContainer.isHidden = true
        
        loadingLabel.text = "正在加载学期列表"
        loadingLabel.font = UIFont.systemFont(ofSize: 15)
        loadingLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        loadingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadingLabelClicked)))
        loadingLabel.isUserInteractionEnabled = false
        
        loadingView.isHidden = true
        
        addSubview(termContainer)
        termContainer.addSubview(label)
        termContainer.addSubview(termButton)
        termContainer.addSubview(separator)
        addSubview(contentView)
        addSubview(loadingContainer)
        loadingContainer.addArrangedSubview(loadingView)
        loadingContainer.addArrangedSubview(loadingLabel)
        addSubview(termMask)
        addSubview(tableView)
        
        termContainer.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(56)
        }
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        termButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        separator.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(termContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadingContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        termMask.snp.makeConstraints { (make) in
            make.top.equalTo(termContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(termContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    @objc private func termButtonClicked() {
        toggleExpandStatus()
    }
    
    @objc private func loadingLabelClicked() {
        delegate?.termPickerViewDidClickRetry(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        if isExpanded && touch.location(in: self).y > tableView.frame.maxY {
            toggleExpandStatus()
        }
    }
    
}

extension TermPickerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TermCell.self, for: indexPath)
        cell.title = termList[indexPath.row]
        cell.isChecked = currentSelectedIndex == indexPath.row
        return cell
    }
}

extension TermPickerView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if currentSelectedIndex >= 0 {
            let cell = tableView.cellForRow(at: IndexPath(row: currentSelectedIndex, section: 0)) as? TermCell
            cell?.isChecked = false
        }
        currentSelectedIndex = indexPath.row
        let cell = tableView.cellForRow(at: IndexPath(row: currentSelectedIndex, section: 0)) as? TermCell
        cell?.isChecked = true
        let term = termList[indexPath.row]
        termButton.setTitle(term, for: .normal)
        delegate?.termPickerView(self, didSelect: term)
        toggleExpandStatus()
    }
}

private class TermCell: UITableViewCell {
    
    var isChecked: Bool = false {
        didSet {
            checkImageView.isHidden = !isChecked
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = UILabel()
    private let checkImageView: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50))
        
        checkImageView.image = #imageLiteral(resourceName: "check_tick")
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkImageView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
