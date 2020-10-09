//
//  EduApi.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/7.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

enum EduApi: Api {
    
    case login(username: String, password: String, verifycode: String)
    case getName
    case loginBySSO
    case editUserInfo(username: String, realName: String)
    
    case getSchoolTermList
    case getCourses(term: String, username: String)
    
    case getScoreList(term: String)
    case getScoreDetail(path: String)
    
    case getRebuildCourseList
    case applyRebuildCourse(path: String)
    
    case getResitList(applied: Bool)
    case applyResit(bmid: String, isApply: Bool)
    
    case getStudyProject
    
    var domain: String {
        return "http://jwgl.nepu.edu.cn/"
    }
    
    var path: String {
        switch self {
        case .login:
            return "Logon.do?method=logon"
        case .getName:
            return "framework/main.jsp"
        case .loginBySSO:
            return "Logon.do?method=logonBySSO"
        case .editUserInfo:
            return "yhxigl.do?method=editUserInfo"
        case .getSchoolTermList:
            return "tkglAction.do?method=kbxxXs"
        case .getCourses:
            return "tkglAction.do"
        case .getScoreList:
            return "xszqcjglAction.do?method=queryxscj"
        case let .getScoreDetail(path):
            return path
        case .getRebuildCourseList:
            return "zxglAction.do?method=xszxbmList"
        case let .applyRebuildCourse(path):
            return path
        case let .getResitList(applied):
            return "bkglAction.do?method=bkbmList&operate=\(applied ? "ybkc" : "kbkc")"
        case let .applyResit(_, isApply):
            return "bkglAction.do?method=bkbmList&operate=\(isApply ? "kbkc" : "ybkc")"
        case .getStudyProject:
            return "pyfajhgl.do?method=toViewJxjhXs"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .login(username, password, verifycode):
            return [
                "USERNAME": username,
                "PASSWORD": password,
                "RANDOMCODE": verifycode
            ]
        case .getName:
            return nil
        case .loginBySSO:
            return nil
        case let .editUserInfo(username, realName):
            return [
                "account" : username,
                "realName" : realName,
                "pwdQuestion1" : "",
                "pwdAnswer1" : "",
                "pwdQuestion2" : "",
                "pwdAnswer2" : "",
                "pageSize" : "200",
                "zjftxt" : "",
                "kyjftxt" : ""
            ]
        case .getSchoolTermList:
            return nil
        case let .getCourses(term, username):
            return [
                "method": "goListKbByXs",
                "sql": "",
                "xnxqh": term,
                "zc": "",
                "xs0101id": username
            ]
        case let .getScoreList(term):
            return [
                "kksj": term,
                "kcxz": "",
                "kcmc": "",
                "xsfs": ""
            ]
        case .getScoreDetail:
            return nil
        case .getStudyProject:
            return nil
        case .getRebuildCourseList:
            return nil
        case .getResitList:
            return nil
        case .applyRebuildCourse:
            return nil
        case let .applyResit(bmid, isApply):
            return [
                "cj0716id": bmid,
                "type": isApply ? "bm" : "qx"
            ]
        }
    }
    
    var method: ApiMethod {
        switch self {
        case .login,
             .getName,
             .loginBySSO,
             .editUserInfo,
             .getSchoolTermList,
             .getCourses,
             .getScoreList,
             .getScoreDetail,
             .getStudyProject,
             .getRebuildCourseList,
             .getResitList,
             .applyRebuildCourse,
             .applyResit:
            return .post
        }
    }
}
