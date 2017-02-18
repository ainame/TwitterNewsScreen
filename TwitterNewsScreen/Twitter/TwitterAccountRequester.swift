//
//  TwitterAccountInfoRequester.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import Foundation
import Accounts
import Social
import RxSwift

class TwitterAccountRequester {
    enum Errors: Error {
        case NotGranted
        case NoAccount
    }

    static func request () -> Observable<[ACAccount]> {
        return Observable.create { observer in
            let accountStore = ACAccountStore()
            let twitterAccountType =
                accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)

            accountStore.requestAccessToAccounts(with: twitterAccountType, options: nil) { (granted, error) in
                if error != nil {
                    fatalError("got unknwon error \(error)")
                }

                if granted != true {
                    observer.onError(Errors.NotGranted)
                    return
                }

                // swiftlint:disable:next force_cast
                let accounts = accountStore.accounts(with: twitterAccountType) as! [ACAccount]?
                if accounts?.count == 0 {
                    observer.onError(Errors.NoAccount)
                    return
                }

                observer.onNext(accounts!)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
