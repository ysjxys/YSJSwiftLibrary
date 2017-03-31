//
//  AlertProperty.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/29.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public class AlertProperty: NSObject {
    //动画参数
    ///动画出现的时间，默认0.4s
    public var inDuration: TimeInterval = 0.4
    ///动画消失的时间，默认0.4s
    public var outDuration: TimeInterval = 0.4
    ///动画方式，默认为zoom
    public var transitionStyle: AHTransitionStyle = .zoom
    
    //蒙版参数
    ///是否需要蒙版，默认为true
    public var isNeedMaskView = true
    ///蒙版View，默认为nil，可自定义，若不自定义则会自动生成
    public var maskView: UIView?
    ///蒙版透明度，默认0.3
    public var maskViewAlpha: CGFloat = CGFloat(0.3)
    ///蒙版背景色，默认black
    public var maskViewBackgroundColor = UIColor.black
    
    //弹窗整体参数
    ///弹窗宽度，默认为4.7寸下300，随屏等比例变化
    public var alertViewWidth = ahScreenFitSize(AHCGFloatAlertDefaultWidth)
    ///弹窗背景色，默认为white
    public var alertBackgroundColor = UIColor.white
    
    //标题栏参数
    ///标题栏高度，默认为4.7寸下40，随屏等比例变化
    public var titleHeight = ahScreenFitSize(AHCGFloatTitleDefaultHeight)
    ///标题栏文字，默认为nil
    public var titleText: String?
    ///标题文字颜色，默认为black
    public var titleColor = UIColor.black
    ///标题文字格式，默认为systemFont，size:18
    public var titleTextFont = UIFont.systemFont(ofSize: 18)
    
    //messageView参数
    ///message内容，默认为空
    public var message = ""
    ///messageView左右留白空间值，默认为4.7寸下的10，随屏等比例变化
    public var messageLeftRightDistance = ahScreenFitSize(AHCGFloatMessaheLabelDefaultDistance)
    ///指定messageView的高度，默认为nil，不进行赋值messageView的height会随文字自适应
    public var messageHeight: CGFloat?
    ///message文字颜色，默认为lightGrey
    public var messageColor = UIColor.lightGray
    ///message文字格式，默认为systemFont size:15
    public var messageTextFont = UIFont.systemFont(ofSize: 15)
    ///title与message参数设定闭包，可以在此内设定详细的titleLabel与messageLabel参数
    public var titleMessageLabelsAttributeClosure: ( (UILabel, UILabel?) -> () )?
    
    //按钮参数
    ///按钮高度，默认为4.7寸下44，随屏等比例变化
    public var btnHeight = ahScreenFitSize(AHCGFloatBtnDefaultHeight)
    ///按钮排列方式，默认为水平排列
    public var isBtnHorizontal = true
    ///按钮标题数组，以此为准创建按钮
    public var btnTitleArray: [String] = []
    ///按钮参数设定闭包，可以在此内设定详细的UIButtom参数
    public var btnAttributeClosure: ( ([UIButton]) -> () )?
    ///按钮按下回调闭包，int为此按钮在标题数组内的下标
    public var btnSelectClosure: ( (UIButton, Int) -> () )?
    
    //分割线参数
    ///是否需要titleLable与messageLabel的分割线，默认为true
    public var isNeedTitleMessageSeparateLine = true
    ///是否需要messageLabel与btn的分割线，默认为true
    public var isNeedMessageBtnSeparateLine = true
    ///是否需要btn之间的分割线，默认为true
    public var isNeedBtnsSeparateLine = true
    ///分割线颜色，默认为groupTableViewBackground
    public var separateLineColor = UIColor.groupTableViewBackground
    ///分割线粗细，默认为0.5
    public var separateLineWidth = CGFloat(0.5)
    
    //用户自定义view
    ///用户自定义View，默认为nil，若指定则会覆盖全部AlertVC
    public var customView: UIView?
    ///用户自定义messageView，默认为nil，若指定会覆盖messageView
    public var customMessageView: UIView?
}
