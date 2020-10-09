//
//  ScoreViewController.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    private let headerView: HeaderGradientView = HeaderGradientView()
    private let termPickerView: TermPickerView = TermPickerView()
    private let creditLabel: UILabel = UILabel()
    private let tableView: UITableView = UITableView()
    
    private var scores: [Score] = []
    private var cellExpandStatus: [IndexPath: Bool] = [:]
    private var cellLoadingStatus: [IndexPath: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadTermList()
    }
    
    @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadTermList() {
        termPickerView.startLoading(text: "正在加载学期列表")
        EduSystemManager.shared.getSchoolTermList(refresh: false) { (result) in
            switch result {
            case let .success(list):
                var list = list
                if list.first == "请选择" {
                    list.removeFirst()
                }
                self.termPickerView.termList = list
                self.termPickerView.endLoading(displayMode: .selectTerm)
                self.termPickerView.toggleExpandStatus()
            case let .failure(error):
                self.termPickerView.endLoading(displayMode: .retry)
                print(error)
            }
        }
    }
}

extension ScoreViewController: TermPickerViewDelegate {
    func termPickerView(_ view: TermPickerView, didSelect term: String) {
        loadScore(term: term)
    }
    
    func termPickerViewDidClickRetry(_ view: TermPickerView) {
        if termPickerView.termList.isEmpty {
            loadTermList()
        } else if let term = view.currentSelectedTerm {
            loadScore(term: term)
        }
    }
    
    private func loadScore(term: String) {
        termPickerView.startLoading(text: "正在加载成绩")
        EduSystemManager.shared.getScores(term: term) { (result) in
            switch result {
            case let .success(score):
                self.scores = score.scores
                
                var array: [String] = []
                if let gradeScore = score.grade {
                    array.append("已修学分：\(gradeScore)")
                }
                if let credit = score.credit {
                    array.append("绩点：\(credit)")
                }
                if array.isEmpty {
                    self.creditLabel.text = "未查询到学分绩点"
                } else {
                    self.creditLabel.text = array.joined(separator: "        ")
                }
                
                self.termPickerView.endLoading(displayMode: .content)
                self.tableView.reloadData()
                self.tableView.contentOffset = .zero
            case let .failure(error):
                self.termPickerView.endLoading(displayMode: .retry)
                print(error)
            }
        }
    }
}

extension ScoreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ScoreCell.self, for: indexPath)
        cell.score = scores[indexPath.row]
        cell.delegate = self
        cell.setExpand(cellExpandStatus[indexPath] ?? false, animated: false)
        cell.isLoadingDetail = cellLoadingStatus[indexPath] ?? false
        return cell
    }
}

extension ScoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let isExpanded = cellExpandStatus[indexPath] ?? false
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath) as? ScoreCell
        cell?.setExpand(!isExpanded, animated: true)
        cellExpandStatus[indexPath] = !isExpanded
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = cellExpandStatus[indexPath] ?? false
        if isExpanded {
            if case let .success(details) = scores[indexPath.row].details {
                return 88 + CGFloat(7 + details.count) * 32 + 16
            } else {
                return 88 + 7 * 32 + 56
            }
        } else {
            return 88
        }
    }
}

extension ScoreViewController: ScoreCellDelegate {
    func scoreCellDidClickLoadDetail(_ cell: ScoreCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let isLoading = cellLoadingStatus[indexPath] ?? false
        guard !isLoading else { return }
        cell.isLoadingDetail = true
        cellLoadingStatus[indexPath] = true
        let path = scores[indexPath.row].detailURL
        EduSystemManager.shared.getScoreDetail(path: path) { [weak cell, weak self] (result) in
            guard let cell = cell, let self = self, let currentIndexPath = self.tableView.indexPath(for: cell) else { return }
            guard indexPath == currentIndexPath else { return }
            var score = self.scores[indexPath.row]
            score.details = result
            self.scores[indexPath.row] = score
            self.tableView.beginUpdates()
            cell.score = score
            cell.isLoadingDetail = false
            self.tableView.endUpdates()
        }
    }
}

extension ScoreViewController {
    private func setupViews() {
        view.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "成绩查询"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        termPickerView.delegate = self
        
        tableView.register(ScoreCell.self)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 48))
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        tableView.backgroundColor = .dynamic(light: .white, dark: 0x121212.rgbColor)
        
        creditLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        creditLabel.textColor = .dynamic(light: UIColor.md.grey(.level900), dark: .white)
        
        view.addSubview(headerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(termPickerView)
        termPickerView.contentView.addSubview(tableView)
        tableHeaderView.addSubview(creditLabel)
        
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalTo(headerView)
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.bottom.equalTo(headerView)
            make.height.equalTo(44)
        }
        
        termPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        creditLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(2)
        }
    }
}
