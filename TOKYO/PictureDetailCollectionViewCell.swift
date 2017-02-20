//
//  PictureDetailCollectionViewCell.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

protocol DetailCellDelegate {
    func showAlertFromDetailCell()
}

class PictureDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numOfLikeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var countOfLike = 0
    var post = PostModel()
    var isLike = false
    
    let ud = UserDefaults.standard
    
    var delegate: DetailCellDelegate?
    
    var selfUid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selfUid = ud.object(forKey: "uid") as? String
    }

    @IBAction func likeButtonTapped(sender: UIButton) {
        
        guard let uid = ud.object(forKey: "uid") as? String else {
            showAlertOnVC()
            return
        }
        
        if isLike { // like -> unlike
            isLike = false
            likeButton.setImage(UIImage(named: "blackHeart.png"), for: .normal)
            countOfLike -= 1
            post.unlike(uid: uid)
        }
        else { // unlike -> like
            isLike = true
            likeButton.setImage(UIImage(named: "redHeart.png"), for: .normal)
            countOfLike += 1
            post.like(uid: uid)
        }
        
        numOfLikeLabel.text = String(countOfLike)
        
    }

    func setCell(post: PostModel) {
        self.post = post
        imageView.image = post.image
        nameLabel.text = post.userName
        countOfLike = post.likeUidArray.count
        numOfLikeLabel.text = String(countOfLike)
        
        likeButton.setImage(UIImage(named: "blackHeart.png"), for: .normal)
        if selfUid != nil {
            for uid in post.likeUidArray {
                if selfUid == uid {
                    isLike = true
                    likeButton.setImage(UIImage(named: "redHeart.png"), for: .normal)
                    break
                }
            }
        }
    }
    
    func showAlertOnVC() {
        
        self.delegate?.showAlertFromDetailCell()
        
    }
    
    
}
