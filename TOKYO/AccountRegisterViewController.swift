//
//  AccountRegisterViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class AccountRegisterViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var newIdTextField: UITextField!
    @IBOutlet weak var newMailTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var newPass2TextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toLoginButton: UIButton!
    
    let ud = UserDefaults.standard
    
    let user = UserModel()
    
    var indicator = UIActivityIndicatorView() // くるくる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUIParts()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func barCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped() {
        startIndicator()
        register()
    }
    
    @IBAction func signInButton() {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension AccountRegisterViewController {
    func initUIParts() {
        
        newIdTextField.delegate = self
        newIdTextField.tag = 1
        newIdTextField.returnKeyType = .next
        newIdTextField.keyboardType = .asciiCapable
        newIdTextField.attributedPlaceholder = NSAttributedString(
            string:"USER ID(半角英数 3~13字)",
            attributes:[NSForegroundColorAttributeName: UIColor.gray])
        newIdTextField.becomeFirstResponder()
        
        newMailTextField.delegate = self
        newMailTextField.tag = 2
        newMailTextField.returnKeyType = .next
        newMailTextField.attributedPlaceholder = NSAttributedString(
            string:"メールアドレス",
            attributes:[NSForegroundColorAttributeName: UIColor.gray])
        
        newPassTextField.delegate = self
        newPassTextField.tag = 3
        newPassTextField.returnKeyType = .next
        newPassTextField.keyboardType = .asciiCapable
        newPassTextField.isSecureTextEntry = true
        newPassTextField.attributedPlaceholder = NSAttributedString(
            string:"パスワード(6~20字)",
            attributes:[NSForegroundColorAttributeName: UIColor.gray])
        
        newPass2TextField.delegate = self
        newPass2TextField.tag = 4
        newPass2TextField.returnKeyType = .next
        newPass2TextField.keyboardType = .asciiCapable
        newPass2TextField.isSecureTextEntry = true
        newPass2TextField.attributedPlaceholder = NSAttributedString(
            string:"パスワード(再入力)",
            attributes:[NSForegroundColorAttributeName: UIColor.gray])
        
        
        signUpButton.layer.cornerRadius = signUpButton.bounds.size.height / 2
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.white.cgColor
        
        toLoginButton.layer.cornerRadius = signUpButton.bounds.size.height / 2
        toLoginButton.layer.borderWidth = 0.5
        toLoginButton.layer.borderColor = UIColor.white.cgColor
        
    }
   
    func startIndicator() {
        // UIActivityIndicatorViewを生成
        indicator = UIActivityIndicatorView()
        
        // 以下、各種プロパティ設定
        
        // indicatorのframeを作成
        indicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        // frameを角丸にする場合は数値調整
        indicator.layer.cornerRadius = 8
        
        // indicatorのstyle（color）を設定
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        // indicatorのbackgroundColorを設定
        indicator.backgroundColor = UIColor.darkGray
        
        // indicatorの配置を設定
        indicator.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        
        // indicatorのアニメーションが終了したら自動的にindicatorを非表示にするか否かの設定
        indicator.hidesWhenStopped = true
        
        // indicatorのアニメーションを開始
        indicator.startAnimating()
        
        // 画面操作の無効化
        self.view.isUserInteractionEnabled = false
        
        // viewにindicatorを追加
        self.view.addSubview(indicator)
        
    }
    
    func stopIndicator() {
        // indicatorのアニメーションを終了
        indicator.stopAnimating()
        
        // 画面操作の有効化
        self.view.isUserInteractionEnabled = true
    }
    

}

// firebaseまわり
extension AccountRegisterViewController {
    
    func register() {
        // それぞれのtextFieldに値が入力されているか確認
        guard
            let newId = newIdTextField.text,
            let signUpEmail = newMailTextField.text,
            let signUpPass = newPassTextField.text ,
            let pass2 = newPass2TextField.text else {
                stopIndicator()
                let alertController = UIAlertController( title: "入力してない項目があります", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
        }
        
        if !newId.isValidUserId { // 半角英数が不正
            stopIndicator()
            // Alert
            let alertController = UIAlertController( title: "入力に誤りがあります", message: "IDは半角英字3~13字です", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.newIdTextField.text = nil
                self.newPassTextField.text = nil
                self.newPass2TextField.text = nil
            })
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if !signUpEmail.isValidEmail { // メールアドレスが不正
            stopIndicator()
            // Alert
            let alertController = UIAlertController( title: "入力に誤りがあります", message: "メールアドレスが不正です", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.newMailTextField.text = nil
                self.newPassTextField.text = nil
                self.newPass2TextField.text = nil
            })
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if signUpPass != pass2 {
            stopIndicator()
            // Alert
            let alertController = UIAlertController( title: "入力に誤りがあります", message: "パスワードが一致しません", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.newPassTextField.text = nil
                self.newPass2TextField.text = nil
            })
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        user.registerAccount(id: newId, mail: signUpEmail, pass: signUpPass, vc: self)
        
    }
    
    
    func successNewAccountRegister() {
        stopIndicator()
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    func failureNewHSRegister(errorMessage: String) {
        stopIndicator()
        let alertController = UIAlertController( title: "Sign Up Failure", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}

extension AccountRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTextField = nextInputTextField(tagNum: textField.tag) {
            
            textField.resignFirstResponder() // focus解除
            nextTextField.becomeFirstResponder() // focus
            
        } else {
            // 次のvcへ
            register()
            //            textField.resignFirstResponder() // focus解除
            // 次の画面に行く準備処理
            
        }
        return true
    }
    
    // 次の入力に移動するメソッド
    func nextInputTextField(tagNum: Int) -> UITextField? {
        if let nextTextField = self.view.viewWithTag(tagNum + 1) {
            return tagNum >= 4 ? nil : nextTextField as? UITextField
        }
        return nil
    }
    
}


