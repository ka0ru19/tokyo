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
    @IBOutlet weak var bgImageView: UIImageView!
    
    var pictureKeyArray: [String] = []
    var postArray: [PostModel] = []
    
    let multiDisplayNum = 3
    var numOfDispayLine = 3 // 何行で表示するか // 画像タップで変更
    
    var numOfNowCells = 0 // 現在表示されているcellの個数
    let addNumOfCell = 18 // 更新で追加して読み込むcellの個数 // 基本は18
    let maxNumOfCell = 3000 //上限
    
    var refreshControl:UIRefreshControl! // 最上部を引っ張って読み込む
    var indicator = UIActivityIndicatorView() // 最下部を引っ張って読み込むくるくる
    
    var isLoadindCollectionView = false // 読み込み中 -> true
    var isChangingDisplayNum = false // 表示行の変更中 -> true
    var reConnectButton: UIButton = UIButton()
    
    let ud = UserDefaults.standard
    var user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        readDataFromStorage(startIndex: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initUser()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension TimeLineViewController {
    
    func initUser() {
        if let uid = ud.object(forKey: "uid") as? String {
            if uid != user.uid {
                user.getUserInfo(uid: uid)
                collectionView.reloadData()
            } else { // 同じなら何もしない
            }
        } else {
            user = UserModel()
            print("未ログイン")
            collectionView.reloadData()
        }
    }
    
    // viewの初期化
    func initView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        //        var autoresizingMask: UIViewAutoresizing = [.flexibleHeight, .flexibleWidth]
//        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 2.0 // Cellのマージン.
        
        if numOfDispayLine == multiDisplayNum { // 複数行表示のとき
            let itemLength = (self.view.bounds.width - CGFloat(numOfDispayLine - 1) * margin) / CGFloat(numOfDispayLine)
            layout.itemSize = CGSize(width: itemLength , height: itemLength)
        } else if numOfDispayLine == 1 { // １行表示のとき
            let itemLength = (self.view.bounds.width - CGFloat(numOfDispayLine - 1) * margin) / CGFloat(numOfDispayLine)
            layout.itemSize = CGSize(width: itemLength , height: itemLength + 40)
        }
        
        layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, margin, 0.0) //top,left,bottom,rightの余白
        layout.minimumInteritemSpacing = margin
        collectionView.collectionViewLayout = layout
        
    }
    
    // 何番目のcellから読み込むか指定
    // ０だと最初から更新、30,60..etcだと追加読み込み
    func readDataFromStorage(startIndex: Int) {
        
        if indicator.isAnimating {
            return // 読み込み中なら即関数を抜ける // 複数回この関数が呼ばれるのを防ぐため
        }
        
        var isReadingUserName = true // すべてのusernameを読み込みが未完了 -> false
        var isReadingImage = true // すべてのimageを読み込みが未完了 -> false
        var countOfReadUserName: Int = 0 // makeArrayIndexCount と一致で isReadingUserName をfalseにする
        var countOfReadImage: Int = 0 // makeArrayIndexCount と一致で image をfalseにする
        
        var makeArrayIndexCount: Int! // 新しく追加する配列の要素の数
        // インターネット接続確認
        if CheckReachability(host_name: "google.com") {
            print("インターネットへの接続が確認されました")
            collectionView.backgroundColor = UIColor.white
            reConnectButton = UIButton()
            reConnectButton.isHidden = true
            bgImageView.isHidden = true
        } else {
            stopIndicator() // 真ん中のくるくるを停止
            refreshControl.endRefreshing() // 上のくるくるを停止
            let alertController = UIAlertController(title: "読み込めません", message: "ネットワークに接続してください", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            collectionView.backgroundColor = UIColor.clear
            
            bgImageView.isHidden = false
            bgImageView.image = UIImage(named: "noInternet.png")
            
            reConnectButton = UIButton()
            reConnectButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
            reConnectButton.backgroundColor = UIColor.cyan
            reConnectButton.layer.masksToBounds = true
            reConnectButton.setTitle("Connect Again", for: .normal)
            reConnectButton.setTitleColor(UIColor.blue, for: .normal)
            reConnectButton.layer.cornerRadius = reConnectButton.bounds.size.height / 2
            reConnectButton.layer.position = CGPoint(x: self.view.frame.width * 1/2,
                                                     y: self.view.frame.height * 3/4)
            reConnectButton.addTarget(self,
                                      action: #selector(TimeLineViewController.onClickReConnectButton),
                                      for: .touchUpInside)
            self.view.addSubview(reConnectButton)
            
            return
            
        }
        
        startIndicator()
        
        // 第３引数でコールバックとして実行したい関数オブジェクトを受け取る
        // ここはまだ関数の宣言
        func makeArray(callback: (Bool) -> Void) -> Void {
            print("最初に読み込んだself.pictureKeyArray.count: \(self.pictureKeyArray.count)")
            print("読み込みを始める最初のindex: \(startIndex)")
            
            if self.pictureKeyArray.count <= startIndex {
                // pictureKeyArrayをすべて読み込み済みの場合
                self.isLoadindCollectionView = false
                self.collectionView.reloadData()
                self.stopIndicator()
                self.refreshControl.endRefreshing()
                return
            } else if startIndex + self.addNumOfCell < self.pictureKeyArray.count {
                // startIndex に self.addNumOfCell を加算してもまだpictureKeyArrayの総数より少ない場合
                makeArrayIndexCount = addNumOfCell
            } else {
                makeArrayIndexCount = self.pictureKeyArray.count - startIndex
            }
            
            print("読み込むpostの数: \(makeArrayIndexCount)")
            
            // 開始indexから現在表示したいcellのindexまでの配列を準備
            for _ in 0 ..< makeArrayIndexCount {
                self.postArray.append(PostModel())
            }
            
            // 処理が終わったら第３引数で受け取った関数を実行。今回はメッセージを渡す
            callback(true)
        }
        // ここまで関数の宣言
        
        let listRef = FIRDatabase.database().reference().child("list")
        
        // ここから処理
        // 初回読み込むのときだけしか使わない工程があるので要改善
        listRef.child("picture").observeSingleEvent(of: .value, with: { snapshot in
            
            // 終わりのスイッチ
            isReadingUserName = true
            isReadingImage = true
            
            guard let value = snapshot.value as? NSDictionary else {
                self.stopIndicator() // 真ん中のくるくるを停止
                self.refreshControl.endRefreshing() // 上のくるくるを停止
                self.isLoadindCollectionView = false // classに設けたスイッチをoff
                return
            }
            
            self.pictureKeyArray = []
            self.pictureKeyArray = value.allKeys as! [String]
            
            let storage = FIRStorage.storage()
            let storageRef = storage.reference(forURL: "gs://tokyo-27015.appspot.com")
            
            // 読み込むだけの空の配列の確保が終わってから
            makeArray(callback: {_ in
                for i in startIndex ..< startIndex + makeArrayIndexCount  {
                    // 作った配列に要素を追加していく
                    print("現在のi: \(i), 全体の進行度: \(i-startIndex)/\(makeArrayIndexCount)")
                    print("現在のi: \(i), 全体の進行度: \(i-startIndex)/\(self.postArray.count)")
                    let key = self.pictureKeyArray[i]
                    storageRef.child("images/\(key)").data(withMaxSize: 1 * 1024 * 1024) { data, error in
                        if let imageData = data {
                            print("data: \(imageData)")
                            self.postArray[i].image = UIImage(data: imageData)
                            
                            self.postArray[i].postId = key
                            let keyValue = (value[key] as! [String: Any])
                            let uid = keyValue["postUserUid"] as? String ?? "no uid"
                            let likeArray = (keyValue["likeUid"] as? NSDictionary)?.allKeys as? [String] ?? []
                            
                            self.postArray[i].userUid = uid
                            self.postArray[i].likeUidArray = likeArray
                            
                            listRef.child("user/\(uid)/id").observeSingleEvent(of: .value, with: { snapshot in
                                guard let userNameValue = snapshot.value as? String else{
                                    return
                                }
                                
                                print("\(i):\(userNameValue)")
                                self.postArray[i].userName = userNameValue
                                
                                // もし最後のiならreload
                                if countOfReadUserName + 1 == makeArrayIndexCount {
                                    isReadingUserName = false
                                    if isReadingImage == false {
                                        self.isLoadindCollectionView = false // classに設けたスイッチをoff
                                        self.stopIndicator() // 真ん中のくるくるを停止
                                        self.refreshControl.endRefreshing() // 上のくるくるを停止
                                        self.collectionView.reloadData() // collectionviewをreload
                                        self.numOfNowCells = startIndex + makeArrayIndexCount
                                    }
                                } else {
                                    countOfReadUserName += 1
                                }
                            })
                            // もし最後のiならreload
                            if countOfReadImage + 1 == makeArrayIndexCount {
                                isReadingImage = false
                                if isReadingUserName == false {
                                    self.isLoadindCollectionView = false // classに設けたスイッチをoff
                                    self.stopIndicator() // 真ん中のくるくるを停止
                                    self.refreshControl.endRefreshing() // 上のくるくるを停止
                                    self.collectionView.reloadData() // collectionviewをreload
                                    self.numOfNowCells = startIndex + makeArrayIndexCount
                                }
                            } else {
                                countOfReadImage += 1
                            }
                        }
                        if let theError = error {
                            print(theError)
                            // もし最後のiならreload
                            if countOfReadUserName + 1 == makeArrayIndexCount {
                                isReadingUserName = false
                                if isReadingImage == false {
                                    self.isLoadindCollectionView = false // classに設けたスイッチをoff
                                    self.stopIndicator() // 真ん中のくるくるを停止
                                    self.refreshControl.endRefreshing() // 上のくるくるを停止
                                    self.collectionView.reloadData() // collectionviewをreload
                                    self.numOfNowCells = startIndex + makeArrayIndexCount
                                }
                            } else {
                                countOfReadUserName += 1
                            }
                            if countOfReadImage + 1 == makeArrayIndexCount {
                                isReadingImage = false
                                if isReadingUserName == false {
                                    self.isLoadindCollectionView = false // classに設けたスイッチをoff
                                    self.stopIndicator() // 真ん中のくるくるを停止
                                    self.refreshControl.endRefreshing() // 上のくるくるを停止
                                    self.collectionView.reloadData() // collectionviewをreload
                                    self.numOfNowCells = startIndex + makeArrayIndexCount
                                }
                            } else {
                                countOfReadImage += 1
                            }
                            
//                            self.stopIndicator() // 真ん中のくるくるを停止
//                            self.refreshControl.endRefreshing() // 上のくるくるを停止
//                            self.isLoadindCollectionView = false // classに設けたスイッチをoff
//                            let alertController = UIAlertController(title: "読み込みできません", message: "ネットワークに接続してください", preferredStyle: .alert)
//                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                            
//                            alertController.addAction(okAction)
//                            
//                            self.reConnectButton = UIButton()
//                            self.reConnectButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//                            self.reConnectButton.backgroundColor = UIColor.cyan
//                            self.reConnectButton.layer.masksToBounds = true
//                            self.reConnectButton.setTitle("Connect Again", for: .normal)
//                            self.reConnectButton.setTitleColor(UIColor.blue, for: .normal)
//                            self.reConnectButton.layer.cornerRadius = self.reConnectButton.bounds.size.height / 2
//                            self.reConnectButton.layer.position = CGPoint(x: self.view.frame.width * 1/2,
//                                                                          y: self.view.frame.height * 3/4)
//                            self.reConnectButton.addTarget(self,
//                                                           action: #selector(TimeLineViewController.onClickReConnectButton),
//                                                           for: .touchUpInside)
//                            self.view.addSubview(self.reConnectButton)
//                            
//                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            })
        })
    }
    
    func refresh() {
        // 最上部からなので最初のindexから読み込む
        // 表示数を初期設定に戻す
        numOfNowCells = 0
        postArray = []
        pictureKeyArray = []
        collectionView.reloadData()
        readDataFromStorage(startIndex: numOfNowCells)
    }
    
    // no Network時に「再接続」ボタンが押された時
    func onClickReConnectButton() {
        reConnectButton.isHidden = true
        bgImageView.isHidden = true
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
    
    func deletePost(post: PostModel) {
        
        // データベースから削除
//        let postModel = PostModel()
//        postModel.deletePostById(id: post.postId)

        post.deleteSelf()
        
        // ローカルでの削除処理
        
        for i in 0 ..< postArray.count {
            if post.postId == postArray[i].postId {
                postArray.remove(at: i)
                break
            }
        }
        
        collectionView.reloadData()
        
        for i in 0 ..< pictureKeyArray.count {
            if post.postId == pictureKeyArray[i] {
                pictureKeyArray.remove(at: i)
                break
            }
        }
    }
    
    func spamPost(id: String) {
        PostModel().spamPostById(id: id)
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
        isChangingDisplayNum = true
        
        setCollectionViewLayout()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        // issue: タップ時のUIが悪い問題
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //一番下までスクロールしたかどうか
        if self.collectionView.contentOffset.y
            > (self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
            //まだ表示するコンテンツが存在するか判定し存在するなら○件分を取得して表示更新する
            if !isLoadindCollectionView && !isChangingDisplayNum {
                print("collectionViewの最下部に到達: 読み込み開始")
                isLoadindCollectionView = true
                readDataFromStorage(startIndex: numOfNowCells)
            } else {
                isChangingDisplayNum = false
            }
        }
    }
}

extension TimeLineViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoadindCollectionView {
            return 0
        } else {
            return postArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「cell」のセルを取得する。
        if numOfDispayLine == multiDisplayNum {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCollectionViewCell
            
            cell.setCell(post: postArray[indexPath.row])
            cell.contentView.frame = cell.bounds
            cell.contentView.autoresizingMask = [.flexibleWidth,
                                                 .flexibleTopMargin]
            return cell
        }
            
        else if numOfDispayLine == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! PictureDetailCollectionViewCell
            
            cell.setCell(post: postArray[indexPath.row])
            cell.delegate = self
            cell.contentView.frame = cell.bounds
            cell.contentView.autoresizingMask = [.flexibleWidth,
                                                 .flexibleTopMargin]
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
    
    func showSettingAlertFromDetailCell(post: PostModel) {
        let alert = UIAlertController(title: "詳細", message: nil, preferredStyle: .actionSheet)
        if  post.userUid == ud.object(forKey: "uid") as? String {
            let deleteAction = UIAlertAction(title: "この投稿を削除する", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                self.deletePost(post: post)
            })
            alert.addAction(deleteAction)
        } else {
            let spamAction = UIAlertAction(title: "この投稿の問題を報告する", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                self.spamPost(id: post.postId)
            })
            alert.addAction(spamAction)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
