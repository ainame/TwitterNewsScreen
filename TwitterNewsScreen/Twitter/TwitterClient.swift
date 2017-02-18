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

    func timeline() -> Observable<JSON> {
        return Observable.create { observer in
            self.swifter.getHomeTimeline(success: { json in
                observer.onNext(json)
            }, failure: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }

    }
}
