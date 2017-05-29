//
//  CheckReachability.swift
//  TOKYO
//
//  Created by 井上航 on 2017/02/21.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
// インターネット接続確認
//

import Foundation
import SystemConfiguration

func CheckReachability(host_name:String)->Bool{
    let reachability = SCNetworkReachabilityCreateWithName(nil, host_name)!
    var flags = SCNetworkReachabilityFlags.connectionAutomatic
    if !SCNetworkReachabilityGetFlags(reachability, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}
