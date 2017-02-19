//
//  ImageScreenViewController.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImageScreenViewController: UIViewController {
    enum LaunchOption {
        case keyword(String)
        case screenName(String)
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    let viewModel = TweetSearcherViewModel()
    let disposeBag = DisposeBag()

    var launchOption: LaunchOption?
    var timer: Timer?
    var currentIndexPath: IndexPath? {
        return self.collectionView.indexPathsForVisibleItems.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.pagingToNext()
        }

        guard case let .keyword(keyword) = launchOption! else { return }
        viewModel
            //.show(forId: "830745950922551296")
            //.map { tweet in [tweet, tweet, tweet, tweet, tweet, tweet, tweet] }
            .search(for: keyword)
            .do(onNext: { [weak self] _ in self?.timer?.fire() })
            .bindTo(
                collectionView.rx.items(cellIdentifier: ImageScreenCell.identifier, cellType: ImageScreenCell.self)
            ) { (_, element, cell) in
                let summary = MediaTweetSummarizer.summary(element)
                cell.render(for: summary)
            }.disposed(by: disposeBag)
        
        closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true, completion: nil)})
            .disposed(by: disposeBag)
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

    func pagingToNext() {
        print("page! \(self.currentIndexPath)")
        guard let currentIndexPath = self.currentIndexPath else { return }

        let max = self.collectionView.numberOfItems(inSection: currentIndexPath.section)
        if max > 0 && currentIndexPath.item < max - 1 {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
