//
//  UserModel.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserModel {
    var uid: String! // ユニークID AuthでFirebaseが自動で決定する
    var id: String! // 半角3~13文字 ユーザが任意で決める
    var email: String! //
    var postIdArray: [String] = []
    var likePostIdArray: [String] = []
    var postIdCount: Int! // これはfirebaseで管理しない
    
    let userRef = FIRDatabase.database().reference().child("list").child("user")
    
    let ud = UserDefaults.standard
    
    func registerAccount(id: String, mail: String, pass: String, vc: AccountRegisterViewController) {
        
        FIRAuth.auth()?.createUser(withEmail: mail, password: pass, completion: { (user, error) in
            
            //エラーなしなら、認証完了
            if let error = error {
                vc.failureNewHSRegister(errorMessage: error.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            
            print(user.uid)
            print(user.email ?? "no email -> ありえないけど")
            print("user has been signed in successfully.")
            
            self.userRef.child(user.uid).setValue(["id": id,
                                                   "email": user.email])
            
            vc.successNewAccountRegister()
            
            
            
        })
    }
    
    func login(mail: String, pass: String, vc: LoginViewController) {
        print("Firebase: userログイン開始")
        
        FIRAuth.auth()?.signIn(withEmail: mail, password: pass, completion: { (firUser, error) in
            
            print("Firebase: userログイン完了")
            
            //エラーなしなら、認証完了
            if let error = error {
                vc.failureLoing(errorMessage: error.localizedDescription)
                return
            }
            
            guard let loginUser = firUser else {
                print("loginHS: firUserの値がnilです")
                return
            }
            
            vc.successLogin(uid: loginUser.uid)
            
        })
    }
    
    func getUserInfo(uid: String) {
        userRef.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            print("Firebase: uidからuser情報取得完了")
            
            print(snapshot.value)
            
            guard let userValue = snapshot.value as? [String: Any] else{
                print("no user value")
                return
            }
            
            self.uid = uid
            self.id = userValue["id"] as! String
            self.email = userValue["email"] as! String
            self.postIdArray = userValue["postIdArray"] as? [String] ?? []
            self.likePostIdArray = userValue["likePostIdArray"] as? [String] ?? []
            self.postIdCount = self.postIdArray.count
            
            
        })
    }
    
    func getUserIdAndEmail(uid: String, vc: InfoViewController) {
        userRef.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            print("Firebase: uidからuser情報取得完了")
            
            print(snapshot.value)
            
            guard let userValue = snapshot.value as? [String: Any] else{
                print("no user value")
                return
            }
            self.id = userValue["id"] as! String
            self.email = userValue["email"] as! String
            
            vc.successGetUserInfo()
            
            // 1/2-3/3.
            //            self.firReadUserFinishDelegate?.readUserFinish(self)
            
        })

    }
    
    func logOut(vc: UIViewController) {
        do {
            try FIRAuth.auth()?.signOut()
            ud.removeObject(forKey: "uid")
        } catch {
            print("error")
        }
    }
}
