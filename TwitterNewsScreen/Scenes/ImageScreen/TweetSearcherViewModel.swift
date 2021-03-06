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

class TweetSearcherViewModel {
    enum NetworkState: String {
        case none
        case connecting
    }

    lazy var networkState: Observable<NetworkState> = self._networkState.asObservable()
    lazy var tweetStream: Observable<[Tweet]> = self._tweetStream.asObservable()

    private let _networkState = Variable<NetworkState>(.none)
    private let _tweetStream: Variable<[Tweet]>
    private let client = Variable<TwitterClient?>(nil) // use variable for atomic access
    private let store: TweetStorable

    init(store: TweetStorable) {
        self.store = store
        _tweetStream = Variable<[Tweet]>(store.fetch())
    }

    func lookupUser(by screenName: String) -> Observable<User> {
        return makeClient()
            .flatMap { $0.showUser(by: screenName) }
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: { [weak self] in self?._networkState.value = .connecting },
                onDispose: { [weak self] in self?._networkState.value = .none })
    }

    func search(for queryString: String, since sinceId: String? = nil) -> Observable<([Tweet], String?)> {
        return makeClient()
            .flatMap { $0.searchMedia(for: queryString, since: sinceId) }
            .map { tweets, searchMetadata in
                let notRetweeted = tweets.filter { !$0.retweeted }
                return (notRetweeted, searchMetadata.maxId)
            }.observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] tweets, _ in self?.store(tweets) },
                onSubscribe: { [weak self] in self?._networkState.value = .connecting },
                onDispose: { [weak self] in self?._networkState.value = .none })
    }

    func timeline(by screenName: String, since sinceId: String? = nil) -> Observable<([Tweet], String?)> {
        return makeClient()
            .map { client in (client, client.showUser(by: screenName)) }
            .flatMap { client, user in user.flatMap { user in client.timeline(for: user.id, since: sinceId)} }
            .map { tweets in
                let notRetweeted = tweets.filter { !$0.retweeted }
                let maxId = tweets.map { $0.id }.max()
                return (notRetweeted, maxId)
            }.observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] tweets, _ in self?.store(tweets) },
                onSubscribe: { [weak self] in self?._networkState.value = .connecting },
                onDispose: { [weak self] in self?._networkState.value = .none })
    }

    private func store(_ tweets: [Tweet]) {
        store.append(tweets.sorted { $0.createdAt < $1.createdAt })
        _tweetStream.value = store.fetch()
    }

    // cache client instance
    private func makeClient() -> Observable<TwitterClient> {
        if let value = self.client.value {
            return Observable.just(value)
        }
        return TwitterAccountRequester.request()
            .map { TwitterClient(account: $0.first!) }
            .do(onNext: { [weak self] client in self?.client.value = client })
    }
}
