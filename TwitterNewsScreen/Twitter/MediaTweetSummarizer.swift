//
//  MediaTweetSummarizer.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import SwiftDate

struct MediaTweetSummary {
    let type: PresentationType
    let URL: URL
    let user: User
    let text: String
    let createdAt: DateInRegion
}

struct MediaTweetSummarizer {
    static let noImageAvailable = "https://placeholdit.imgix.net/~text?txtsize=33&txt=No+Image+Available&w=350&h=150"

    static func summary(_ tweet: Tweet) -> MediaTweetSummary {
        if let extendedMedia = tweet.extendedMedia {
            let index = Int(arc4random() % UInt32(extendedMedia.count))
            return MediaTweetSummary(
                type: PresentationType(rawValue: extendedMedia[index].type.rawValue)!,
                URL: extendedMedia[index].mediaURL,
                user: tweet.user,
                text: tweet.text,
                createdAt: tweet.createdAt
            )
        }

        if let media = tweet.entities.media?.first {
            return MediaTweetSummary(
                type: PresentationType(rawValue: media.type.rawValue)!,
                URL: media.mediaURL,
                user: tweet.user,
                text: tweet.text,
                createdAt: tweet.createdAt
            )
        }

        if let urls = tweet.entities.urls.first {
            return MediaTweetSummary(
                type: .ogImage,
                URL: urls.expandedURL,
                user: tweet.user,
                text: tweet.text,
                createdAt: tweet.createdAt
            )
        }

        return MediaTweetSummary(
            type: .photo,
            URL: URL(string: MediaTweetSummarizer.noImageAvailable)!,
            user: tweet.user,
            text: tweet.text,
            createdAt: tweet.createdAt
        )
    }
}
