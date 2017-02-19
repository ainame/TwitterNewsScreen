//
//  MediaTweetSummarizer.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation

struct MediaTweetSummarizer {
    enum MediaType: String {
        case photo
        case video
        case animated_gif
    }
    struct MediaSummary {
        let type: MediaType
        let URL: URL
        let user: User
        let text: String
        let createdAt: Date
    }
    
    static func summary(tweet: Tweet) -> URL {
        if let extendedMedia = tweet.extendedMedia {
            return extendedMedia[0].mediaURL
        }
        
        if let media = tweet.entities.media {
            return extendedMedia[0].mediaURL
        }
    }
}
