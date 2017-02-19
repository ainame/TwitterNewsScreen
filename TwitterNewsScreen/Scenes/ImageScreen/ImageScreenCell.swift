//
//  ImageScreenCell.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit

protocol TweetSummaryType {
    var type: Tweet.MediaType { get }
    var URL: URL { get }
    var user: User { get }
    var text: String { get }
    var createdAt: Date { get }
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
        imageView.kf.setImage(with: summary.URL)
        profileImageView.kf.setImage(with: summary.user.profileImageUrl)
        nameLabel.text = "\(summary.user.name)(@\(summary.user.screenName)) - \("2017.02.15")"
        textLabel.text = summary.text
    }
}