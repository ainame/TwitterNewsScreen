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
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var networkStateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    private let disposeBag = DisposeBag()
    private let viewModel = TweetSearcherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let observable = authButton.rx.tap.asObservable()
        observable.flatMapLatest { self.viewModel.search(for: "ゼルダ").catchErrorJustReturn([]) }
            .subscribe(onNext: { tweets in
                self.setTweet(tweet: tweets[0])
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

    func setTweet(tweet: Tweet) {
        self.imageView.kf.setImage(with: tweet.extendedMedia?[0].mediaURL)
    }
}
