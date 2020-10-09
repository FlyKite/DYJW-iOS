//
//  EduSystemManager.swift
//  DYJW
//
//  Created by 风筝 on 2017/12/28.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit
import SwiftSoup

private let JSESSIONID = "JSESSIONID"

enum EduError: Error, CustomStringConvertible {
    case requestFailed
    case getSessionIdFailed
    case parseHTMLFailed
    case loginFailed(reason: String)
    case needLogin
    
    var description: String {
        switch self {
        case .requestFailed:
            return "网络连接失败，请稍后重试"
        case .getSessionIdFailed:
            return "登录失败：获取session出错"
        case .parseHTMLFailed:
            return "登录失败：HTML解析出错"
        case let .loginFailed(reason):
            return "登录失败：\(reason)"
        case .needLogin:
            return "请重新登录"
        }
    }
}

class EduSystemManager: NSObject {
    
    typealias LoginResult = Result<LoginSuccessInfo, EduError>
    
    typealias LoginCompletion = (LoginResult) -> Void
    
    typealias LoginSuccessInfo = (name: String, sessionId: String)
    typealias ScoreWithCredit = (scores: [Score], grade: String?, credit: String?)
    typealias RebuildCourseAndTime = (rebuildCourses: [RebuildCourse], applyTime: String)
    
    static let shared = EduSystemManager()
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.flykite.DYJW.Edu", attributes: .concurrent)
    
    private var termList: [String]?
    private let termSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
        
