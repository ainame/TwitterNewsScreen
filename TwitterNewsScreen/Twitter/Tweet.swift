//
//  Tweet.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct Tweet: Mappable {
    let id: Int
    let user: User
    let text: String
    let retweetCount: Int
    let favoritesCount: Int
    let createdAt: Date
    let entities: Entities
    let extendedMedia: [Media]?

    init(map: Mapper) throws {
        try id = map.from("id")
        try user = map.from("user")
        try text = map.from("text")
        try retweetCount = map.from("retweet_count")
        try favoritesCount = map.from("favorite_count")
        try createdAt = map.from("created_at") { _ in Date() } // TODO parse date string
        try entities = map.from("entities")
        extendedMedia = map.optionalFrom("extended_entities.media")
    }
}

extension Tweet {
    enum MediaType: String {
        case photo
        case video
        case animated_gif
    }

    struct Media: Mappable {
        let id: Int
        let URL: URL
        let mediaURL: URL
        let expandedURL: URL
        let displayURL: String
        let type: MediaType
        let indices: [Int]

        init(map: Mapper) throws {
            try id = map.from("id")
            try URL = map.from("url")
            try mediaURL = map.from("media_url_https")
            try expandedURL = map.from("expanded_url")
            try displayURL = map.from("display_url")
            try type = map.from("type") { typeStr in MediaType(rawValue: typeStr as! String)! }
            try indices = map.from("indices")
        }
    }

    struct EntityURL: Mappable {
        let url: URL
        let displayURL: String
        let expandedURL: URL
        let indices: [Int]

        init(map: Mapper) throws {
            try url = map.from("url")
            try displayURL = map.from("display_url")
            try expandedURL = map.from("expanded_url")
            try indices = map.from("indices")
        }
    }

    struct Hashtag: Mappable {
        let text: String
        let indices: [Int]

        init(map: Mapper) throws {
            try text = map.from("text")
            try indices = map.from("indices")
        }
    }

    struct Entities: Mappable {
        let urls: [EntityURL]
        let hashtags: [Hashtag]
        let media: [Media]?
        // omit user_mentions

        init(map: Mapper) throws {
            try urls = map.from("urls")
            try hashtags = map.from("hashtags")
            media = map.optionalFrom("media")
        }
    }
}
