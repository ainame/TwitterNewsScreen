//
//  MediaTweetSummarizer.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation

struct MediaTweetSummary {
    let type: Tweet.MediaType
    let URL: URL
    let user: User
    let text: String
    let createdAt: Date
}

struct MediaTweetSummarizer {
    static func summary(_ tweet: Tweet) -> MediaTweetSummary? {
        if let extendedMedia = tweet.extendedMedia {
            let index = Int(arc4random() % UInt32(extendedMedia.count))
            return MediaTweetSummary(
                type: extendedMedia[index].type,
                URL: extendedMedia[index].mediaURL,
                user: tweet.user,
                text: tweet.text,
                createdAt: tweet.createdAt
            )
        }

        if let media = tweet.entities.media?.first {
            return MediaTweetSummary(
                type: media.type,
                URL: media.mediaURL,
                user: tweet.user,
                text: tweet.text,
                createdAt: tweet.createdAt
            )
        }

        return nil
    }
}
