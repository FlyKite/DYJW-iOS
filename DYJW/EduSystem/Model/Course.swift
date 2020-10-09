//
//  Course.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

struct Course {
    
    struct Index: Hashable {
        let day: Int
        let index: Int
    }
    let index: Index
    
    let name: String
    let className: String
    let teacher: String
    let weeks: String
    let classroom: String
    
    var time: String {
        switch index.index {
        case 0: return "8:00-9:35"
        case 1: return "9:55-11:30"
        case 2: return "13:30-15:05"
        case 3: return "15:25-17:00"
        case 4: return "18:00-19:35"
        case 5: return "19:55-21:30"
        default: return ""
        }
    }
}
