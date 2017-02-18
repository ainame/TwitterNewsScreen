//
//  TwitterClient.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Accounts
import SwifteriOS
import RxSwift

struct TwitterClient {
    private let account: ACAccount
    private let swifter: Swifter

    init(account: ACAccount) {
        self.account = account
        swifter = Swifter(account: account)
    }

    func timeline() -> Observable<[TwitterStatus]> {
        return Observable.create { observer in
            let userID: String = self.account.value(forKeyPath: "properties.user_id")! as! String
            self.swifter.getTimeline(for: userID, success: { json in
                let array = TwitterClient.convertRecursive(json) as! NSArray
                let statuses = TwitterStatus.from(array)
                observer.onNext(statuses!)
            }, failure: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    // workaround to use mapper with swifter
    static func convertRecursive(_ json: SwifteriOS.JSON) -> Any? {
        switch json {
        case .array(let array):
            let newArray = array
                .map { elem in TwitterClient.convertRecursive(elem) }
                .filter { elem in elem != nil }
            return NSArray(array: newArray)
        case .object(let dictionary):
            let newDictionary = NSMutableDictionary()
            dictionary.forEach { key, value in
                if let newValue = TwitterClient.convertRecursive(value) {
                    newDictionary[key] = newValue
                }
            }
            return newDictionary
        case .string(let string):
            return NSString(string: string)
        case .number(let double):
            return NSNumber(value: double)
        case .bool(let bool):
            return bool
        case .null:
            return NSNull()
        case .invalid:
            fatalError()
        }
    }
}
