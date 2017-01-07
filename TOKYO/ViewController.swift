//
//  ViewController.swift
//  TOKYO
//
//  Created by 井上航 on 2017/01/07.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import Accounts

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tokyoTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let fontFamilyNamesArray = UIFont.familyNames // font名のarray
    
    var selectedFontName: String? // 選択されたfont名
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
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
    
    @IBAction func uploadButton(_ sender: UIBarButtonItem) {
        
        let tokyoImage: UIImage = makeTokyoImage()
        
        let activityVC = UIActivityViewController(activityItems: [tokyoImage,"#TOKYO"],
                                                  applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func makeTokyoImage() -> UIImage {
        guard let image = imageView.image else { //背景画像を設定
            fatalError()
        }
        
        // テキストの内容の設定
        guard let text = tokyoTextField.text else { // 合成する文字列を設定
            print("no word in tokyoTextField")
            return image
        }
        
        let fontSize: CGFloat = image.size.width / CGFloat(text.characters.count)
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        var font = UIFont()
        if (selectedFontName != nil) {
            font = UIFont(name: selectedFontName!, size: fontSize)!
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
        UIGraphicsBeginImageContext(image.size)
        
        // 読み込んだ写真を書き出す
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // 描き出す位置と大きさの設定 CGRect([左からのx座標]px, [上からのy座標]px, [縦の長さ]px, [横の長さ]px)
        //let margin: CGFloat = 5.0 // 余白
        var textRect  = CGRect(x: 0, y: 0, width: 0, height: 0)
        textRect.size = image.size
        textRect.origin = CGPoint(x: (image.size.width / 2 ) - (fontSize * CGFloat(text.characters.count) / 2),
                                  y: (image.size.height / 2) - (fontSize / 2)
        )
        
        // textRectで指定した範囲にtextFontAttributesにしたがってtextを描き出す
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        // グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // グラフィックスコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFontName = fontFamilyNamesArray[indexPath.row]
        tokyoTextField.font = UIFont(name: selectedFontName!, size: 80)!
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(fontFamilyNamesArray.count)
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
        cell.sampleLabel.text = tokyoTextField.text ?? "NO WORD"
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
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController {
    func initView() {
        tokyoTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FontSampleCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "cell")
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 4.0
        layout.itemSize = CGSize(width: collectionView.frame.width / 2 - margin * 2 , height: 60)
        // Cellのマージン.
        layout.sectionInset = UIEdgeInsetsMake(0.0, margin, 0.0, margin) //top,left,bottom,rightの余白
        layout.minimumInteritemSpacing = margin
        collectionView.collectionViewLayout = layout
        
        tokyoTextField.center = imageView.center
        view.reloadInputViews()
    }
}
