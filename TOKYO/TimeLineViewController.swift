//
//  TimeLineViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/15.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Firebase

class TimeLineViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pictureKeyArray: [String] = []
    var postArray: [PostModel] = []
    
    let multiDisplayNum = 3
    var numOfDispayLine = 3 // 何行で表示するか // 画像タップで変更
    
    var numOfNowCells = 0 // 現在表示されているcellの個数
    let addNumOfCell = 30 // 更新で追加して読み込むcellの個数
    let maxNumOfCell = 3000 //上限
    
    var refreshControl:UIRefreshControl! // 最上部を引っ張って読み込む
    var indicator = UIActivityIndicatorView() // 最下部を引っ張って読み込むくるくる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        readDataFromStorage(startIndex: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension TimeLineViewController {
    
    // 初期化
    func initView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "PictureDetailCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "detailCell")
        
        setCollectionViewLayout()
        
        refreshControl = UIRefreshControl() // 最上部からの更新
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(TimeLineViewController.refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    // 各cellに1または3行としてcellの配置位置を定義
    func setCollectionViewLayout() {
        if numOfDispayLine == multiDisplayNum {
            let layout = UICollectionViewFlowLayout()
            let margin: CGFloat = 2.0 // Cellのマージン.
            let itemLength = (self.view.bounds.width - CGFloat(numOfDispayLine - 1) * margin) / CGFloat(numOfDispayLine)
            layout.itemSize = CGSize(width: itemLength , height: itemLength)
            layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, margin, 0.0) //top,left,bottom,rightの余白
            layout.minimumInteritemSpacing = margin
            collectionView.collectionViewLayout = layout
            
        } else if numOfDispayLine == 1 {
            let layout = UICollectionViewFlowLayout()
            let margin: CGFloat = 2.0 // Cellのマージン.
            let itemLength = (self.view.bounds.width - CGFloat(numOfDispayLine - 1) * margin) / CGFloat(numOfDispayLine)
            layout.itemSize = CGSize(width: itemLength , height: itemLength + 40)
            layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, margin, 0.0) //top,left,bottom,rightの余白
            layout.minimumInteritemSpacing = margin
            collectionView.collectionViewLayout = layout
        }
    }
    
    // 何番目のcellから読み込むか指定
    // ０だと最初から更新、30,60..etcだと追加読み込み
    func readDataFromStorage(startIndex: Int) {
        
        var isReadingUserName = false
        var isReadingImage = false
        if indicator.isAnimating {
            return
        } else {
            isReadingUserName = true
            isReadingImage = true
        }
        
        startIndicator()
        
        // 第３引数でコールバックとして実行したい関数オブジェクトを受け取る
        // ここはまだ関数の定義
        func makeArray(callback: (Bool) -> Void) -> Void {
            
            let max = self.numOfNowCells + self.addNumOfCell // max = 30, 60, 90 ...
            self.numOfNowCells = max < self.pictureKeyArray.count ? max : self.pictureKeyArray.count
            
            let startIndex = self.numOfNowCells - self.addNumOfCell < 0 ? 0 : self.numOfNowCells - self.addNumOfCell
            
            for i in startIndex ..< self.numOfNowCells {
                print(i)
                self.postArray.append(PostModel())
            }
            
            // 処理が終わったら第３引数で受け取った関数を実行。今回はメッセージを渡す
            callback(true)
        }
        
        let listRef = FIRDatabase.database().reference().child("list")
        
        
        // ここから処理
        listRef.child("picture").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            print(value)
            self.pictureKeyArray = []
            self.pictureKeyArray = value.allKeys as! [String]
            
            if startIndex == 0 {
                self.postArray = []
            }
            
            let storage = FIRStorage.storage()
            let storageRef = storage.reference(forURL: "gs://tokyo-27015.appspot.com")
            
            print("self.pictureKeyArrayを出力↓")
            print(self.pictureKeyArray)
            
            // 読み込むだけの空の配列の確保が終わってから
            makeArray(callback: {_ in
                let startIndex = self.numOfNowCells - self.addNumOfCell < 0 ? 0 : self.numOfNowCells - self.addNumOfCell
                for i in startIndex ..< self.numOfNowCells  {
                    // 作った配列に要素を追加していく
                    print("現在のi: \(i), 全体の進行度: \(i-startIndex)/\(self.numOfNowCells-startIndex)")
                    let key = self.pictureKeyArray[i]
                    storageRef.child("images/\(key)").data(withMaxSize: 1 * 1024 * 1024) { data, error in
                        if let imageData = data {
                            print("data: \(imageData)")
                            
                            self.postArray[i].postId = key
                            let uid = (value[key] as! [String: Any])["postUserUid"] as? String ?? "no uid"
                            
                            self.postArray[i].userUid = uid
                            
                            listRef.child("user/\(uid)/id").observeSingleEvent(of: .value, with: { snapshot in
                                print("Firebase: uidからusername情報取得->\(snapshot.value)")
                                guard let userNameValue = snapshot.value as? String else{
                                    return
                                }
                                
                                print("\(i):\(userNameValue)")
                                self.postArray[i].userName = userNameValue
                                
                                // もし最後のiならreload
                                if i == self.numOfNowCells - 1 {
                                    isReadingUserName = false
                                    if isReadingImage == false {
                                        self.stopIndicator()
                                        self.collectionView.reloadData()
                                        self.refreshControl.endRefreshing()
                                    }
                                    
                                }
                                
                            })
                            self.postArray[i].image = UIImage(data: imageData)
                            
                            // もし最後のiならreload
                            if i == self.numOfNowCells - 1 {
                                isReadingImage = false
                                if isReadingUserName == false {
                                    self.stopIndicator()
                                    self.collectionView.reloadData()
                                    self.refreshControl.endRefreshing()
                                }
                            }
                        }
                        if let theError = error {
                            print(theError)
                        }
                    }
                }
            })
        })
    }
    
    func refresh() {
        // 最上部からなので最初のindexから読み込む
        readDataFromStorage(startIndex: 0)
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

extension TimeLineViewController: UICollectionViewDelegateFlowLayout {
    // 横に長い写真は上下の幅を削減したかったけど保留。
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        let imageSize = imageArray[indexPath.row].size
    //        let yokonagaRate: Float = Float(imageSize.width / imageSize.height) // 横長率(高さ/横)
    //        let screenWidth = self.view.bounds.width
    //        if yokonagaRate > 1.0 {
    //            return CGSize(width: screenWidth , height: screenWidth / CGFloat(yokonagaRate) )
    //        } else {
    //            return CGSize(width: screenWidth , height: screenWidth)
    //        }
    //    }
}

extension TimeLineViewController: UICollectionViewDelegate {
    // cellタップ時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if numOfDispayLine == multiDisplayNum {
            numOfDispayLine = 1
        } else if numOfDispayLine == 1 {
            numOfDispayLine = multiDisplayNum
        }
        
        setCollectionViewLayout()
        collectionView.reloadData()
    }
}

extension TimeLineViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「cell」のセルを取得する。
        if numOfDispayLine == multiDisplayNum {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCollectionViewCell
            
            cell.setCell(post: postArray[indexPath.row])
            
            return cell
        }
            
        else if numOfDispayLine == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! PictureDetailCollectionViewCell
            
            cell.setCell(post: postArray[indexPath.row])
            cell.delegate = self
            
            return cell
        }
        else {
            fatalError()
        }
        
    }
}

extension TimeLineViewController: DetailCellDelegate {
    // ログアウト状態でdetailcellのHeartを押した時に呼ばれる
    func showAlertFromDetailCell() {
        let alert = UIAlertController(title: "利用できません", message: "ユーザ登録をしてください", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
