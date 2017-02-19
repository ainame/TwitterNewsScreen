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

    func show(forId: String) -> Observable<Tweet> {
        return Observable.create { observer in
            self.swifter.getTweet(forID: forId, includeEntities: true, success: { json in
                let dictionary = TwitterClient.convertRecursive(json) as! NSDictionary
                let tweet = Tweet.from(dictionary)!
                observer.onNext(tweet)
                observer.onCompleted()
            }, failure: observer.onError)

            return Disposables.create()
        }
    }

    func search(for queryStrng: String) -> Observable<([Tweet], SearchMetadata)> {
        return Observable.create { observer in
            self.swifter.searchTweet(using: queryStrng, includeEntities: true, success: { json, searchMetadataJSON in
                let array = TwitterClient.convertRecursive(json) as! NSArray
                let statuses = Tweet.from(array)!
                let dictionary = TwitterClient.convertRecursive(searchMetadataJSON) as! NSDictionary
                let searchMetadata = SearchMetadata.from(dictionary)!
                observer.onNext((statuses, searchMetadata))
                observer.onCompleted()
            }, failure: observer.onError)

            return Disposables.create()
        }
    }

    func searchMedia(for queryString: String) -> Observable<([Tweet], SearchMetadata)> {
        return search(for: "\(queryString) filter:media")
    }

    func timeline() -> Observable<[Tweet]> {
        return Observable.create { observer in
            let userID: String = self.account.value(forKeyPath: "properties.user_id")! as! String
            self.swifter.getTimeline(for: userID, success: { json in
                let array = TwitterClient.convertRecursive(json) as! NSArray
                let statuses = Tweet.from(array)
                observer.onNext(statuses!)
                observer.onCompleted()
            }, failure: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    // workaround to use mapper with swifter
    static func convertRecursive(_ json: SwifteriOS.JSON) -> Any {
        switch json {
        case .array(let array):
            let newArray = array
                .map { elem in TwitterClient.convertRecursive(elem) }
            return NSArray(array: newArray)
        case .object(let dictionary):
            let newDictionary = NSMutableDictionary()
            dictionary.forEach { key, value in
                newDictionary[key] = TwitterClient.convertRecursive(value)
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
