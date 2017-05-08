//
//  MPProperty.swift
//  MediaPicker
//
//  Created by ysj on 2017/5/4.
//  Copyright © 2017年 XGN. All rights reserved.
//

import Foundation
import UIKit
import Photos

public class MPProperty: NSObject {
    //主题颜色
    public static var themeColor = ipColorFromHex(IPHexColorNextBtn)
    //图片选择按钮背景色
    public static var selectBackgroundColor = ipColorFromHex(IPHexColorNextBtn)
    //图片选择按钮文字颜色
    public static var selectNumTextColor = ipColorFromHex(IPHexColorSelectNumLabelText)
    //是否在shareImage模式下启用勾选图片
    public static var isUseSelectImageInShareImageType = false
    //选择模式，头像模式或分享模式，默认为分享模式
    public static var chooseType: ChooseType = .shareImageType
    //选择分享模式时的最大可选图片数量
    public static var maxChooseNum = 9
    //勾选图片
    public static var selectImage: UIImage? = imageFromBundle(imageName: IPImageNameSelectCamera)
    //头像选择模式回调
    public static var chooseHeadImageClosure: ( (UIImage) -> () )?
    //分享模式PHAsset回调
    public static var chooseShareAssetClosure: ( ([PHAsset]) -> () )?
    //分享模式image回调指定图片的大小
    public static var resultImageTargetSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    //分享模式image回调
    public static var chooseShareImageClosure: ( ([UIImage]) -> () )?
    //失败回调
    public static var failClosure: ( () -> () )?
    //展示模式，默认为present式
    public static var isShowByPresent = true
    //进入MediaPlayer的页面的tabBar是否显示
    public static var isComingVCTabBarShow = true
    //进入MediaPlayer的页面的navigationBar是否显示
    public static var isComingVCNavigationBarShow = true
    //进入MediaPlayer的页面的statusBar是否显示
    public static var isComingVCStatusBarShow = true
}
