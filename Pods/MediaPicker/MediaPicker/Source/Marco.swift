//
//  Marco.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import UIKit
import Photos

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


let IPImageNameAdditionIcon = "MP_addition_icon"
let IPImageNamePhotoAlbumIcon = "MP_Photo_album_icon"
let IPImageNamePlayButtonIcon = "MP_play_button_icon"
let IPImageNameRemoveIcon = "MP_remove_icon"
let IPImageNameSelectCamera = "MP_select_cameta"
let IPImageNameUmSelectCamera = "MP_um_select_camera"
let IPImageNameWhiteReturnIcon = "MP_white_return_icon"


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
let IPStringCameraRollEnglish = "Camera Roll"
let IPStringAllPhotosEnglish = "All Photos"



let IPCompareRatio = UIScreen.main.bounds.width/CGFloat(375)

func appName() -> String {
    guard let tempName: String = Bundle.main.infoDictionary!["CFBundleName"] as? String else {
        return ""
    }
    return tempName
}

func imageFromBundle(imageName: String) -> (UIImage?){
    if let url = Bundle(for: ImagePickerViewController.self).url(forResource: "MediaPicker", withExtension: "bundle") {
        return UIImage(named: imageName, in: Bundle(url: url), compatibleWith: nil)
    }
    return nil
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

func createAlert(title: String) -> UIView {
    let label = UILabel()
    label.text = title
    label.backgroundColor = UIColor.white
    label.textColor = UIColor.lightGray
    label.layer.cornerRadius = 5
    label.layer.borderColor = UIColor.clear.cgColor
    label.clipsToBounds = true
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 17)
    
    let cornerRadiusBackView = UIView()
    cornerRadiusBackView.backgroundColor = UIColor.clear
    cornerRadiusBackView.layer.shadowOffset = CGSize(width: 3, height: 3)
    cornerRadiusBackView.layer.shadowOpacity = 0.7
    cornerRadiusBackView.layer.shadowRadius = 5
    cornerRadiusBackView.layer.shadowColor = UIColor.lightGray.cgColor
    let size = title.boundingRect(with: CGSize(width: 240, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil).size
    cornerRadiusBackView.frame = CGRect(x: 0, y: 0, width: size.width+60, height: size.height+30)
    
    label.frame = CGRect(x: 0, y: 0, width: cornerRadiusBackView.frame.width, height: cornerRadiusBackView.frame.height)
    cornerRadiusBackView.addSubview(label)
    
    return cornerRadiusBackView
}

func showHud(targetView: UIView, title: String, completeClosure:( () -> () )? ){
    DispatchQueue.main.async {
        let cornerRadiusBackView = createAlert(title: title)
        cornerRadiusBackView.center = targetView.center
        targetView.addSubview(cornerRadiusBackView)
        
        UIView.animate(withDuration: 2, animations: {
            cornerRadiusBackView.alpha = 0.99
        }) { (isFinish1) in
            UIView.animate(withDuration: 0.5, animations: {
                cornerRadiusBackView.alpha = 0
            }, completion: { (isFinish2) in
                cornerRadiusBackView.removeFromSuperview()
                if completeClosure != nil{
                    completeClosure!()
                }
            })
        }
    }
}

func checkAndChangeBars(controller: UIViewController, shouldPopVC: UIViewController?) {
    if MPProperty.isComingVCStatusBarShow {
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }else{
        UIApplication.shared.setStatusBarHidden(true, with: .none)
    }
    if MPProperty.isShowByPresent {
        controller.dismiss(animated: true, completion: nil)
    }else{
        if let shouldPopVC = shouldPopVC {
            controller.hidesBottomBarWhenPushed = MPProperty.isComingVCTabBarShow ? false : true
            if MPProperty.isComingVCNavigationBarShow {
                controller.navigationController?.setNavigationBarHidden(false, animated: true)
            }else{
                controller.navigationController?.setNavigationBarHidden(true, animated: true)
            }
            
            _ = controller.navigationController?.popToViewController(shouldPopVC, animated: true)
        }else {
            _ = controller.navigationController?.popToRootViewController(animated: true)
        }
    }
}

