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
        case keyword(keyword: String, pollingInterval: Int, pagingInterval: Int)
        case screenName(screenName: String, pollingInterval: Int, pagingInterval: Int)
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    static let storeCapacity = 500

    let viewModel = TweetSearcherViewModel(store: TweetStore(limit: ImageScreenViewController.storeCapacity))
    let disposeBag = DisposeBag()

    var launchOption: LaunchOption?
    var query: ((String?) -> Observable<([Tweet], String)>?)?
    var maxId: String?

    var pollingInterval: Int = 10
    var pollingTimer: Timer?

    var pagingInterval: Int = 5
    var pagingTimer: Timer?

    var currentIndexPath: IndexPath {
        return self.collectionView.indexPathsForVisibleItems.first!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        query = { [weak self, launchOption] maxId in
            guard let launchOption = launchOption else { fatalError("must given launch option") }
            switch launchOption {
            case .keyword(let keyword, let pollingInterval, let pagingInterval):
                self?.pollingInterval = pollingInterval
                self?.pagingInterval = pagingInterval
                return self?.viewModel.search(for: keyword, since: maxId)
            case .screenName(let screenName, let pollingInterval, let pagingInterval):
                self?.pollingInterval = pollingInterval
                self?.pagingInterval = pagingInterval
                return self?.viewModel.timeline(by: screenName, since: maxId)
            }
        }

        viewModel.tweetStream.asObservable()
            .bindTo(
                collectionView.rx.items(cellIdentifier: ImageScreenCell.identifier, cellType: ImageScreenCell.self)
            ) { (_, element, cell) in
                let summary = MediaTweetSummarizer.summary(element)
                cell.render(for: summary)
            }.disposed(by: disposeBag)

        closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true, completion: nil)})
            .disposed(by: disposeBag)

        pollingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(pollingInterval), repeats: true) { [weak self] _ in
            self?.pollingTweets()
        }
        pollingTimer?.fire()
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

        let max = self.collectionView.numberOfItems(inSection: currentIndexPath.section)
        if max > 0 && currentIndexPath.item < max - 1 {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func pollingTweets() {
        print("polling")

        pagingTimer?.invalidate()
        pagingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(pagingInterval), repeats: true) { [weak self] _ in
            self?.pagingToNext()
        }
        guard let query = query else { fatalError() }
        query(maxId)!
            .subscribe(onNext: { [weak self, currentIndexPath, pollingInterval, pagingInterval] tweets, maxId in
                guard let strongSelf = self else { return }
                if tweets.isEmpty {
                    let scrollback = pollingInterval / pagingInterval
                    let nextIndexPath = IndexPath(item: currentIndexPath.item - scrollback,
                                                  section: currentIndexPath.section)
                    strongSelf.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                }
                strongSelf.pagingTimer?.fire()
                strongSelf.maxId = maxId
            })
            .disposed(by: disposeBag)
    }
}
