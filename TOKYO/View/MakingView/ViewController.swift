//
//  ViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/07.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//
//  メインの、画像を合成するViewController

import UIKit
import Accounts
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let fontFamilyNamesArray = UIFont.familyNames // font名のarray
    
    let ud = UserDefaults.standard
    
    var ref : FIRDatabaseReference!
    //    let storage = FIRStorage.storage()
    
    var sourceImage: UIImage! // もともとの写真
    var tokyoText: String? // 合成するテキスト
    var tokyoFontName: String? // 選択されたfont名
    
    var indicator = UIActivityIndicatorView() // くるくる
    
    var user =  UserModel()
    
    // 拡大率
    var zoomNow:CGFloat=1.0
    let zoomMin:CGFloat=0.2
    let zoomMax:CGFloat=2.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference().child("list").child("selectedFont")
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraButton(_ sender: UIBarButtonItem) {
        precentPickerController(sourceType: .camera)
    }
    
    @IBAction func AlbumButton(_ sender: UIBarButtonItem) {
        precentPickerController(sourceType: .photoLibrary)
    }
    
    @IBAction func infoButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toInfo", sender: nil)
    }
    @IBAction func uploadButton(_ sender: UIBarButtonItem) {
        
//        let tokyoImage: UIImage = makeTokyoImage()
        
        // Firebaseに情報を保存
        setDataToFirebase(fontname: tokyoFontName ?? "", text: tokyoText ?? "")
        
        let alert = UIAlertController(title: "共有先を選択", message: "このアプリではすべての人が投稿を閲覧できます", preferredStyle: .actionSheet)
        
        let shareOnHere: UIAlertAction = UIAlertAction(title: "このアプリ上でシェア", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.displayShareHere()
        })
        
        let shareOnSNS: UIAlertAction = UIAlertAction(title: "他のSNSでシェア", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.displayActivityVC()
        })
        // Cancelボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(shareOnHere)
        alert.addAction(shareOnSNS)
        
        // iPadのクラッシュ回避策
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

        present(alert, animated: true, completion: nil)
        
    }
    
    // 「このアプリでShare」
    func displayShareHere() {
        
        if ud.object(forKey: "uid") != nil {
            startIndicator() // くるくる開始 -> successUpLoad()にて終了
            let newPost = PostModel()
            newPost.image = makeTokyoImage()
            newPost.upLoad(user: user, image: makeTokyoImage(), vc: self)
        } else {
            performSegue(withIdentifier: "toSignUp", sender: nil)
        }

        
    }
    
    //「その他のShare」
    func displayActivityVC() {
        let activityVC = UIActivityViewController(activityItems: [makeTokyoImage(),"#TOKYO "],
                                                  applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func successUpLoad() {
        stopIndicator()
    }
    
    func failureUpLoad(errorMessage: String) {
        stopIndicator()
        let alertController = UIAlertController( title: "アップロード失敗", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)

    }
    
    func makeTokyoImage() -> UIImage {
        
        guard let tokyoText = tokyoText else {
            return sourceImage
        }
        
        let fontSize: CGFloat = sourceImage.size.width / CGFloat(tokyoText.characters.count) * zoomNow
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        var font = UIFont()
        if (tokyoFontName != nil) {
            font = UIFont(name: tokyoFontName!, size: fontSize)!
        } else {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        }
        
        textStyle.alignment = NSTextAlignment.center
        let textFontAttributes = [
            NSFontAttributeName: font ,
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        // グラフィックスコンテキスト生成,編集を開始
        UIGraphicsBeginImageContext(sourceImage.size)
        
        // 読み込んだ写真を書き出す
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: sourceImage.size.width, height: sourceImage.size.height))
        
        // 描き出す位置と大きさの設定 CGRect([左からのx座標]px, [上からのy座標]px, [縦の長さ]px, [横の長さ]px)
        //let margin: CGFloat = 5.0 // 余白
        var textRect  = CGRect(x: 0, y: 0, width: 0, height: 0)
        //        textRect.size = sourceImage.size
        textRect.size = CGSize(width: sourceImage.size.width * zoomNow,
                               height: sourceImage.size.height * zoomNow)
        textRect.origin = CGPoint(x: (sourceImage.size.width / 2 ) - (fontSize * CGFloat(tokyoText.characters.count) / 2),
                                  y: (sourceImage.size.height / 2) - (fontSize / 2)
        )
        
        // textRectで指定した範囲にtextFontAttributesにしたがってtextを描き出す
        tokyoText.draw(in: textRect, withAttributes: textFontAttributes)
        
        // グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // グラフィックスコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func setDataToFirebase(fontname: String, text: String) {
        
        // 時刻を取得
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium // -> ex: 2016/10/29
        formatter.timeStyle = .medium // -> ex: 13:20:08
        
        let formattedDate = formatter.string(from: now)
        
        ref.childByAutoId().setValue(["name": fontname,
                                      "text": text,
                                      "date": formattedDate])
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tokyoFontName = fontFamilyNamesArray[indexPath.row]
        //        tokyoTextField.font = UIFont(name: tokyoFontName!, size: 80)!
        
        imageView.image = makeTokyoImage()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fontFamilyNamesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「TestCell」のセルを取得する。
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FontSampleCollectionViewCell
        
        //セルの背景色をランダムに設定する。
        cell.backgroundColor = UIColor(red: CGFloat(drand48()),
                                       green: CGFloat(drand48()),
                                       blue: CGFloat(drand48()),
                                       alpha: 1.0)
        
        //セルのラベルに番号を設定する。
        cell.sampleLabel.text = tokyoText ?? "NO WORD"
        cell.sampleLabel.font = UIFont(name: fontFamilyNamesArray[indexPath.row], size: 20)
        cell.nameLabel.text = fontFamilyNamesArray[indexPath.row]
        cell.nameLabel.font = UIFont(name: fontFamilyNamesArray[indexPath.row], size: 12)
        
        return cell
        
    }
}


extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // カメラ、アルバムの呼び出しメソッド(カメラorアルバムのソースタイプが引き数)
    func precentPickerController(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // 写真が選択された時に呼び出されるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        // 画像を出力
        imageView.contentMode = .scaleAspectFit
        sourceImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = sourceImage
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    // ピンチジェスチャー
    func viewPinch(sender:UIPinchGestureRecognizer){
        // 拡大率を適当に決める
        zoomNow += (sender.scale-1) * 0.1
        
        if zoomNow > zoomMax {
            zoomNow=zoomMax
        }else if zoomNow < zoomMin {
            zoomNow=zoomMin
        }
        
        imageView.image = makeTokyoImage()
        
    }
}

extension ViewController {
    
    // 初期化
    func initUser() {
        if let uid = ud.object(forKey: "uid") as? String {
            if uid != user.uid {
                user.getUserInfo(uid: uid )
            }
        } else {
            user = UserModel()
            print("未ログイン")
        }
    }
    
    func initView() {
        //        tokyoTextField.delegate = self
        //        tokyoTextField.returnKeyType = .done
        sourceImage = UIImage(named: "sample2.jpg")
        tokyoText = "TOKYO"
        imageView.image = makeTokyoImage()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.inputTextAlert))
        tapGesture.delegate = self
        dummyView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target:self, action: #selector(self.viewPinch))
        pinchGesture.delegate=self
        dummyView.addGestureRecognizer(pinchGesture)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FontSampleCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "cell")
        
        let layout = UICollectionViewFlowLayout()
        let numOfLine = 3 // 何行で表示するか
        let margin: CGFloat = 3.0 // Cellのマージン.
        let itemWidth = (self.view.bounds.width - CGFloat(numOfLine - 1) * margin) / CGFloat(numOfLine)
        layout.itemSize = CGSize(width: itemWidth , height: 56)
        layout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) //top,left,bottom,rightの余白
        layout.minimumInteritemSpacing = margin
        collectionView.collectionViewLayout = layout
        
        let titleView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        titleView.image = UIImage(named: "TokyoLogo1.png")
        titleView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = titleView
    }
    
    func inputTextAlert() {
        let alert = UIAlertController(title: "Input Text!", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Done", style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            self.tokyoText = textField.text
            self.imageView.image = self.makeTokyoImage()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = self.tokyoText
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
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
