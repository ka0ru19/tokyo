//
//  InfoViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/13.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Social
import GoogleMobileAds

class InfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let cellTitleArray = ["Twitterでシェア",
                          "Facebookでシェア",
                          "レビューを書く",
                          "フォントの追加を依頼",
                          "開発者 Facebookアカウント"]
    
    // 参考-> http://qiita.com/naoyashiga/items/09d9947880f467ed4422
    let itunesURL: String = ""
    let reviewUrl: String = ""

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
        // AdMob
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-4040761063524447/7604354219"
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeSmartBannerLandscape
        bannerView.load(GADRequest())
    }
    
    // 0
    func shareInTwitter() {
        let text = "アプリでエモいフォントのTOKYO写真を作ろう #TOKYO " + itunesURL
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        composeViewController.setInitialText(text)
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    // 1
    func shareInFacebook() {
        let text = "アプリでエモいフォントのTOKYO写真を作ろう #TOKYO " + itunesURL
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        composeViewController.setInitialText(text)
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    // 2
    func writeReview() {
        let url = NSURL(string: reviewUrl)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as! URL)
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

extension InfoViewController: GADBannerViewDelegate {
    
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
    }
}

