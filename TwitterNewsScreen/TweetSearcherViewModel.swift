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
    enum NetworkState {
        case none
        case connecting
    }

    let networkingState = Variable<NetworkState>(.none)
    private let disposeBag = DisposeBag()

    init() {
    }

    func search(for queryString: String) -> Observable<[TwitterStatus]> {
        return makeClient()
            .do(onSubscribe: { self.networkingState.value = .connecting },
                onDispose: { self.networkingState.value = .none })
            .flatMap { $0.search(for: queryString) }
            .map { (results, _) in results }
    }

    private func makeClient() -> Observable<TwitterClient> {
        return TwitterAccountRequester.request().map { TwitterClient(account: $0.first!) }
    }
}
