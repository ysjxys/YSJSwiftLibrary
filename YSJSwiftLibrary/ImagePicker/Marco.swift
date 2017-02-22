//
//  Marco.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import UIKit
import MBProgressHUD


let ImageCollectionCellViewIdentifier = "ImageCollectionCellViewIdentifier"
let EditImageTextCellViewIdentifier = "EditImageTextCellViewIdentifier"


//IP = ImagePicker
let IPCGFloatCellWidth = CGFloat(122)
let IPCGFloatCellBetweenDistance = CGFloat(4.5)
let IPCGFloatCollectionViewTopDistance = CGFloat(5.5)
let IPCGFloatCollectionSelectRoundDiameter = CGFloat(25)
let IPCGFloatCollectionSelectRoundDistance = CGFloat(5)
let IPCGFloatCollectionSelectRoundBorderWidth = CGFloat(1)

let IPCGFloatChooseSureBtnRightDistance = CGFloat(15)
let IPCGFloatDetailTopViewHeight = CGFloat(64)
let IPCGFloatDetailBackIconLeftDistance = CGFloat(23)
let IPCGFloatDetailBottomViewHeight = CGFloat(55)
let IPCGFloatDetailSelectBtnWidth = CGFloat(25)

let IPCGFloatEditImageTextFieldDistance = CGFloat(14)
let IPCGFloatEditImageTextFieldHeight = CGFloat(112.5)
let IPCGFloatEditImageViewDistance = CGFloat(4)
let IPCGFloatEditImageDeleteImageWidth = CGFloat(16.5)



let IPHexColorNavigationTitle = "333333"
let IPHexColorNextBtn = "5dd1d5"
let IPHexColorDetailTopView = "000000"//black
let IPHexColorSelectNumLabelText = "ffffff"//white


let IPStringCancel = "取消"
let IPStringCamera = "相机"
let IPStringAllPhotos = "所有照片"
let IPStringNextStep = "下一步"
let IPStringPhotoLibraryForbiddenWarningMsg = "获得照片权限被关闭，请在 设置-隐私-相册 中开启"
let IPStringCameraRoll = "相机胶卷"
let IPStringSelectAtLeastOne = "请至少选则一个"
let IPStringSelectTheMost = "不能选择更多"
let IPStringComplete = "完成"
let IPStringPublishState = "发动态"
let IPStringBack = "返回"

let IPCompareRatio = UIScreen.main.bounds.width/CGFloat(375)

func appName() -> String {
    guard let tempName: String = Bundle.main.infoDictionary!["CFBundleName"] as? String else {
        return ""
    }
    return tempName
}

func ipFitSize(_ originalSize: CGFloat) -> (CGFloat) {
    return CGFloat(Int(originalSize * IPCompareRatio * CGFloat(100))/Int(1))/CGFloat(100)
}

func ipColorFromHex (_ hex: String) -> UIColor {
    return ipColorFromHex(hex: hex, alpha: CGFloat(1))
}

func ipColorFromHex(hex: String, alpha: CGFloat) -> UIColor {
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

func showHudWith(targetView: UIView, title: String) {
    let hud = MBProgressHUD(view: targetView)
    hud.label.text = title
    hud.mode = .text
    targetView.addSubview(hud)
    hud.show(animated: true, whileExecuting: { 
        sleep(UInt32(1.5))
    }) {
        hud.removeFromSuperview()
    }
}



