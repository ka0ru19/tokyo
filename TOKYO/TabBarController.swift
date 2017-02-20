//
//  TabBarController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/20.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //レンダリングモードをAlwaysOriginalでボタンの画像を登録する。
        tabBar.items![0].image = UIImage(named: "making")!.withRenderingMode(UIImageRenderingMode.automatic)
        tabBar.items![1].image = UIImage(named: "timeline")!.withRenderingMode(UIImageRenderingMode.automatic)
        
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        tabBar.items![0].selectedImage = UIImage(named: "making")
        tabBar.items![1].selectedImage = UIImage(named: "timeline")
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
