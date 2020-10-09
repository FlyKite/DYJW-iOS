//
//  RebuildCourse.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

struct RebuildCourse {
    typealias Detail = (title: String, value: String)
    var courseName: String = ""
    var details: [Detail] = []
    var applyUrl: String = ""
    var cancelUrl: String = ""
    var bmid: String = ""
    var status: Status = .normal
    
    enum Status {
        case normal
        case applied
        case inReview
        case disabled
        case purchased
        
        var title: String {
            switch self {
            case .normal: return "报名"
            case .applied: return "取消报名"
            case .inReview: return "审核中不可取消"
            case .disabled: return "不可操作"
            case .purchased: return "已缴费不可取消"
            }
        }
    }
}
