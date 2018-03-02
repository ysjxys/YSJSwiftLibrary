//
//  Common.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public let WidthScreen: CGFloat = UIScreen.main.bounds.size.width
public let HeightScreen: CGFloat = UIScreen.main.bounds.size.height
public let HeightNavBar: CGFloat = 44
public let HeightSystemStatus: CGFloat = 20
public let HeightTabBar: CGFloat = 49

// MARK: - Scale
private func adjustValue(_ value: CGFloat) -> CGFloat{
    var result = floor(value)
    let interval: CGFloat = 0.5
    let gap = value - result
    if gap >= 0.5 {
        result += interval
    }
    return result
}

public let Ratio_Scale: CGFloat = WidthScreen / CGFloat(375)

public func UIScale(_ x: CGFloat) -> CGFloat {
    return adjustValue(x * Ratio_Scale)
}

// MARK: - Color
public let BlackColor = UIColor.black
public let WhiteColor = UIColor.white
public let GrayColor = UIColor.gray
public let ClearColor = UIColor.clear
public let MagentaColor = UIColor.magenta
public let RedColor = UIColor.red
public let OrangeColor = UIColor.orange
public let YellowColor = UIColor.yellow
public let GreenColor = UIColor.green
public let BlueColor = UIColor.blue
public let CyanColor = UIColor.cyan
public let PurpleColor = UIColor.purple
public let TableGroupColor = UIColor.groupTableViewBackground
public let BrownColor = UIColor.brown

public func ColorFromHex (_ hex: String, _ alpha: CGFloat = 1) -> UIColor {
    return ColorFromHex(hex: hex, alpha: alpha)
}

func ColorFromHex(hex: String, alpha: CGFloat) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substring(from: 1)
    }
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
}

// MARK: - Font Size
public func FontL(_ fontSize: CGFloat) -> UIFont {
    if UIDevice.current.deviceModel == .iPhone4S || UIDevice.current.deviceModel == .iPhone4{
        return UIFont.systemFont(ofSize: fontSize)
    }else{
        guard let font = UIFont(name: "PingFangSC-Light", size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return font
    }
}

public func FontM(_ fontSize: CGFloat) -> UIFont {
    if UIDevice.current.deviceModel == .iPhone4S || UIDevice.current.deviceModel == .iPhone4{
        return UIFont.systemFont(ofSize: fontSize)
    }else{
        guard let font = UIFont(name: "PingFangSC-Medium", size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return font
    }
}

public func FontR(_ fontSize: CGFloat) -> UIFont {
    if UIDevice.current.deviceModel == .iPhone4S || UIDevice.current.deviceModel == .iPhone4{
        return UIFont.systemFont(ofSize: fontSize)
    }else{
        guard let font = UIFont(name: "PingFangSC-Regular", size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return font
    }
}

public func FontS(_ fontSize: CGFloat) -> UIFont {
    if UIDevice.current.deviceModel == .iPhone4S || UIDevice.current.deviceModel == .iPhone4{
        return UIFont.systemFont(ofSize: fontSize)
    }else{
        guard let font = UIFont(name: "PingFangSC-Semibold", size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return font
    }
}

public func FontB(_ fontSize: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: fontSize)
}
