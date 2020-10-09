//
//  Score.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/2.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

struct Score {
    var courseName: String = ""
    var score: String = ""
    var chengjibiaozhi: String = ""
    var kechengxingzhi: String = ""
    var kechengleibie: String = ""
    var xueshi: String = ""
    var xuefen: String = ""
    var kaoshixingzhi: String = ""
    var buchongxueqi: String = ""
    var detailURL: String = ""
    
    typealias Detail = (title: String, value: String)
    
    var details: Result<[Detail], Error>?
}
