//
//  PictureDetailCollectionViewCell.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class PictureDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numOfLikeLabel: UILabel!
    
    var countOfLike = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func likeButton(sender: UIButton) {
        countOfLike += 1
        numOfLikeLabel.text = String(countOfLike)
        
    }

    func setCell(post: PostModel) {
        imageView.image = post.image
        nameLabel.text = post.userName
        numOfLikeLabel.text = String(countOfLike)
    }
    
    
    
}
