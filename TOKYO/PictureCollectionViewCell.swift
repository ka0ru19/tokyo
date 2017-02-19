//
//  PictureCollectionViewCell.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/15.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {

    // storyBoardでAspectFitに設定
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(image: UIImage){
        imageView.image = image
    }

}
