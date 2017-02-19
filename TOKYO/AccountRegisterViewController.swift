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
    
    let ud = UserDefaults.standard
    
    let user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUIParts()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTapped() {
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
        
    }
    
}

// firebaseまわり
extension AccountRegisterViewController {
    
    func register() {
        // それぞれのtextFieldに値が入力されているか確認
        guard let newId = newIdTextField.text else { return }
        guard let signUpEmail = newMailTextField.text else { return }
        guard let signUpPass = newPassTextField.text else { return }
        guard let pass2 = newPass2TextField.text else { return }
        
        if signUpPass != pass2 {
            
            print("２つのパスワードが一致しません")
            newPassTextField.text = ""
            newPass2TextField.text = ""
            return
        }
        
        user.registerAccount(id: newId, mail: signUpEmail, pass: signUpPass, vc: self)
        
    }
    
    
    func successNewAccountRegister() {
        self.performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    func failureNewHSRegister(errorMessage: String) {
        print("failureNewHSRegister: \(errorMessage)")
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


