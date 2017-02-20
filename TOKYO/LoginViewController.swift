//
//  LoginViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/19.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userMailTextField: UITextField!
    @IBOutlet weak var userPassTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var user = UserModel()
    
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onTappedLoginButton() {
        login()
    }
    
    @IBAction func barCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    func login() {
        guard let signInEmail = userMailTextField.text else { return }
        guard let signInPass = userPassTextField.text else { return }
        
        user.login(mail: signInEmail, pass: signInPass, vc: self)
    }
    
    func successLogin(uid: String) {
        
        print(uid)
        
        ud.set(uid, forKey: "uid")
        
        user.getUserInfo(uid: uid)
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func failureLoing(errorMessage: String) {
        print(errorMessage)
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

extension LoginViewController {
    func initView() {
        
        userMailTextField.delegate = self
        userMailTextField.tag = 1
        userMailTextField.returnKeyType = .next
        userMailTextField.textColor = UIColor.white
        userMailTextField.attributedPlaceholder = NSAttributedString(
            string:"メールアドレス",
            attributes:[NSForegroundColorAttributeName: UIColor.white])
        userMailTextField.becomeFirstResponder()
        
        userPassTextField.delegate = self
        userPassTextField.tag = 2
        userPassTextField.returnKeyType = .next
        userPassTextField.textColor = UIColor.white
        userPassTextField.keyboardType = .asciiCapable
        userPassTextField.isSecureTextEntry = true
        userPassTextField.attributedPlaceholder = NSAttributedString(
            string:"パスワード",
            attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        signInButton.layer.cornerRadius = signInButton.bounds.size.height / 2
        signInButton.layer.borderWidth = 0.5
        signInButton.layer.borderColor = UIColor.white.cgColor
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTextField = nextInputTextField(tagNum: textField.tag) {
            
            textField.resignFirstResponder() // focus解除
            nextTextField.becomeFirstResponder() // focus
            
        } else {
            
            login()
        }
        return true
    }
    
    // 次の入力に移動するメソッド
    func nextInputTextField(tagNum: Int) -> UITextField? {
        
        if let nextTextField = self.view.viewWithTag(tagNum + 1) {
            return tagNum >= 2 ? nil : nextTextField as? UITextField
        }
        return nil
    }
    
}
