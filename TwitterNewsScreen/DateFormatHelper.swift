//
//  DateFormatHelper.swift
//  TwitterNewsScreen
//
//  Created by satoshi.namai on 2017/02/20.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import SwiftDate

struct DateFormatHelper {
    static let defaultRegion = Region(tz: TimeZoneName.asiaTokyo, cal: CalendarName.gregorian, loc: LocaleName.japanese)
    static let defaultParseRegion = Region(tz: TimeZoneName.asiaTokyo, cal: CalendarName.gregorian, loc: LocaleName.english)

    static func parseTwitterFormat(string: String,
                                   from fromRegion: Region = defaultParseRegion,
                                   to toRegion: Region = defaultRegion) -> DateInRegion {
        return try! DateInRegion(string: string,
                                 format: .custom("EEE MMM dd HH:mm:ss ZZZZZ yyyy"),
                                 fromRegion: fromRegion).toRegion(toRegion)
    }
}
