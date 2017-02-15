//
//  InfoViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/13.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Social
class InfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellTitleArray = ["Twitterでシェア",
                          "Facebookでシェア",
                          "レビューを書く",
                          "フォントの追加を依頼",
                          "開発者 Facebookアカウント"]
    
    // 参考-> http://qiita.com/naoyashiga/items/09d9947880f467ed4422
    let itunesUrl: NSURL = NSURL(string: "itms-apps://itunes.apple.com/app/1194887658")!
    let reviewUrl: NSURL = NSURL(string: "itms-apps:////itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1194887658")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
