//
//  FullScreenFlowLayout.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit

class FullScreenFlowLayout: UICollectionViewFlowLayout {
    func setup(root view: UIView) {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        itemSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        scrollDirection = UICollectionViewScrollDirection.horizontal
    }
}
