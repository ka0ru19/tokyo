//
//  InfoViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/13.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Social
import Firebase
class InfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var accountButton: UIButton!
    
    let cellTitleArray = ["Twitterでシェア",
                          "Facebookでシェア",
                          "レビューを書く",
                          "フォントの追加を依頼",
                          "開発者 Facebookアカウント"]
    
    // 参考-> http://qiita.com/naoyashiga/items/09d9947880f467ed4422
    let itunesUrl: NSURL = NSURL(string: "itms-apps://itunes.apple.com/app/1194887658")!
    let reviewUrl: NSURL = NSURL(string: "itms-apps:////itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1194887658")!

    let ud = UserDefaults.standard
    var user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let uid = ud.object(forKey: "uid") as? String {
            user.getUserIdAndEmail(uid: uid, vc: self) // 完了したらsuccessGetUserIdAndEmail()が呼ばれる
        } else {
            statusLabel.text = "アカウントを作成しましょう！\n1分ほどで簡単に作成できます"
            accountButton.setTitle("Sign up / Sign In", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func accountButtonTapped() {
        if (ud.object(forKey: "uid") as? String) != nil { //ログイン中
            ud.removeObject(forKey: "uid")
            user.logOut(vc: self)
            statusLabel.text = "アカウントを作成しましょう！\n1分ほどで簡単に作成できます"
            accountButton.setTitle("Sign up / Sign In", for: .normal)
        } else {
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AccountRegister") as! AccountRegisterViewController
            self.present(nextView, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func successGetUserIdAndEmail(){
        statusLabel.text = "id: \(user.id)\nmail: \(user.email)"
        accountButton.setTitle("ログアウト", for: .normal)
    }

}

extension InfoViewController {
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "情報"
    }
    
    // 0
    func shareInTwitter() {
        let text = "アプリでエモいフォントのTOKYO写真を作ろう #TOKYO "
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        composeViewController.setInitialText(text)
        composeViewController.add(itunesUrl as URL!)
        self.present(composeViewController, animated: true, completion: { action in
            self.tableView.reloadData()
        })
    }
    
    // 1
    func shareInFacebook() {
        let text = "アプリでエモいフォントのTOKYO写真を作ろう #TOKYO "
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        composeViewController.setInitialText(text)
        composeViewController.add(itunesUrl as URL!)
        self.present(composeViewController, animated: true, completion: { action in
            self.tableView.reloadData()
        })
    }
    
    // 2
    func writeReview() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(reviewUrl as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(reviewUrl as URL)
        }
    }
    
    // 3
    func toFontRequestVC() {
        performSegue(withIdentifier: "toFontRequest", sender: nil)
    }
    
    // 4
    func toDeveloperFacebook() {
        let profileUrl = NSURL(string: "https://www.facebook.com/in0uewataru")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(profileUrl as! URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(profileUrl as! URL)
        }
    }
}

extension InfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = cellTitleArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: shareInTwitter()
        case 1: shareInFacebook()
        case 2: writeReview()
        case 3: toFontRequestVC()
        case 4: toDeveloperFacebook()
        default : fatalError()
        }
    }
    
}
