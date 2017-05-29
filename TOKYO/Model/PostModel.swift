//
//  PostClass.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PostModel {
    var postId: String = "" // 写真のid
    var userUid: String = "" // 投稿したuserのuid
    var userName: String = "" // ユーザ名
    var image: UIImage!
    var countOfLike: Int = 0
    var likeUidArray: [String] = []
    
    func upLoad(user: UserModel, image: UIImage, vc: ViewController) {
        
        let pictureRef = FIRDatabase.database().reference().child("list").child("picture")
        let newRef = pictureRef.childByAutoId()
        let newKey = newRef.key
        pictureRef.child(newKey).setValue(["postUserUid": user.uid,
                                           "countOfLike": "0",
                                           "date": getNowDateString()])
        let userRef = FIRDatabase.database().reference().child("list/user")
        userRef.child(user.uid).child("postIdArray").child(String(user.postIdCount)).setValue(newKey)
        
        
        let storageRef = FIRStorage.storage().reference(forURL: "gs://tokyo-27015.appspot.com")
        
        if let data = getResizedImage(image: image) {
            
            let riversRef = storageRef.child("images/\(newKey)")
            riversRef.put(data, metadata: nil, completion: { metaData, error in
                if let data = metaData {
                    print("up成功->\(data)")
                    user.getUserInfo(uid: user.uid) // userDataの更新
                    vc.successUpLoad()
                }
                if let theError = error {
                    print(theError)
                    vc.failureUpLoad(errorMessage: "ネットワークに問題の可能性")
                }
            })
        }
        
    }
    
    func getResizedImage(image: UIImage) -> Data? {
        let maxSize: Float = 70 * 1024 // 70 KB = 0.070 MB
        let originalImage = image
        let originalData: NSData = NSData(data: UIImageJPEGRepresentation(originalImage, 1.0)!)
        let rate = Float(originalData.length) / maxSize
        let reduction: Float = rate > 1.0 ? rate : 1.0
        print("originalDataSize: \(Float(originalData.length) / 1024.0)KB -> rate: \(rate)")
        
        return UIImageJPEGRepresentation(originalImage, CGFloat(1 / reduction))
    }
    
    func like(uid: String) {
        
        let pictureRef = FIRDatabase.database().reference().child("list/picture/\(self.postId)/likeUid")
        pictureRef.child(uid).setValue(["date": getNowDateString()])
    }
    
    func unlike(uid: String) {
        let pictureRef = FIRDatabase.database().reference().child("list/picture/\(self.postId)/likeUid")
        pictureRef.child(uid).removeValue()
    }
    
    func getNowDateString() -> String {
        // 時刻を取得
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium // -> ex: 2016/10/29
        formatter.timeStyle = .medium // -> ex: 13:20:08
        
        return formatter.string(from: now)
        
    }
    
    func deletePostById(id: String) {
        DispatchQueue.global().async {
            
            // postデータベースから削除
            let pictureRef = FIRDatabase.database().reference().child("list/picture/\(id)")
            pictureRef.removeValue()
            
            DispatchQueue.main.async {
                print("postデータベースから削除")
            }
            
            // storageデータベースから削除
            let storageRef = FIRStorage.storage().reference(forURL: "gs://tokyo-27015.appspot.com")
            storageRef.child("images/\(id)").delete(completion: nil)
            
            DispatchQueue.main.async {
                print("storageデータベースから削除")
            }
            
        }
    }
    
    func spamPostById(id: String) {
        let pictureRef = FIRDatabase.database().reference().child("list/picture/\(id)")
        pictureRef.child("spamedList").childByAutoId().setValue(id)
    }
    
    func deleteSelf() {
        
        // postデータベースから削除
        let pictureRef = FIRDatabase.database().reference().child("list/picture")
        pictureRef.child(self.postId).removeValue(completionBlock: { (error, ref) in
            if let theError = error {
                print(theError.localizedDescription)
            } else {
                print("postデータベースから削除")
            }
            
        })
        
        
        // storageデータベースから削除
        let storageRef = FIRStorage.storage().reference(forURL: "gs://tokyo-27015.appspot.com")
        storageRef.child("images/\(self.postId)").delete(completion: { error -> Void in
            if let theError = error {
                print(theError.localizedDescription)
            } else {
                print("storageデータベースから削除")
            }
        })
        
    }
}
