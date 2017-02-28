//
//  FontRequestViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/13.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Firebase

class FontRequestViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var ref : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("list").child("fontRequest")
        initView()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButton(_ sender: UIBarButtonItem) {
        showAlert()
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

extension FontRequestViewController {
    func initView() {
        textView.delegate = self
        textView.becomeFirstResponder()
    }
    
    func showAlert() {
        guard let text = textView.text else {
            return
        }
        
        if text == "" {
            print("textがありません")
            return
        }
        
        let alert = UIAlertController(title: "確認", message: "この内容で送信しますか？", preferredStyle: .alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.postToFirebase(text)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func postToFirebase(_ text: String) {
        
        // 時刻を取得
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium // -> ex: 2016/10/29
        formatter.timeStyle = .medium // -> ex: 13:20:08
        
        let formattedDate = formatter.string(from: now)
        
        ref.childByAutoId().setValue(["text": text,
                                      "date": formattedDate])
    }
}

extension FontRequestViewController: UITextViewDelegate {
    
}
