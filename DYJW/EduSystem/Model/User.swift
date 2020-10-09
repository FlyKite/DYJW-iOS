//
//  User.swift
//  DYJW
//
//  Created by 风筝 on 2017/12/28.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

class User {
    
    static var isLogined: Bool {
        return current != nil
    }
    
    private(set) static var current: User? = getCurrentUser()
    
    let username: String
    let password: String
    let name: String
    private(set) var sessionId: String
    private(set) var lastDate: Date
    
    var needRefreshSessionId: Bool {
        return Date().timeIntervalSince(lastDate) > 25 * 60
    }
    
    static func login(username: String, password: String, name: String, sessionId: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(sessionId, forKey: "sessionId")
        let lastDate = Date()
        UserDefaults.standard.set(lastDate.timeIntervalSince1970, forKey: "lastDate")
        current = User(username: username,
                       password: password,
                       name: name,
                       sessionId: sessionId,
                       lastDate: lastDate)
    }
    
    static func logout() {
        current = nil
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "sessionId")
        UserDefaults.standard.removeObject(forKey: "lastDate")
    }
    
    func update(sessionId: String) {
        self.sessionId = sessionId
        UserDefaults.standard.set(sessionId, forKey: "sessionId")
        updateLastDate()
    }
    
    func updateLastDate() {
        let lastDate = Date()
        self.lastDate = lastDate
        UserDefaults.standard.set(lastDate.timeIntervalSince1970, forKey: "lastDate")
    }
    
    private static func getCurrentUser() -> User? {
        guard let username = UserDefaults.standard.string(forKey: "username"), !username.isEmpty else { return nil }
        guard let password = UserDefaults.standard.string(forKey: "password"), !password.isEmpty else { return nil }
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        let sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
        let lastDate = UserDefaults.standard.double(forKey: "lastDate")
        return User(username: username,
                    password: password,
                    name: name,
                    sessionId: sessionId,
                    lastDate: Date(timeIntervalSince1970: lastDate))
    }
    
    private init(username: String, password: String, name: String, sessionId: String, lastDate: Date) {
        self.username = username
        self.password = password
        self.name = name
        self.sessionId = sessionId
        self.lastDate = lastDate
    }
    
}
