//
//  TwitterStatusMedia.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct TwitterStatusMedia: Mappable {
    enum `Type`: String {
        case photo
        case video
    }
    let URL: URL
    let mediaURL: URL
    let expandedURL: URL
    let displayURL: URL
    let type: `Type`

    init(map: Mapper) throws {
        try URL = map.from("url")
        try mediaURL = map.from("media_url_https")
        try expandedURL = map.from("expanded_url")
        try displayURL = map.from("display_url")
        try type = map.from("type", transformation: { str in Type(rawValue: str as! String)! })
    }
}
