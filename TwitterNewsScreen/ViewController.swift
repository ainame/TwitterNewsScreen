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

class ViewController: UIViewController {
    @IBOutlet weak var authButton: UIButton!
    private let disposeBag = DisposeBag()
    private let viewModel = TweetSearcherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        authButton.rx.controlEvent(.touchUpInside)
            .asObservable()
            .flatMap { _ in self.viewModel.search(for: "どらえもん") }
            .subscribe(onNext: { results in
                print(results)
            }, onError: { error in
                print(error)
            })
            .addDisposableTo(disposeBag)
    }

}
