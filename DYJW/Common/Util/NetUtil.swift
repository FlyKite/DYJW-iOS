//
//  NetUtil.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/3/6.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import Alamofire

class NetUtil {
    
    typealias RequestResult = (AFDataResponse<String>) -> Void
    
    static func syncRequest(api: Api) -> AFDataResponse<String> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDataResponse<String>?
        let request = AF.request(api)
        request.responseString { (response) in
            result = response
            semaphore.signal()
        }
        request.resume()
        semaphore.wait()
        return result!
    }
    
    static func request(api: Api, encoding: String.Encoding? = nil, completion: RequestResult?) {
        let request = AF.request(api)
        request.responseString(encoding: encoding) { (response) in
            completion?(response)
        }
        request.resume()
    }
    
    static func getCookies(of response: AFDataResponse<String>) -> [HTTPCookie] {
        guard let headers = response.response?.allHeaderFields as? [String: String]
            , let url = response.request?.url else {
            return []
        }
        return HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
    }
    
    static func getCookie(of response: AFDataResponse<String>, name: String) -> HTTPCookie? {
        return getCookies(of: response).first { (cookie) -> Bool in
            return cookie.name == name
        }
    }

}
