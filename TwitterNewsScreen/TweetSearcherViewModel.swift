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
    private let disposeBag = DisposeBag()

    init() {
    }

    func search(for queryString: String) -> Observable<[Tweet]> {
        return makeClient()
            .flatMap { $0.search(for: queryString) }
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: { self.networkState.value = .connecting },
                onDispose: { self.networkState.value = .none })
            .map { (results, _) in results }
    }

    func searchMedia(for queryString: String) -> Observable<[Tweet]> {
        return search(for: queryString)
            .map { tweets in tweets.filter { $0.media != nil } }
            .filter { tweets in !tweets.isEmpty }
    }

    private func makeClient() -> Observable<TwitterClient> {
        return TwitterAccountRequester.request().map { TwitterClient(account: $0.first!) }
    }
}