    func login(username: String, password: String, verifycode: String, completion: @escaping LoginCompletion) {
        queue.async {
            let result = self.loginFlow(username: username, password: password, verifycode: verifycode)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func setSessionId(_ sessionId: String) {
        guard let cookie = HTTPCookie(properties: [.value: sessionId,
                                                   .name: "JSESSIONID",
                                                   .path: "/",
                                                   .discard: "FALSE",
                                                   .domain: "jwgl.nepu.edu.cn"]) else {
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)
    }
    
    func removeSessionId() {
        guard let cookie = getSessionId() else { return }
        HTTPCookieStorage.shared.deleteCookie(cookie)
    }
    
    func getSchoolTermList(refresh: Bool, completion: ((Result<[String], Error>) -> Void)?) {
        queue.async {
            let result: Result<[String], Error>
            self.termSemaphore.wait()
            if !refresh, let list = self.termList {
                result = .success(list)
            } else {
                result = self.requestSchoolTermsList()
                if case let .success(list) = result {
                    User.current?.updateLastDate()
                    self.termList = list
                }
            }
            self.termSemaphore.signal()
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    func getCourses(term: String, username: String, completion: ((Result<[Course.Index: [Course]], Error>) -> Void)?) {
        schedule(completion: completion) { () -> [Course.Index: [Course]] in
            return try self.loadCourses(term: term, username: username)
        }
    }
    
    func getScores(term: String, completion: ((Result<ScoreWithCredit, Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.loadScores(term: term)
        }
    }
    
    func getScoreDetail(path: String, completion: ((Result<[Score.Detail], Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.loadScoreDetail(path: path)
        }
    }
    
    func getRebuildCourseList(completion: ((Result<RebuildCourseAndTime, Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.loadRebuildCourseList()
        }
    }
    
    func applyRebuildCourse(path: String, completion: ((Result<Void, Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.applyRebuildCourse(path: path)
        }
    }
    
    func applyResit(bmid: String, isApply: Bool, completion: ((Result<String, Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.applyResit(bmid: bmid, isApply: isApply)
        }
    }
    
    func getResitList(applied: Bool, completion: ((Result<[RebuildCourse], Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.loadResitExamList(applied: applied)
        }
    }
    
    func getStudyProject(completion: ((Result<[StudyProject], Error>) -> Void)?) {
        schedule(completion: completion) {
            try self.loadStudyProject()
        }
    }
    
    private func schedule<T>(completion: ((Result<T, Error>) -> Void)?, handle: @escaping () throws -> T) {
        queue.async {
            do {
                let result = try handle()
                User.current?.updateLastDate()
                DispatchQueue.main.async {
                    completion?(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
}

// MARK: - Login
extension EduSystemManager {
    private func loginFlow(username: String, password: String, verifycode: String) -> LoginResult {
        do {
            let sessionId = try login(username: username, password: password, verifycode: verifycode)
            let name = try getName()
            try logonBySSO()
            try changePageSize(username: username, name: name)
            return .success((name, sessionId))
        } catch {
            return .failure(error as! EduError)
        }
    }
    
    private func login(username: String, password: String, verifycode: String) throws -> String {
        let response = NetUtil.syncRequest(api: EduApi.login(username: username, password: password, verifycode: verifycode))
        switch response.result {
        case let .success(html):
            let successScript = "window.location.href='http://jwgl.nepu.edu.cn/framework/main.jsp'"
            if html.contains(successScript) {
                // 登录成功，进行下一步
                if let sessionId = getSessionId() {
                    return sessionId.value
                } else {
                    throw EduError.getSessionIdFailed
                }
            } else {
                // 登录失败，查找失败原因
                let err: EduError
                do {
                    let doc = try SwiftSoup.parse(html)
                    let errorMessage = try doc.select("span#errorinfo").first()?.text() ?? "未知原因"
                    if errorMessage.isEmpty {
                        err = EduError.loginFailed(reason: "未知原因")
                    } else {
                        err = EduError.loginFailed(reason: errorMessage)
                    }
                } catch {
                    print("Convert HTML failed: \(error)")
                    err = EduError.parseHTMLFailed
                }
                throw err
            }
        case let .failure(error):
            print(error)
            throw EduError.requestFailed
        }
    }
    
    private func getSessionId() -> HTTPCookie? {
        guard let url = URL(string: "http://jwgl.nepu.edu.cn/Logon.do?method=logon") else { return nil }
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        let cookie = cookies?.first { $0.name == JSESSIONID }
        return cookie
    }
    
    private func getName() throws -> String {
        let response = NetUtil.syncRequest(api: EduApi.getName)
        switch response.result {
        case let .success(html):
            do {
                let doc = try SwiftSoup.parse(html)
                let title = try doc.title()
                let name: String
                if let index = title.firstIndex(of: "[") {
                    name = String(title[..<index])
                } else {
                    name = ""
                }
                return name
            } catch {
                throw EduError.parseHTMLFailed
            }
        case let .failure(error):
            print(error)
            throw EduError.requestFailed
        }
    }
    
    private func logonBySSO() throws {
        let response = NetUtil.syncRequest(api: EduApi.loginBySSO)
        if case .failure = response.result {
            throw EduError.requestFailed
        }
    }

    private func changePageSize(username: String, name: String) throws {
        let response = NetUtil.syncRequest(api: EduApi.editUserInfo(username: username, realName: name))
        if case .failure = response.result {
            throw EduError.requestFailed
        }
    }
}

// MARK: - SchoolTermList
extension EduSystemManager {
    private func requestSchoolTermsList() -> Result<[String], Error> {
        let response = NetUtil.syncRequest(api: EduApi.getSchoolTermList)
        switch response.result {
        case let .success(html):
            do {
                let doc = try SwiftSoup.parse(html)
                try checkNeedLogin(document: doc)
                guard let elements = try doc.getElementById("xnxqh")?.select("option") else {
                    return .failure(EduError.parseHTMLFailed)
                }
                let results = try elements.enumerated().map { (element) -> String in
                    let text = try element.element.text()
                    if element.offset == 0 && text == "---请选择---" {
                        return "请选择"
                    } else {
                        return text
                    }
                }
                return .success(results)
            } catch {
                if error is EduError {
                    return .failure(error)
                }
                return .failure(EduError.parseHTMLFailed)
            }
        case let .failure(error):
            print(error)
            return .failure(EduError.requestFailed)
        }
    }
    
    private func checkNeedLogin(document doc: Document) throws {
        let form = try? doc.getElementById("relogonForm")
        if form != nil {
            throw EduError.needLogin
        }
    }
}

// MARK: - Courses
extension EduSystemManager {
    private func loadCourses(term: String, username: String) throws -> [Course.Index: [Course]] {
        let response = NetUtil.syncRequest(api: EduApi.getCourses(term: term, username: username))
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            guard let table = try doc.getElementById("kbtable") else {
                throw EduError.parseHTMLFailed
            }
            let rows = try table.select("tr")
            guard rows.count > 1 else {
                throw EduError.parseHTMLFailed
            }
            var courses: [Course.Index: [Course]] = [:]
            for row in 1 ..< rows.count {
                let rowElement = rows[row]
                let cols = try rowElement.select("td")
                guard cols.count > 1 else {
                    throw EduError.parseHTMLFailed
                }
                for col in 1 ..< cols.count {
                    let colElement = cols[col]
                    guard colElement.children().count >= 2 else { continue }
                    let div = colElement.child(1)
                    
                    var nodes: [Node] = div.getChildNodes()
                    var textNodes: [TextNode] = []
                    while !nodes.isEmpty {
                        let node = nodes.removeFirst()
                        if let node = node as? TextNode {
                            textNodes.append(node)
                        } else if let node = node as? Element {
                            nodes.append(contentsOf: node.getChildNodes())
                        }
                    }
                    
                    var array: [Course] = []
                    let index = Course.Index(day: col - 1, index: row - 1)
                    while textNodes.count >= 5 {
                        let courseName = textNodes.removeFirst().text()
                        let className = textNodes.removeFirst().text()
                        let teacherName = textNodes.removeFirst().text()
                        let weeks = textNodes.removeFirst().text()
                        let classroom = textNodes.removeFirst().text()
                        
                        let course = Course(index: index,
                                            name: courseName,
                                            className: className,
                                            teacher: teacherName,
                                            weeks: weeks,
                                            classroom: classroom)
                        array.append(course)
                    }
                    courses[index] = array
                }
            }
            return courses
        case let .failure(error):
            throw error
        }
    }
}

// MARK: - Score
extension EduSystemManager {
    private func loadScores(term: String) throws -> ScoreWithCredit {
        let response = NetUtil.syncRequest(api: EduApi.getScoreList(term: term))
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            
            var gradeScore: String?
            var credit: String?
            if let spans = try doc.getElementById("tblBm")?.getElementsByTag("td").first()?.getElementsByTag("span") {
                if spans.count > 1 {
                    gradeScore = try spans[1].text()
                }
                if spans.count > 3 {
                    credit = try spans[3].text()
                }
            }
            
            guard let rows = try doc.getElementById("mxh")?.getElementsByTag("tr") else {
                throw EduError.parseHTMLFailed
            }
            var scores: [Score] = []
            for row in rows {
                let cols = try row.getElementsByTag("td")
                var score = Score()
                
                if cols.count > 5 {
                    score.courseName = try cols[4].text()
                    let col = try cols[5].getElementsByTag("a").first()
                    score.score = try col?.text() ?? ""
                    
                    if let detailUrl = try col?.attr("onclick") {
                        let startIndex = detailUrl.firstIndex(of: "/")
                        let endIndex = detailUrl.lastIndex(of: "'")
                        if let start = startIndex, let end = endIndex {
                            score.detailURL = String(detailUrl[start ..< end])
                        }
                    }
                }
                
                score.chengjibiaozhi = try getText(in: cols, index: 6)
                score.kechengxingzhi = try getText(in: cols, index: 7)
                score.kechengleibie = try getText(in: cols, index: 8)
                score.xueshi = try getText(in: cols, index: 9)
                score.xuefen = try getText(in: cols, index: 10)
                score.kaoshixingzhi = try getText(in: cols, index: 11)
                score.buchongxueqi = try getText(in: cols, index: 12)
                
                scores.append(score)
            }
            
            return (scores, gradeScore, credit)
        case let .failure(error):
            throw error
        }
    }
    
    func getText(in cols: Elements, index: Int) throws -> String {
        if cols.count > index {
            return try cols[index].text()
        }
        return ""
    }
    
    private func loadScoreDetail(path: String) throws -> [Score.Detail] {
        let response = NetUtil.syncRequest(api: EduApi.getScoreDetail(path: path))
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            guard let tabs = try doc.getElementById("tblHead")?.getElementsByTag("th") else {
                throw EduError.parseHTMLFailed
            }
            guard let items = try doc.getElementById("mxh")?.getElementsByTag("td") else {
                throw EduError.parseHTMLFailed
            }
            var details: [Score.Detail] = []
            for index in 0 ..< tabs.count {
                let title = try tabs[index].text()
                let value: String
                if items.count > index {
                    value = try items[index].text()
                } else {
                    value = ""
                }
                details.append((title, value))
            }
            return details
        case let .failure(error):
            throw error
        }
    }
}

// MARK: - Rebuild
extension EduSystemManager {
    private func loadRebuildCourseList() throws -> RebuildCourseAndTime {
        let response = NetUtil.syncRequest(api: EduApi.getRebuildCourseList)
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            var applyTime = try doc.getElementById("tbTable")?.getElementsByTag("td").first()?.text() ?? ""
            if let index = applyTime.firstIndex(of: "\n") {
                applyTime = String(applyTime[applyTime.startIndex ..< index])
            }
            guard let rows = try doc.getElementById("mxh")?.getElementsByTag("tr") else {
                throw EduError.parseHTMLFailed
            }
            var courses: [RebuildCourse] = []
            for row in rows {
                let cols = try row.getElementsByTag("td")
                var course = RebuildCourse()
                course.courseName = try getText(in: cols, index: 5)
                course.details.append(("是否报名", try getText(in: cols, index: 0)))
                course.details.append(("上课院审", try getText(in: cols, index: 1)))
                course.details.append(("开课院审", try getText(in: cols, index: 2)))
                course.details.append(("取得资格", try getText(in: cols, index: 3)))
                course.details.append(("学年学期", try getText(in: cols, index: 4)))
                course.details.append(("课程编号", try getText(in: cols, index: 6)))
                course.details.append(("考试性质", try getText(in: cols, index: 7)))
                course.details.append(("课程属性", try getText(in: cols, index: 8)))
                course.details.append(("课程性质", try getText(in: cols, index: 9)))
                course.details.append(("学时", try getText(in: cols, index: 10)))
                course.details.append(("学分", try getText(in: cols, index: 11)))
                course.details.append(("是否选课", try getText(in: cols, index: 17)))
                course.details.append(("是否缴费", try getText(in: cols, index: 18)))
                course.details.append(("性质", try getText(in: cols, index: 19)))
                
                if cols.count > 20, let applyUrl = try cols[20].getElementsByTag("a").first()?.attr("onclick") {
                    if let startIndex = applyUrl.range(of: "('"), let endIndex = applyUrl.range(of: "')") {
                        course.applyUrl = String(applyUrl[startIndex.upperBound ..< endIndex.lowerBound])
                    }
                }
                
                if cols.count > 21, let cancelUrl = try cols[21].getElementsByTag("a").first()?.attr("onclick") {
                    if let startIndex = cancelUrl.range(of: "('"), let endIndex = cancelUrl.range(of: "')") {
                        course.cancelUrl = String(cancelUrl[startIndex.upperBound ..< endIndex.lowerBound])
                    }
                }
                
                let sfkbm = html.contains("var sfkbm = \"true\"")
                if sfkbm {
                    if try getText(in: cols, index: 0) == "√" {
                        if try getText(in: cols, index: 2) == "√" {
                            course.status = .inReview
                        } else {
                            course.status = .applied
                        }
                    } else {
                        course.status = .normal
                    }
                } else {
                    course.status = .disabled
                }
                if try getText(in: cols, index: 18) == "√" {
                    course.status = .purchased
                }
                courses.append(course)
            }
            return (courses, applyTime)
        case let .failure(error):
            throw error
        }
    }
    
    private func applyRebuildCourse(path: String) throws {
        let response = NetUtil.syncRequest(api: EduApi.applyRebuildCourse(path: path))
        if case let .failure(error) = response.result {
            throw error
        }
    }
}

// MARK: - ResitExam
extension EduSystemManager {
    private func loadResitExamList(applied: Bool) throws -> [RebuildCourse] {
        let response = NetUtil.syncRequest(api: EduApi.getResitList(applied: applied))
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            guard let rows = try doc.getElementById("mxh")?.getElementsByTag("tr") else {
                throw EduError.parseHTMLFailed
            }
            var courses: [RebuildCourse] = []
            for row in rows {
                let cols = try row.getElementsByTag("td")
                var course = RebuildCourse()
                course.courseName = try getText(in: cols, index: 1)
                course.details.append(("开课学期", try getText(in: cols, index: 0)))
                course.details.append(("课程编号", try getText(in: cols, index: 2)))
                course.details.append(("考试性质", try getText(in: cols, index: 3)))
                course.details.append(("课程属性", try getText(in: cols, index: 4)))
                course.details.append(("课程性质", try getText(in: cols, index: 5)))
                course.details.append(("学时", try getText(in: cols, index: 6)))
                course.details.append(("学分", try getText(in: cols, index: 7)))
                course.details.append(("总成绩", try getText(in: cols, index: 8)))
                if applied {
                    course.details.append(("是否缴费", try getText(in: cols, index: 9)))
                }
                
                let bmidIndex = applied ? 10 : 9
                if bmidIndex < cols.count, let bmid = try cols[bmidIndex].getElementsByTag("a").first()?.attr("onclick") {
                    if let startIndex = bmid.range(of: "('"), let endIndex = bmid.range(of: "')") {
                        course.bmid = String(bmid[startIndex.upperBound ..< endIndex.lowerBound])
                    }
                }
                
                let sfkbm = html.contains("var sfkbm = \"true\"")
                if sfkbm {
                    if applied {
                        course.status = .applied
                    } else {
                        course.status = .normal
                    }
                } else {
                    course.status = .disabled
                }
                if applied, try getText(in: cols, index: 9) == "是" {
                    course.status = .purchased
                }
                courses.append(course)
            }
            return courses
        case let .failure(error):
            throw error
        }
    }
    
    private func applyResit(bmid: String, isApply: Bool) throws -> String {
        let response = NetUtil.syncRequest(api: EduApi.applyResit(bmid: bmid, isApply: isApply))
        switch response.result {
        case let .success(html):
            if let startIndex = html.range(of: "alert('"), let endIndex = html.range(of: "')") {
                return String(html[startIndex.upperBound ..< endIndex.lowerBound])
            } else {
                return "未知"
            }
        case let .failure(error):
            throw error
        }
    }
}

// MARK: - StudyProject
extension EduSystemManager {
    private func loadStudyProject() throws -> [StudyProject] {
        let response = NetUtil.syncRequest(api: EduApi.getStudyProject)
        switch response.result {
        case let .success(html):
            let doc = try SwiftSoup.parse(html)
            try checkNeedLogin(document: doc)
            guard let rows = try doc.getElementById("mxh")?.getElementsByTag("tr") else {
                throw EduError.parseHTMLFailed
            }
            
            var projects: [StudyProject] = []
            let extra = (try rows.first()?.getElementsByTag("td").count ?? 0) - 11
            for row in rows {
                let cols = try row.getElementsByTag("td")
                var project = StudyProject()
                project.courseName = try getText(in: cols, index: 3)
                project.kaikexueqi = try getText(in: cols, index: 1)
                project.kechengbianma = try getText(in: cols, index: 2)
                project.zongxueshi = try getText(in: cols, index: 4)
                project.xuefen = try getText(in: cols, index: 5)
                project.kechengtixi = try getText(in: cols, index: 6)
                project.kechengshuxing = try getText(in: cols, index: 7)
                project.kaikedanwei = try getText(in: cols, index: 10 + extra)
                project.kaohefangshi = try getText(in: cols, index: 9 + extra)
                projects.append(project)
            }
            projects.sort { (project1, project2) -> Bool in
                var result = project1.kaikexueqi.compare(project2.kaikexueqi)
                if result == .orderedSame {
                    result = project2.kaohefangshi.compare(project1.kaohefangshi)
                }
                if result == .orderedSame {
                    result = project1.courseName.compare(project2.courseName)
                }
                return result == .orderedAscending
            }
            return projects
        case let .failure(error):
            throw error
        }
    }
}
