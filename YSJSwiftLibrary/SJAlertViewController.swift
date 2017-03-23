//
//  SJAlertViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

public class SJAlertViewController: SJAlertHudViewController, UIViewControllerTransitioningDelegate {
    
//    public var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    
    ///是否需要蒙版
    public var isNeedMaskView = true
    public var isNeedTitleMessageSeparateLine = true
    public var isNeedMessageBtnSeparateLine = true
    public var isNeedBtnsSeparateLine = true
    ///蒙版View
    public var maskView: UIView?
    public var maskViewAlpha: CGFloat = CGFloat(0.5)
    public var maskViewBackgroundColor = UIColor.black
    ///用户自定义View
    public var customView: UIView?
    ///
    public var titleLabel = UILabel()
    public var isMessageFitSize = true
    public var messageLabel = UILabel()
    public var btnView = UIView()
    
    var alertView = UIView()
    var btnArray: [UIButton] = []
    
    var delegate = SJPresentationManager(transitionStyle: .bounceDown, interactVC: nil, inDuration: 0.4, outDuration: 0.4)
    
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
    
    public var transitionStyle: SJTransitionStyle = .bounceDown {
        didSet{
            delegate.transitionStyle = transitionStyle
        }
    }
    
    public var titleText: String?
    public var message = ""
    public var titleColor = UIColor.black
    public var titleTextFont = UIFont.systemFont(ofSize: 18)
    public var messageColor = UIColor.lightGray
    public var messageTextFont = UIFont.systemFont(ofSize: 15)
    
    
    public var btnTitleArray: [String] = []
    public var btnSelectClosure: ( (UIButton, Int) -> () )?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = delegate
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
        
        
        if let customView = customView {
            customView.snp.makeConstraints({ (make) in
                make.center.equalTo(view)
                make.width.equalTo(customView.frame.width)
                make.height.equalTo(customView.frame.height)
            })
            view.addSubview(customView)
            return
        }
        
        //添加alertView
        alertView.backgroundColor = UIColor.white
        alertView.layer.cornerRadius = 5
        alertView.layer.shadowOffset = CGSize(width: 3, height: 3)
        alertView.layer.shadowOpacity = 0.7
        alertView.layer.shadowRadius = 5
        alertView.layer.shadowColor = UIColor.lightGray.cgColor
        view.addSubview(alertView)
        //计算alertView高度
        var messageHeight = ahScreenFitSize(AHCGFloatMessageHeight)
        if isMessageFitSize {
            let size = ahStingFitSize(string: message, font: messageTextFont, maxSize: CGSize(width: ahScreenFitSize(AHCGFloatMessaheLabelWidth), height: CGFloat.greatestFiniteMagnitude))
            messageHeight = size.height + 10
        }
        alertView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(ahScreenFitSize(AHCGFloatAlertWidth))
            make.height.equalTo(ahScreenFitSize(AHCGFloatBtnHeight+AHCGFloatTitleHeight) + messageHeight)
        }
        
        
        //titleLabel
        titleLabel.text = titleText
        titleLabel.textColor = titleColor
        titleLabel.font = titleTextFont
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(alertView)
            make.left.equalTo(alertView)
            make.right.equalTo(alertView)
            make.height.equalTo(ahScreenFitSize(AHCGFloatTitleHeight))
        }
        
        
        //buttonView
        btnView.backgroundColor = UIColor.clear
        alertView.addSubview(btnView)
        btnView.snp.makeConstraints { (make) in
            make.bottom.equalTo(alertView)
            make.left.equalTo(alertView)
            make.right.equalTo(alertView)
            let height = btnTitleArray.count == 0 ? 0 : ahScreenFitSize(AHCGFloatBtnHeight)
            make.height.equalTo(height)
        }
        
        for index in 0..<btnTitleArray.count {
            let btn = UIButton(type: .custom)
            btn.setTitle(btnTitleArray[index], for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.backgroundColor = UIColor.white
            btn.tag = index
            btn.addTarget(self, action: #selector(btnSelect), for: .touchUpInside)
            btnArray.append(btn)
            btnView.addSubview(btn)
            if index == 0 || index == btnTitleArray.count-1 {
                btn.layer.cornerRadius = 5
            }
            btn.snp.makeConstraints({ (make) in
                if index == 0 {
                    make.left.equalTo(btnView)
                }else{
                    make.left.equalTo(btnArray[index-1].snp.right)
                    make.width.equalTo(btnArray[index-1].snp.width)
                }
                make.top.equalTo(btnView)
                make.height.equalTo(btnView)
                
                if index == btnTitleArray.count-1 {
                    make.right.equalTo(btnView)
                }
            })
            //如有需要，添加分割线
            if isNeedBtnsSeparateLine && index != btnTitleArray.count-1{
                let btnsSeparateLine = UILabel()
                btnsSeparateLine.backgroundColor = UIColor.groupTableViewBackground
                btn.addSubview(btnsSeparateLine)
                btnsSeparateLine.snp.makeConstraints({ (make) in
                    make.top.equalTo(btn)
                    make.bottom.equalTo(btn)
                    make.right.equalTo(btn)
                    make.width.equalTo(0.5)
                })
            }
        }
        
        //messageLabel
        messageLabel.text = message
        messageLabel.textColor = messageColor
        messageLabel.font = messageTextFont
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        alertView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(alertView)
            make.right.equalTo(alertView)
            make.bottom.equalTo(btnView.snp.top)
        }
        
        //分割线
        if isNeedTitleMessageSeparateLine {
            let titleMessageSeparateLine = UILabel()
            titleMessageSeparateLine.backgroundColor = UIColor.groupTableViewBackground
            messageLabel.addSubview(titleMessageSeparateLine)
            titleMessageSeparateLine.snp.makeConstraints({ (make) in
                make.left.equalTo(messageLabel)
                make.top.equalTo(messageLabel)
                make.right.equalTo(messageLabel)
                make.height.equalTo(0.5)
            })
        }
        
        if isNeedMessageBtnSeparateLine {
            let messageBtnSeparateLine = UILabel()
            messageBtnSeparateLine.backgroundColor = UIColor.groupTableViewBackground
            messageLabel.addSubview(messageBtnSeparateLine)
            messageBtnSeparateLine.snp.makeConstraints({ (make) in
                make.left.equalTo(messageLabel)
                make.bottom.equalTo(messageLabel)
                make.right.equalTo(messageLabel)
                make.height.equalTo(0.5)
            })
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("SJAlertViewController deinit")
    }
    
    func btnSelect(btn: UIButton) {
        if btnSelectClosure != nil {
            btnSelectClosure!(btn, btn.tag)
        }
    }
}
