//
//  AlertHudMacro.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

//ah = AlertHud
let AHCGFloatAlertDefaultWidth = CGFloat(300)
let AHCGFloatBtnDefaultHeight = CGFloat(44)
let AHCGFloatTitleDefaultHeight = CGFloat(40)
let AHCGFloatMessageDefaultHeight = CGFloat(80)
let AHCGFloatMessaheLabelDefaultDistance = CGFloat(10)

let AHCGFloatHudMessageDefaultHeight = CGFloat(50)
let AHCGFloatHudImageDefaultWidth = CGFloat(30)
let AHCGFloatHudActivityDefaultSize = CGFloat(40)

let AHCompareRatio = UIScreen.main.bounds.width/CGFloat(375)

public func ahScreenFitSize(_ originalSize: CGFloat) -> (CGFloat) {
    return CGFloat(Int(originalSize * AHCompareRatio * CGFloat(100))/Int(1))/CGFloat(100)
}

public func ahStingFitSize(string: String, font: UIFont, maxSize: CGSize) -> (CGSize){
    return string.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil).size
}


