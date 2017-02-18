//
//  ViewController.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/18.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Accounts
import SwifteriOS

class ViewController: UIViewController {
    @IBOutlet weak var authButton: UIButton!
    private let disposeBag = DisposeBag()
    private var client: TwitterClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        authButton.rx.controlEvent(.touchUpInside)
            .flatMap { TwitterAccountRequester.request() }
            .flatMap { (accounts: [ACAccount]) -> Observable<JSON> in
                let client = TwitterClient(account: accounts.first!)
                return client.timeline()
            }
            .subscribe { event in
                switch event {
                case .next(let json):
                    print(json)
                case .completed:
                    break
                case .error(let error):
                    print(error)
                }
            }
            .addDisposableTo(disposeBag)
    }

}
