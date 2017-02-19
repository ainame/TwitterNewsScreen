//
//  User.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct User: Mappable {
    let id: String
    let name: String
    let screenName: String
    let profileImageUrl: URL

    init(map: Mapper) throws {
        try id = map.from("id_str")
        try name = map.from("name")
        try screenName = map.from("screen_name")
        try profileImageUrl = map.from("profile_image_url_https")
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
