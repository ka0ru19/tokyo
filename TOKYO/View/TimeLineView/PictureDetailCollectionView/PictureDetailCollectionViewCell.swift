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
    func showSettingAlertFromDetailCell(post: PostModel)
}

class PictureDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numOfLikeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var countOfLike: Int = 0
    
    var post: PostModel!
    var isLike: Bool = false
    
    let ud = UserDefaults.standard
    
    var delegate: DetailCellDelegate?
    
    
    //    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    //        super.init(style, reuseIdentifier: reuseIdentifier)
    //
    //        var autoresizingMask: UIViewAutoresizing = [.flexibleHeight, .flexibleWidth]
    //        // MARK: ↓これが足りなかった
    //        self.contentView.autoresizingMask = autoresizingMask
    //        // MARK: ↑これが足りなかった
    //        var nib = UINib(nibName: "MyCustomView", bundle: nil)
    //        var view: MyCustomView? = nib.instantiate(withOwner: nil, options: nil).first
    //        view?.autoresizingMask = autoresizingMask
    //        view?.frame = self.contentView.bounds
    //        self.contentView.addSubview(view)
    //
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // 基本的に使いまわしで何度も新たに生成されるわけじゃないからここに何か書くときは要注意
        
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
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
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        showSettingAlertOnVC(post: self.post)
    }
    
    func setCell(post: PostModel) {
        self.post = post
        imageView.image = post.image
        nameLabel.text = post.userName
        countOfLike = post.likeUidArray.count
        numOfLikeLabel.text = String(countOfLike)
        
        nameLabel.textColor = UIColor.black // 投稿の名前はデフォルトで黒文字
        //        settingButton.isHidden = true // 他人の投稿は設定ボタン非表示
        
        if let selfUid = ud.object(forKey: "uid") as? String {
            
            if selfUid == post.userUid {
                nameLabel.textColor = UIColor.blue // 自分の投稿なら名前を青文字にする
                //                settingButton.isHidden = false
            }
            
            isLike = false // likeはデフォルトでfalse
            likeButton.setImage(UIImage(named: "blackHeart.png"), for: .normal) // Heartはデフォルトで黒
            for likeUid in post.likeUidArray {
                if selfUid == likeUid { // 自分が既にlikeしていたらHeartを赤くする
                    isLike = true
                    likeButton.setImage(UIImage(named: "redHeart.png"), for: .normal)
                    break
                }
            }
        } else {
            print("udにuidがありませんでした")
        }
    }
    
    func showAlertOnVC() {
        // 親のVCで「ユーザ登録してください」とAlertを表示
        self.delegate?.showAlertFromDetailCell()
    }
    
    func showSettingAlertOnVC(post: PostModel) {
        // 親のVCで「この投稿を削除しますか？」とAlertを表示
        self.delegate?.showSettingAlertFromDetailCell(post: post)
    }
    
}
