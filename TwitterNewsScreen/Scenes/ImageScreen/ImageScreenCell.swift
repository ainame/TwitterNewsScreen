//
//  ImageScreenCell.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate
import Kanna

enum PresentationType: String {
    case photo, video, animated_gif, ogImage
}

protocol TweetSummaryType {
    var type: PresentationType { get }
    var URL: URL { get }
    var user: User { get }
    var text: String { get }
    var createdAt: DateInRegion { get }
}
extension MediaTweetSummary: TweetSummaryType {}

class ImageScreenCell: UICollectionViewCell {
    static let identifier = "ImageScreenCell"
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    func render(for summary: TweetSummaryType?) {
        guard let summary = summary else { return }

        let formattedDate = summary.createdAt.string(dateStyle: .long, timeStyle: .medium)
        nameLabel.text = "\(summary.user.name)(@\(summary.user.screenName)) - \(formattedDate)"
        textLabel.text = summary.text
        profileImageView.kf.setImage(with: summary.user.profileImageUrl)
        imageView.kf.setImage(with: nil)

        displayMedia(summary: summary)
    }

    func displayMedia(summary: TweetSummaryType) {
        switch summary.type {
        case .photo:
            imageView.kf.setImage(with: summary.URL)
        case .ogImage:
            DispatchQueue.global().async {  [weak self] in
                let html = Kanna.HTML(url: summary.URL, encoding: .utf8)
                let urlString = html?.head?.xpath("meta").filter { $0["property"]?.hasPrefix("og:image") ?? false }.first?["content"]
                DispatchQueue.main.async {
                    if let urlString = urlString {
                        self?.imageView.kf.setImage(with: URL(string: urlString))
                    } else {
                        self?.imageView.kf.setImage(with: URL(string: MediaTweetSummarizer.noImageAvailable))
                    }
                }
            }
        case .video, .animated_gif:
            print("currently do not support \(summary.type)")
        }
    }
}
