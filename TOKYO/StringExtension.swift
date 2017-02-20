//
//  StringExtension.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/20.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import Foundation

extension String {
    
//    var isAllHalfWidthCharacter: Bool {
//        // 半角も全角も1文字でカウント
//        let nsStringlen = self.characters.count
//        let utf8 = (self as NSString).utf8String
//        // Cのstrlenは全角を2で判定する
//        let cStringlen = Int(bitPattern: strlen(utf8))
//        if nsStringlen == cStringlen {
//            return true
//        }
//        
//        return false
//    }
//    
//    var isValidNickName: Bool {
//        if rangeOfCharacterFrom(.letterCharacterSet(), options: .LiteralSearch, range: nil) == nil { return false }
//        if rangeOfCharacterFrom(.decimalDigitCharacterSet(), options: .LiteralSearch, range: nil) != nil { return false }
//        guard self.isAllHalfWidthCharacter else { return false }
//        return true
//    }
    
    var isValidUserId: Bool {
        let idRegEx = "[A-Z0-9a-z_]{3,13}"
        let idTest = NSPredicate(format:"SELF MATCHES %@", idRegEx)
        return idTest.evaluate(with: self)

    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
        

    }
}
