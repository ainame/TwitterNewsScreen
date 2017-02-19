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

    func show(forId: String) -> Observable<Tweet> {
        return makeClient()
            .flatMap { $0.show(forId: forId) }
            .observeOn(MainScheduler.instance)
            .do(onNext: { tweet in self.store([tweet]) },
                onSubscribe: { self.networkState.value = .connecting },
                onDispose: { self.networkState.value = .none })
    }

    func search(for queryString: String, with searchMetadata: SearchMetadata? = nil) -> Observable<([Tweet], SearchMetadata)> {
        return makeClient()
            .flatMap { $0.searchMedia(for: queryString, with: searchMetadata) }
            .filter { _, searchMetadata in searchMetadata.count > 0 }
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
