//
//  Api.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/3/6.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import Alamofire

enum ApiMethod {
    case get
    case post
}

protocol Api: URLRequestConvertible {
    var domain: String { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: ApiMethod { get }
}

extension Api {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: domain.appending(path)) else {
            throw NSError()
        }
        var urlRequest = URLRequest(url: url)
        switch method {
        case .get: urlRequest.httpMethod = HTTPMethod.get.rawValue
        case .post: urlRequest.httpMethod = HTTPMethod.post.rawValue
        }
        urlRequest = try URLEncoding().encode(urlRequest, with: parameters)
        return urlRequest
    }
}
