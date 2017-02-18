//
//  TwitterStatus.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct TwitterStatus: Mappable {
    let id: Int
    let user: TwitterUser
    let text: String
    let retweetCount: Int
    let favoritesCount: Int
    let createdAt: Date
    let media: [TwitterStatusMedia]?

    init(map: Mapper) throws {
        try id = map.from("id")
        try user = map.from("user")
        try text = map.from("text")
        try retweetCount = map.from("retweet_count")
        try favoritesCount = map.from("favorite_count")
        try createdAt = map.from("created_at") { _ in Date() } // TODO parse date string
        media = map.optionalFrom("extended_entities.media")
    }
}
