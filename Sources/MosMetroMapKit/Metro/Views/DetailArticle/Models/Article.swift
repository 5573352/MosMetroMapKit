//
//  Article.swift
//
//  Created by Сеня Римиханов on 14.08.2020.
//

import Foundation

struct ArticlesResponse {
    let articles: [Any]
    let totalPages: Int
    let totalItems: Int
    
    static func map(_ json: JSON, articles: [Any]) -> ArticlesResponse {
        return ArticlesResponse(articles: articles,
                                totalPages: json["data"]["totalPages"].intValue,
                                totalItems: json["data"]["totalElements"].intValue)
    }
}

struct Article {
    let title_ru: String
    let title_en: String
    let mainImageURL: String?
    let postDate: Date
    let contentBlocks: [Content]
    let backgroundColorHex: String
    
    struct Content {
        let content: String
        let type: ContentType
        
        enum ContentType: String {
            case title = "TITLE"
            case image = "IMAGE"
            case text = "TEXT"
            case html = "HTML"
        }
    }
}

extension Article {
    
    static func mapSingle(_ json: JSON) -> Article {
        return Article(title_ru: json["data"]["title"].stringValue,
                       title_en: json["data"]["title"].stringValue,
                       mainImageURL: json["data"]["mainImg"].stringValue,
                       postDate: Date(milliseconds: json["data"]["createdDate"].intValue) ,
                       contentBlocks: json["data"]["newsElements"].compactMap { Content(content: $0.1["content"].stringValue, type: Content.ContentType(rawValue: $0.1["type"].stringValue) ?? .text)  },
                       backgroundColorHex: json["data"]["color"].stringValue)
    }
    
    static func map(_ json: JSON) -> [Article]? {
        var articles = [Article]()
        if let itemsArray = json["data"]["items"].array {
            for item in itemsArray {
                let article = Article(title_ru: item["title"].stringValue,
                                      title_en: item["title"].stringValue,
                                      mainImageURL: item["mainImg"].stringValue,
                                      postDate: Date(milliseconds: item["createdDate"].intValue) ,
                                      contentBlocks: item["newsElements"].compactMap { Content(content: $0.1["content"].stringValue, type: Content.ContentType(rawValue: $0.1["type"].stringValue) ?? .text)  },
                                      backgroundColorHex: item["color"].stringValue)
                articles.append(article)
            }
        }
        return articles
    }
}


