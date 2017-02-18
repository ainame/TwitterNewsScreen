//
//  TwitterSearchMetadata.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct TwitterSearchMetadata: Mappable {
    let maxId: Int
    let sinceId: Int
    let refreshURL: URL
    let nextResults: String
    let count: Int
    let completedIn: Double
    let query: String

    init(map: Mapper) throws {
        try maxId = map.from("max_id")
        try sinceId = map.from("since_id")
        try refreshURL = map.from("refresh_url")
        try nextResults = map.from("next_results")
        try count = map.from("count")
        try completedIn = map.from("completed_in")
        try query = map.from("query")
    }
}
