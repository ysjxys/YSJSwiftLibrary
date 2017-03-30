//
//  HudViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public enum ImagePlace {
    case top
    case bottom
    case left
    case right
}


public class HudViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var delegate = PresentationManager(transitionStyle: .zoom, interactVC: nil, inDuration: 0.4, outDuration: 0.4)
    public var inDuration: TimeInterval = 0.4 {
        didSet{
            delegate.inDuration = inDuration
        }
    }
    public var outDuration: TimeInterval = 0.4 {
        didSet{
            delegate.outDuration = outDuration
        }
    }
    public var transitionStyle: SJTransitionStyle = .zoom {
        didSet{
            delegate.transitionStyle = transitionStyle
        }
    }
    
    public var isAutoDisappear = true
    public var hudLastTime: TimeInterval = 1
    public var disappearClosure: ( () -> () )?
    
    ///是否需要蒙版
    public var isNeedMaskView = false
    ///蒙版View
    public var maskView: UIView?
    public var maskViewAlpha: CGFloat = CGFloat(0.5)
    public var maskViewBackgroundColor = UIColor.black
    
    ///用户自定义View
    public var customView: UIView?
    
    
    public var hudWidth = ahScreenFitSize(200)
    public var isHudWidthFitSize = true
    public var hudTopBottomEmptyDistance = ahScreenFitSize(10)
    public var hudBackgroundColor = UIColor.white
    
    public var message = ""
    public var messageLeftRightDistance = ahScreenFitSize(AHCGFloatMessaheLabelDefaultDistance)
    public var messageColor = UIColor.lightGray//boldSystemFont
    public var messageTextFont = UIFont.systemFont(ofSize: 17)
    public var isShowActivityIndicator = true
    public var activityColor = UIColor.lightGray
    
    public var activitySize: CGSize = CGSize(width: ahScreenFitSize(AHCGFloatHudActivityDefaultSize), height: ahScreenFitSize(AHCGFloatHudActivityDefaultSize))
    
    public var customImage: UIImage?
    public var customImageSize: CGSize?
    public var imagePlace: ImagePlace = .left
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isAutoDisappear {
            _ = Timer.scheduledTimer(timeInterval: hudLastTime, target: self, selector: #selector(timerOver), userInfo: nil, repeats: false)
        }
    }
    
    init(disappearClosure: ( () -> () )?) {
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = delegate
        self.modalPresentationStyle = .overFullScreen
        self.disappearClosure = disappearClosure
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        //添加蒙版
        if maskView == nil {
            maskView = UIView()
        }
        maskView?.alpha = isNeedMaskView ? maskViewAlpha : 0
        maskView?.backgroundColor = maskViewBackgroundColor
        view.addSubview(maskView!)
        maskView?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view)
        })
        
        //添加hudView
        let hudView = UIView()
        hudView.backgroundColor = UIColor.clear
        hudView.layer.shadowOffset = CGSize(width: 3, height: 3)
        hudView.layer.shadowOpacity = 0.7
        hudView.layer.shadowRadius = 5
        hudView.layer.shadowColor = UIColor.lightGray.cgColor
        view.addSubview(hudView)
        
        //圆角view
        let cornerRadiusBackView = UIView()
        cornerRadiusBackView.backgroundColor = hudBackgroundColor
        cornerRadiusBackView.layer.cornerRadius = 5
        cornerRadiusBackView.clipsToBounds = true
        hudView.addSubview(cornerRadiusBackView)
        
        //若自定义view存在，进入自定义view设定
        if let customView = customView {
            hudView.snp.makeConstraints({ (make) in
                make.center.equalTo(view)
                make.width.equalTo(customView.frame.width)
                make.height.equalTo(customView.frame.height)
            })
            
            cornerRadiusBackView.snp.makeConstraints({ (make) in
                make.center.equalTo(hudView)
                make.width.equalTo(hudView)
                make.height.equalTo(hudView)
            })
            
            cornerRadiusBackView.addSubview(customView)
            customView.snp.makeConstraints({ (make) in
                make.center.equalTo(cornerRadiusBackView)
                make.width.equalTo(cornerRadiusBackView)
                make.height.equalTo(cornerRadiusBackView)
            })
            return
        }
        
        //计算各个控件的高度长度，为hudView及后续view的约束做铺垫
        //小菊花边长
        let activityBorderLength = isShowActivityIndicator ? activitySize.height : 0
        //图片宽高
        var imageHeight: CGFloat
        var imageWidth: CGFloat
        if customImage == nil {
            imageHeight = CGFloat(0)
            imageWidth = CGFloat(0)
        }else if customImageSize != nil {
            imageHeight = customImageSize!.height
            imageWidth = customImageSize!.width
        }else {
            imageHeight = ahScreenFitSize(AHCGFloatHudImageDefaultWidth)
            imageWidth = imageHeight
        }
        //文本大小
        var textSize: CGSize
        if message == "" {
            textSize = CGSize(width: 0, height: 0)
        }else{
            var writeableWidth = hudWidth-messageLeftRightDistance*2
            
            if imagePlace == .left || imagePlace == .right {
                writeableWidth = writeableWidth - imageWidth
            }
            let size = ahStingFitSize(string: message, font: messageTextFont, maxSize: CGSize(width:writeableWidth, height: CGFloat.greatestFiniteMagnitude))
            textSize = CGSize(width: size.width+5, height: size.height+5)
        }
        //图片与其他控件间隙的额外高度
        var extraImageHeight = CGFloat(0)
        if imageHeight != 0 {
            extraImageHeight = hudTopBottomEmptyDistance
        }
        //文本与其他控件间隙的额外高度
        var extraMessageHeight = CGFloat(0)
        if textSize.height != 0 {
            extraMessageHeight = hudTopBottomEmptyDistance
        }
        //间隙边框额外高度总和
        var extraSumHeight = CGFloat(0)
        
        if imagePlace == .left || imagePlace == .right {
            if isShowActivityIndicator && (extraImageHeight != 0 || extraMessageHeight != 0) {
                extraSumHeight = hudTopBottomEmptyDistance
            }
        }else{
            var n = 0
            if isShowActivityIndicator {
                n += 1
            }
            if extraImageHeight != 0 {
                n += 1
            }
            if extraMessageHeight != 0 {
                n += 1
            }
            if n > 1 {
                extraSumHeight = hudTopBottomEmptyDistance*CGFloat(n-1)
            }
        }
        
        //视用户选择计算hudView宽度
        if isHudWidthFitSize {
            var tempWidth = CGFloat(0)
            if activityBorderLength > tempWidth {
                tempWidth = activityBorderLength
            }
            if imagePlace == .bottom || imagePlace == .top {
                if imageWidth > tempWidth {
                    tempWidth = imageWidth
                }
                if textSize.width > tempWidth {
                    tempWidth = textSize.width
                }
                if activityBorderLength > tempWidth {
                    tempWidth = activityBorderLength
                }
            }else{
                if imageWidth+textSize.width > tempWidth {
                    tempWidth = imageWidth+textSize.width
                }
            }
            hudWidth = tempWidth + 2*hudTopBottomEmptyDistance
        }
        
        //为hud添加约束
        hudView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(hudWidth)
            if imagePlace == .left || imagePlace == .right {
                make.height.equalTo(extraSumHeight + hudTopBottomEmptyDistance*2 + activityBorderLength + (imageHeight>textSize.height ? imageHeight : textSize.height))
            }else{
                make.height.equalTo(extraSumHeight + hudTopBottomEmptyDistance*2 + activityBorderLength + imageHeight + textSize.height)
            }
        }
        //为cornerRadiusBackView添加约束
        cornerRadiusBackView.snp.makeConstraints { (make) in
            make.center.equalTo(hudView)
            make.height.equalTo(hudView)
            make.width.equalTo(hudView)
        }
        
        //小菊花view
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.color = activityColor
        activityView.backgroundColor = UIColor.clear
        if isShowActivityIndicator {
            activityView.startAnimating()
        }
        cornerRadiusBackView.addSubview(activityView)
        activityView.snp.makeConstraints { (make) in
            make.top.equalTo(cornerRadiusBackView).offset(hudTopBottomEmptyDistance)
            make.height.equalTo(activityBorderLength)
            make.width.equalTo(activitySize.width)
            make.centerX.equalTo(cornerRadiusBackView)
        }
        
        //图片view
        let imageView = UIImageView()
        imageView.image = customImage
        cornerRadiusBackView.addSubview(imageView)
        //文本信息view
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textColor = messageColor
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.text = message
        messageLabel.font = messageTextFont
        messageLabel.textAlignment = .center
        cornerRadiusBackView.addSubview(messageLabel)
        
        
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(imageWidth)
            make.height.equalTo(imageHeight)
            switch imagePlace {
            case .bottom:
                make.centerX.equalTo(cornerRadiusBackView)
                make.top.equalTo(messageLabel.snp.bottom).offset(extraMessageHeight)
            case .left:
                if textSize.height == 0 {
                    make.top.equalTo(messageLabel)
                }else{
                    make.centerY.equalTo(messageLabel)
                }
                make.left.equalTo(cornerRadiusBackView).offset((hudWidth-imageWidth-textSize.width)/2)
            case .right:
                if textSize.height == 0 {
                    make.top.equalTo(messageLabel)
                }else{
                    make.centerY.equalTo(messageLabel)
                }
                make.right.equalTo(cornerRadiusBackView).offset(-(hudWidth-imageWidth-textSize.width)/2)
            case .top:
                make.centerX.equalTo(cornerRadiusBackView)
                if isShowActivityIndicator {
                    make.top.equalTo(activityView.snp.bottom).offset(hudTopBottomEmptyDistance)
                }else {
                    make.top.equalTo(activityView.snp.bottom)
                }
            }
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.width.equalTo(textSize.width)
            make.height.equalTo(textSize.height)
            switch imagePlace {
            case .bottom:
                make.centerX.equalTo(cornerRadiusBackView)
                if isShowActivityIndicator {
                    make.top.equalTo(activityView.snp.bottom).offset(hudTopBottomEmptyDistance)
                }else {
                    make.top.equalTo(activityView.snp.bottom)
                }
            case .left:
                make.top.equalTo(activityView.snp.bottom).offset(extraSumHeight)
                make.left.equalTo(imageView.snp.right)
            case .right:
                make.top.equalTo(activityView.snp.bottom).offset(extraSumHeight)
                make.right.equalTo(imageView.snp.left)
            case .top:
                make.centerX.equalTo(cornerRadiusBackView)
                make.top.equalTo(imageView.snp.bottom).offset(extraImageHeight)
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("HudViewController deinit")
    }
    
    public func quitHud() {
        dismiss(animated: true, completion: disappearClosure)
    }
    
    func timerOver() {
        quitHud()
    }
}
