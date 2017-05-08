//
//  ExtensionColor.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func fromHex (_ hex: String, alpha: CGFloat = 1) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
    }
}
