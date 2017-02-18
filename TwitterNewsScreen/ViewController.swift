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

class ViewController: UIViewController {
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var networkStateLabel: UILabel!

    private let disposeBag = DisposeBag()
    private let viewModel = TweetSearcherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        authButton.rx.tap.asObservable()
            .flatMapLatest { self.viewModel.search(for: "この世界の片隅に").catchErrorJustReturn([]) }
            .subscribe(onNext: { tweets in
                print(tweets.map { $0.text }.joined())
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)

        viewModel.networkState
            .asObservable()
            .map { $0.rawValue }
            .asDriver(onErrorJustReturn: "error")
            .drive(networkStateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
