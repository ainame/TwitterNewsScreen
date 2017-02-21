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
    let limit: Int
    let lock = NSLock()
    var array = [Tweet]()
    var count: Int {
        return array.count
    }

    init(limit: Int) {
        self.limit = limit
    }

    func append(_ tweets: [Tweet]) {
        synchronized {
            array.append(contentsOf: tweets)
            if array.count > limit {
                array.removeFirst(array.count - limit)
            }
        }
    }

    func append(_ tweet: Tweet) {
        append([tweet])
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
