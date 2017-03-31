//
//  HudProperty.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/31.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public class HudProperty: NSObject {
    //动画参数
    ///动画出现的时间，默认0.4s
    public var inDuration: TimeInterval = 0.4
    ///动画消失的时间，默认0.4s
    public var outDuration: TimeInterval = 0.4
    ///动画方式，默认为zoom
    public var transitionStyle: AHTransitionStyle = .zoom
    ///是否自动消失，默认为true
    public var isAutoDisappear = true
    ///hud显示持续时间，默认为1s
    public var hudLastTime: TimeInterval = 1
    ///hud消失后的回调闭包
    public var disappearClosure: ( () -> () )?
    
    //蒙版参数
    ///是否需要蒙版，默认为false
    public var isNeedMaskView = false
    ///蒙版View，默认为nil，可自定义，若不自定义则会自动生成
    public var maskView: UIView?
    ///蒙版透明度，默认0.3
    public var maskViewAlpha: CGFloat = CGFloat(0.3)
    ///蒙版背景色，默认black
    public var maskViewBackgroundColor = UIColor.black
    
    //hud整体参数
    ///hud宽度，默认为4.7寸下200，随屏等比例变化
    public var hudWidth = ahScreenFitSize(200)
    ///hud宽度是否自适应，默认为true
    public var isHudWidthFitSize = true
    ///hud边框与内部控件留白宽度，默认为4.7寸下10，随屏等比例变化
    public var hudTopBottomEmptyDistance = ahScreenFitSize(10)
    ///hud背景色，默认为white
    public var hudBackgroundColor = UIColor.white
    
    //小菊花参数
    ///是否显示小菊花，默认为true
    public var isShowActivityIndicator = true
    ///小菊花颜色，默认为lightGray
    public var activityColor = UIColor.lightGray
    ///小菊花大小，默认为4.7寸下 40*40，随屏等比例变化
    public var activitySize: CGSize = CGSize(width: ahScreenFitSize(AHCGFloatHudActivityDefaultSize), height: ahScreenFitSize(AHCGFloatHudActivityDefaultSize))
    
    //messageView参数
    ///message内容，默认为空
    public var message = ""
    ///messageView左右留白空间值，默认为4.7寸下的10，随屏等比例变化
    public var messageLeftRightDistance = ahScreenFitSize(AHCGFloatMessaheLabelDefaultDistance)
    ///message文字颜色，默认为lightGrey
    public var messageColor = UIColor.lightGray
    ///message文字格式，默认为systemFont size:17
    public var messageTextFont = UIFont.systemFont(ofSize: 17)
    
    //用户自定义图片参数
    ///用户自定义图片，默认为nil
    public var customImage: UIImage?
    ///用户自定义图片大小
    public var customImageSize: CGSize?
    ///用户自定义图片相对于message的所在位置，默认为left，图片在message左侧
    public var imagePlace: ImagePlace = .left
    
    //用户自定义view
    ///用户自定义View，默认为nil，若指定则会覆盖全部HudVC
    public var customView: UIView?
}
