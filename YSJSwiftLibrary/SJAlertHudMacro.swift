//
//  SJAlertHudMacro.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

//ah = AlertHud
let AHCGFloatAlertWidth = CGFloat(300)
let AHCGFloatBtnHeight = CGFloat(44)
let AHCGFloatTitleHeight = CGFloat(40)
let AHCGFloatMessageHeight = CGFloat(80)
let AHCGFloatMessaheLabelWidth = CGFloat(260)


let AHCompareRatio = UIScreen.main.bounds.width/CGFloat(375)

public func ahScreenFitSize(_ originalSize: CGFloat) -> (CGFloat) {
    return CGFloat(Int(originalSize * AHCompareRatio * CGFloat(100))/Int(1))/CGFloat(100)
}

public func ahStingFitSize(string: String, font: UIFont, maxSize: CGSize) -> (CGSize){
    return string.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
}


