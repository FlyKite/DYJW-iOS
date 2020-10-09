//
//  NotificationType.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol NotificationType { }

extension NotificationType {
    static var notificationName: Notification.Name {
        let name = String(describing: self)
        return Notification.Name(name)
    }
}

private let userInfoKey: String = "NotificationType_userInfoKey"

extension NotificationCenter {
    func post(_ notification: NotificationType) {
        post(name: type(of: notification).notificationName, object: nil, userInfo: [userInfoKey: notification])
    }
    
    func register<T: NotificationType>(_ type: T.Type, handler: @escaping (T) -> Void) {
        let name = type.notificationName
        addObserver(forName: name, object: nil, queue: nil) { (notification) in
            guard let userInfo = notification.userInfo as? [String: Any] else { return }
            guard let value = userInfo[userInfoKey] as? T else { return }
            handler(value)
        }
    }
    
    func unregister<T: NotificationType>(_ type: T.Type) {
        removeObserver(self, name: type.notificationName, object: nil)
    }
}
