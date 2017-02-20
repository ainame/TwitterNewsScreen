//
//  TweetSearcherViewModel.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import RxSwift
import Accounts

struct TweetSearcherViewModel {
    enum NetworkState: String {
        case none
        case connecting
    }

    let networkState = Variable<NetworkState>(.none)
    let tweetStream: Variable<[Tweet]>

    // use variable for atomic access
    private let client = Variable<TwitterClient?>(nil)
    private let store: TweetStorable

    init(store: TweetStorable) {
        self.store = store
        tweetStream = Variable<[Tweet]>(store.fetch())
    }

    func lookupUser(by screenName: String) -> Observable<User> {
        return makeClient()
            .flatMap { $0.showUser(by: screenName) }
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: { self.networkState.value = .connecting },
                onDispose: { self.networkState.value = .none })
    }

    func search(for queryString: String, since sinceId: String? = nil) -> Observable<([Tweet], String)> {
        return makeClient()
            .flatMap { $0.searchMedia(for: queryString, since: sinceId) }
            .filter { _, searchMetadata in searchMetadata.count > 0 }
            .map { tweets, searchMetadata in (tweets, searchMetadata.maxId) }
            .observeOn(MainScheduler.instance)
            .do(onNext: { tweets, _ in self.store(tweets) },
                onSubscribe: { self.networkState.value = .connecting },
                onDispose: { self.networkState.value = .none })
    }

    func timeline(by screenName: String, since sinceId: String? = nil) -> Observable<([Tweet], String)> {
        return makeClient()
            .map { client in (client, client.showUser(by: screenName)) }
            .flatMap { client, user in user.flatMap { user in client.timeline(for: user.id, since: sinceId)} }
            .filter { tweets in tweets.count > 0 }
            .map { tweets in (tweets, tweets.last!.id) }
            .observeOn(MainScheduler.instance)
            .do(onNext: { tweets, _ in self.store(tweets) },
                onSubscribe: { self.networkState.value = .connecting },
                onDispose: { self.networkState.value = .none })
    }

    private func store(_ tweets: [Tweet]) {
        store.append(tweets.reversed()) // todo: sort by createdat
        store.fetch().forEach { tweet in
            print("id=\(tweet.id) text=\"\(tweet.text)\"")
        }
        tweetStream.value = store.fetch()
    }

    // cache client instance
    private func makeClient() -> Observable<TwitterClient> {
        if let value = self.client.value {
            return Observable.just(value)
        }
        return TwitterAccountRequester.request()
            .map { TwitterClient(account: $0.first!) }
            .do(onNext: { client in self.client.value = client })
    }
}
