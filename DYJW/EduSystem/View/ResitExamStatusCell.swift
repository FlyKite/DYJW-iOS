//
//  ResitExamStatusCell.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol ResitExamStatusCellDelegate: AnyObject {
    func resitExamStatusCellDidClickRetryButton(_ cell: ResitExamStatusCell)
}

class ResitExamStatusCell: UITableViewCell {
    
    weak var delegate: ResitExamStatusCellDelegate?
    
    var title: String? {
        get { return loadingButton.title(for: .normal) }
        set { loadingButton.setTitle(newValue, for: .normal) }
    }
    
    var isLoading: Bool = false {
        didSet {
            loadingView.isHidden = !isLoading
            if isLoading {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
            }
        }
    }
    
    var isButtonEnabled: Bool = true {
        didSet {
            loadingButton.isEnabled = isButtonEnabled
        }
    }
    
    private let loadingContainer: UIStackView = UIStackView()
    private let loadingButton: UIButton = UIButton()
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
    
    @objc private func loadingButtonClicked() {
        delegate?.resitExamStatusCellDidClickRetryButton(self)
    }
}

extension ResitExamStatusCell {
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        loadingButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50)), for: .normal)
        loadingButton.setTitleColor(UIColor.md.grey(.level500), for: .normal)
        loadingButton.setTitleColor(.dynamic(light: UIColor.md.grey(.level900), dark: UIColor.md.grey(.level50)), for: .disabled)
        loadingButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        loadingButton.addTarget(self, action: #selector(loadingButtonClicked), for: .touchUpInside)
        
        loadingContainer.axis = .horizontal
        loadingContainer.alignment = .center
        loadingContainer.spacing = 8
        
        contentView.addSubview(loadingContainer)
        loadingContainer.addArrangedSubview(loadingView)
        loadingContainer.addArrangedSubview(loadingButton)
        
        loadingContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
