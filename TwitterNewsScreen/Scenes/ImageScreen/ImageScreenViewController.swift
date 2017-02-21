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

    static let storeCapacity = 500
    
    let viewModel = TweetSearcherViewModel(store: TweetStore(limit: ImageScreenViewController.storeCapacity))
    let disposeBag = DisposeBag()

    var launchOption: LaunchOption?
    var query: ((String?) -> Observable<([Tweet], String)>?)?
    var maxId: String?

    var pagingTimer: Timer?
    var pollingTimer: Timer?
    var currentIndexPath: IndexPath? {
        return self.collectionView.indexPathsForVisibleItems.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.pollingTweets()
        }

        query = { [weak self, launchOption] maxId in
            guard let launchOption = launchOption else { fatalError("must given launch option") }
            switch launchOption {
            case .keyword(let keyword):
                return self?.viewModel.search(for: keyword, since: maxId)
            case .screenName(let screenName):
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
        guard let currentIndexPath = self.currentIndexPath else { return }

        let max = self.collectionView.numberOfItems(inSection: currentIndexPath.section)
        if max > 0 && currentIndexPath.item < max - 1 {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func pollingTweets() {
        print("polling")
        pagingTimer?.invalidate()
        pagingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.pagingToNext()
        }
        guard let query = query else { fatalError() }
        query(maxId)!
            .do(onNext: { [weak self] _, maxId in
                self?.pagingTimer?.fire()
                self?.maxId = maxId
            })
            .subscribe().disposed(by: disposeBag)
    }
}
