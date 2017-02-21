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
    let timerPeriod = 1

    var launchOption: LaunchOption?
    var query: ((String?) -> Observable<([Tweet], String?)>?)?
    var maxId: String?

    var pollingInterval: Int = 10
    var pagingInterval: Int = 5

    var currentIndexPath: IndexPath {
        return self.collectionView.indexPathsForVisibleItems.first ?? IndexPath(item: 0, section: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

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

        switch launchOption! {
        case .keyword(let keyword, let pollingInterval, let pagingInterval):
            self.pollingInterval = pollingInterval
            self.pagingInterval = pagingInterval
            query = { [weak self] maxId in self?.viewModel.search(for: keyword, since: maxId) }
        case .screenName(let screenName, let pollingInterval, let pagingInterval):
            self.pollingInterval = pollingInterval
            self.pagingInterval = pagingInterval
            query = { [weak self] maxId in self?.viewModel.timeline(by: screenName, since: maxId) }
        }

        Observable<Int>
            .interval(RxTimeInterval(timerPeriod), scheduler: MainScheduler.instance)
            .subscribe(onNext: dispatchTimerEvent, onError: { error in print(error) })
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

    func dispatchTimerEvent(time: Int) {
        if time % pollingInterval == 0 && time % pagingInterval == 0 {
            print("polling & paging")
            pollingTweets()
                .do(onNext: didRequest).map { _ in () }
                .subscribe(onNext: pagingToNext, onError: { error in print(error) })
                .disposed(by: disposeBag)
        } else if time % pollingInterval == 0 {
            print("polling")
            pollingTweets()
                .subscribe(onNext: didRequest, onError: { error in print(error) })
                .disposed(by: disposeBag)
        } else if time % pagingInterval == 0 {
            print("page! \(self.currentIndexPath)")
            pagingToNext()
        }
    }

    func pollingTweets() -> Observable<([Tweet], String?)> {
        return query!(maxId)!.observeOn(MainScheduler.instance)
    }

    func pagingToNext() {
        print("pagingtonext")
        let max = self.collectionView.numberOfItems(inSection: currentIndexPath.section) - 1
        if max > 0 && currentIndexPath.item < max {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func didRequest(_ tweets: [Tweet], _ maxId: String?) {
        print("didrequest")
        let currentItem = currentIndexPath.item
        let max = self.collectionView.numberOfItems(inSection: currentIndexPath.section) - 1
        if tweets.isEmpty && currentItem == max {
            let scrollback: Int = [(pollingInterval / pagingInterval), max].min()!
            let nextIndexPath = IndexPath(item: currentIndexPath.item - scrollback,
                                          section: currentIndexPath.section)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }

        if let maxId = maxId {
            self.maxId = maxId
        }
    }
}
