//
//  NewsManager.swift
//  DYJW
//
//  Created by Feng,Zheng on 2020/7/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import SwiftSoup

enum NewsApi: Api {
    case list(path: String)
    case detail(path: String)
    
    var domain: String {
        return "http://news.nepu.edu.cn/"
    }
    
    var path: String {
        switch self {
        case let .list(path):
            return path
        case let .detail(path):
            return path
        }
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var method: ApiMethod {
        return .get
    }
}

enum NewsError: Error {
    case contentNotFound
    case encodingFailed
}

class NewsManager {
    
    typealias NewsListResult = (totalCount: Int, list: [NewsListItem])
    
    typealias LoadNewsListCompletion = (Result<NewsListResult, Error>) -> Void
    
    typealias LoadNewsDetailCompletion = (Result<NewsDetail, Error>) -> Void
    
    static func loadNewsList(path: String, isPersonList: Bool, completion: LoadNewsListCompletion?) {
        NetUtil.request(api: NewsApi.list(path: path), encoding: .utf8) { (response) in
            switch response.result {
            case let .success(html):
                DispatchQueue.global().async {
                    do {
                        let result: NewsListResult
                        if isPersonList {
                            result = try self.getNewsPersonList(html: html)
                        } else {
                            result = try self.getNewsList(html: html)
                        }
                        DispatchQueue.main.async {
                            completion?(.success(result))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion?(.failure(error))
                        }
                    }
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
    
    static func loadNewsDetail(path: String, completion: LoadNewsDetailCompletion?) {
        NetUtil.request(api: NewsApi.detail(path: path), encoding: .utf8) { (response) in
            DispatchQueue.global().async {
                let result: Result<NewsDetail, Error>
                switch response.result {
                case let .success(html):
                    do {
                        result = .success(try self.getNewsDetail(html: html))
                    } catch {
                        result = .failure(error)
                    }
                case let .failure(error):
                    result = .failure(error)
                }
                DispatchQueue.main.async {
                    completion?(result)
                }
            }
        }
    }

}

extension NewsManager {
    static private func getNewsList(html: String) throws -> NewsListResult {
        let doc = try SwiftSoup.parse(html)
        
        var totalCountText = try doc.select("span.p_t").first()?.text() ?? ""
        totalCountText = totalCountText.replacingOccurrences(of: "共", with: "")
        totalCountText = totalCountText.replacingOccurrences(of: "条", with: "")
        let totalCount = Int(totalCountText) ?? 0
        
        guard let list = try doc.select("ul.ul-news").first() else {
            throw NewsError.contentNotFound
        }
        let items = try list.getElementsByTag("li")
        var result: [NewsListItem] = []
        for item in items {
            let link = try item.select("div.txt").first()?.getElementsByTag("a").first()
            let title = try link?.text()
            let url = try link?.attr("href")
            let detail = try item.getElementsByTag("p").first()?.text()
            let newsItem = NewsListItem(title: title ?? "",
                                        detail: detail ?? "",
                                        path: url ?? "",
                                        imageUrl: nil)
            result.append(newsItem)
        }
        return (totalCount, result)
    }
    
    static private func getNewsPersonList(html: String) throws -> NewsListResult {
        let doc = try SwiftSoup.parse(html)
        
        var totalCountText = try doc.select("span.p_t").first()?.text() ?? ""
        totalCountText = totalCountText.replacingOccurrences(of: "共", with: "")
        totalCountText = totalCountText.replacingOccurrences(of: "条", with: "")
        let totalCount = Int(totalCountText) ?? 0
        
        let items = try doc.select("div.hot-new")
        var result: [NewsListItem] = []
        for item in items {
            let link = try item.getElementsByTag("h3").first()?.getElementsByTag("a").first()
            let title = try link?.text()
            let url = try link?.attr("href")
            let detail = try item.getElementsByTag("p").first()?.text()
            let image = try item.getElementsByTag("img").first()?.attr("src")
            let newsItem = NewsListItem(title: title ?? "",
                                        detail: detail ?? "",
                                        path: url ?? "",
                                        imageUrl: image == nil ? nil : URL(string: "http://news.nepu.edu.cn/\(image ?? "")"))
            result.append(newsItem)
        }
        return (totalCount, result)
    }
    
    static private func getNewsDetail(html: String) throws -> NewsDetail {
        let doc = try SwiftSoup.parse(html)
        
        guard let div = try doc.select("div.m-text").first() else {
            throw NewsError.contentNotFound
        }
        
        let title = try div.getElementsByTag("h1").first()?.text()
        let info = try div.select("div.info").select("span").first()?.text()
        
        var contents: [NewsDetail.Content] = []
        guard let elements = try div.select("div.v_news_content").first()?.children() else {
            throw NewsError.contentNotFound
        }
        for element in elements {
            var text = ""
            for child in element.getChildNodes() {
                if let node = child as? TextNode {
                    contents.append(.text(text: node.text()))
                } else if let node = child as? Element {
                    let tagName = node.tagName()
                    if tagName == "span" {
                        text.append(try node.text())
                    } else {
                        if !text.isEmpty {
                            contents.append(.text(text: text))
                            text = ""
                        }
                        if tagName == "img" {
                            let url = try node.attr("src")
                            contents.append(.image(url: URL(string: "http://news.nepu.edu.cn/\(url)")))
                        }
                    }
                }
            }
            if !text.isEmpty {
                contents.append(.text(text: text))
            }
        }
        
        return NewsDetail(title: title ?? "", info: info ?? "", contents: contents)
    }
}
