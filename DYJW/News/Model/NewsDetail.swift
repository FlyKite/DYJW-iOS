//
//  NewsDetail.swift
//  DYJW
//
//  Created by FlyKite on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

struct NewsDetail {
    let title: String
    let info: String
    let contents: [Content]

    enum Content {
        case text(text: String)
        case image(url: URL?)
    }
}
