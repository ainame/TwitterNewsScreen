//
//  SearchMetadata.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Mapper

struct SearchMetadata: Mappable {
    let maxId: String
    let sinceId: String
    let refreshURL: String
    let nextResults: String?
    let count: Int
    let completedIn: Double
    let query: String

    init(map: Mapper) throws {
        try maxId = map.from("max_id_str")
        try sinceId = map.from("since_id_str")
        try refreshURL = map.from("refresh_url")
        nextResults = map.optionalFrom("next_results")
        try count = map.from("count")
        try completedIn = map.from("completed_in")
        try query = map.from("query")
    }
}
