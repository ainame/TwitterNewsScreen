//
//  ImageScreenViewController.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit
import RxSwift

class ImageScreenViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = TweetSearcherViewModel()
    let disposeBag = DisposeBag()
    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        viewModel.show(forId: "830745950922551296")
            .map { tweet in [tweet, tweet, tweet, tweet, tweet, tweet, tweet] }
            .bindTo(
                collectionView.rx.items(cellIdentifier: ImageScreenCell.identifier, cellType: ImageScreenCell.self)
            ) { (_, element, cell) in
                let summary = MediaTweetSummarizer.summary(element)
                cell.render(for: summary)
            }.disposed(by: disposeBag)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayout()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func setupLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        if let layout = self.collectionView.collectionViewLayout as? FullScreenFlowLayout {
            layout.setup(root: self.view)
        }
    }
}
