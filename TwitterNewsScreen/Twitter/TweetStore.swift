//
//  TweetStore.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/20.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation

protocol TweetStorable {
    func append(_ tweet: Tweet)
    func append(_ tweets: [Tweet])
    func fetch() -> [Tweet]
    var count: Int { get }
}

final class TweetStore: TweetStorable {
    let lock = NSLock()
    var array = [Tweet]()
    var count: Int {
        return array.count
    }

    func append(_ tweets: [Tweet]) {
        synchronized {
            array.append(contentsOf: tweets)
        }
    }

    func append(_ tweet: Tweet) {
        synchronized {
            array.append(tweet)
        }
    }

    func fetch() -> [Tweet] {
        return array
    }

    private func synchronized(_ block: () -> Void) {
        lock.lock()
        block()
        lock.unlock()
    }
}
