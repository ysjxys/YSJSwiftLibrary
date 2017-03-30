//
//  AlertViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

public class AlertViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
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
    public var alertProperty: AlertProperty = shareAlertProperty {
        didSet{
            message = alertProperty.message
        }
    }
    
    public static var shareAlertProperty = AlertProperty()
    ///是否需要蒙版
    public var isNeedMaskView = true
    ///蒙版View
    public var maskView: UIView?
    public var maskViewAlpha: CGFloat = CGFloat(0.3)
    public var maskViewBackgroundColor = UIColor.black
    
    ///用户自定义View
    public var customView: UIView?
    public var customMessageView: UIView?
    
    public var messageLeftRightDistance = ahScreenFitSize(AHCGFloatMessaheLabelDefaultDistance)
    var messageLabel: UILabel?
    public var messageHeight: CGFloat?
//    public var message = alertProperty.message
    public var message = ""
    public var messageColor = UIColor.lightGray
    public var messageTextFont = UIFont.systemFont(ofSize: 15)
    
    public var isNeedTitleMessageSeparateLine = true
    public var isNeedMessageBtnSeparateLine = true
    public var isNeedBtnsSeparateLine = true
    public var separateLineColor = UIColor.groupTableViewBackground
    public var separateLineWidth = CGFloat(0.5)
    
    public var alertViewWidth = ahScreenFitSize(AHCGFloatAlertDefaultWidth)
    public var alertBackgroundColor = UIColor.white
    
    public var titleHeight = ahScreenFitSize(AHCGFloatTitleDefaultHeight)
    public var titleText: String?
    public var titleColor = UIColor.black
    public var titleTextFont = UIFont.systemFont(ofSize: 18)
    
    public var btnHeight = ahScreenFitSize(AHCGFloatBtnDefaultHeight)
    public var isBtnHorizontal = true
    public var btnTitleArray: [String] = []
    var btnArray: [UIButton] = []
    public var btnAttributeClosure: ( ([UIButton]) -> () )?
    public var btnSelectClosure: ( (UIButton, Int) -> () )?
    public var titleMessageLabelsAttributeClosure: ( (UILabel, UILabel?) -> () )?
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = delegate
        self.modalPresentationStyle = .overFullScreen
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
        
        //添加alertView
        let alertView = UIView()
        alertView.backgroundColor = UIColor.clear
        alertView.layer.shadowOffset = CGSize(width: 3, height: 3)
        alertView.layer.shadowOpacity = 0.7
        alertView.layer.shadowRadius = 5
        alertView.layer.shadowColor = UIColor.lightGray.cgColor
        view.addSubview(alertView)
        
        if customView == nil {
            //计算alertView高度
            var messageViewHeight: CGFloat
            if let customMessageView = customMessageView{
                //自定义了customMessageView,以自定义的frame为准，未定义frame，则为默认高度80
                messageViewHeight = customMessageView.frame.height == 0 ? ahScreenFitSize(AHCGFloatMessageDefaultHeight) : customMessageView.frame.height
            }else if let messageHeight = messageHeight {
                //未自定义customMessageView，使用默认的messageView，则优先判断是否自定义高度
                messageViewHeight = ahScreenFitSize(messageHeight)
            }else{
                //也没有自定义高度，则计算文字内容自适应高度
                let size = ahStingFitSize(string: message, font: messageTextFont, maxSize: CGSize(width: alertViewWidth-messageLeftRightDistance*2, height: CGFloat.greatestFiniteMagnitude))
                messageViewHeight = size.height+20
            }
            
            alertView.snp.makeConstraints { (make) in
                make.center.equalTo(view)
                make.width.equalTo(ahScreenFitSize(alertViewWidth))
                if isBtnHorizontal{
                    make.height.equalTo(ahScreenFitSize(btnHeight+titleHeight) + messageViewHeight)
                }else{
                    make.height.equalTo(ahScreenFitSize(btnHeight*CGFloat(btnTitleArray.count)+titleHeight) + messageViewHeight)
                }
            }
        }else{
            alertView.snp.makeConstraints { (make) in
                make.center.equalTo(view)
                make.width.equalTo(customView!.frame.width)
                make.height.equalTo(customView!.frame.height)
            }
        }
        
        
        let cornerRadiusBackView = UIView()
        cornerRadiusBackView.backgroundColor = alertBackgroundColor
        cornerRadiusBackView.layer.cornerRadius = 5
        cornerRadiusBackView.clipsToBounds = true
        alertView.addSubview(cornerRadiusBackView)
        cornerRadiusBackView.snp.makeConstraints { (make) in
            make.center.equalTo(alertView)
            make.height.equalTo(alertView)
            make.width.equalTo(alertView)
        }
        
        if let customView = customView {
            cornerRadiusBackView.addSubview(customView)
            customView.snp.makeConstraints({ (make) in
                make.center.equalTo(cornerRadiusBackView)
                make.width.equalTo(cornerRadiusBackView)
                make.height.equalTo(cornerRadiusBackView)
            })
            return
        }
        
        //titleLabel
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = titleColor
        titleLabel.font = titleTextFont
        titleLabel.textAlignment = .center
        cornerRadiusBackView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(alertView)
            make.left.equalTo(alertView)
            make.right.equalTo(alertView)
            make.height.equalTo(ahScreenFitSize(titleHeight))
        }
        
        
        //buttonView
        let btnView = UIView()
        btnView.backgroundColor = UIColor.clear
        cornerRadiusBackView.addSubview(btnView)
        btnView.snp.makeConstraints { (make) in
            make.bottom.equalTo(alertView)
            make.left.equalTo(alertView)
            make.right.equalTo(alertView)
            let height: CGFloat
            if isBtnHorizontal {
                //按钮水平布局
                height = btnTitleArray.count == 0 ? 0 : ahScreenFitSize(btnHeight)
            }else{
                //按钮垂直布局
                height = CGFloat(btnTitleArray.count) * ahScreenFitSize(btnHeight)
            }
            make.height.equalTo(height)
        }
        
        for index in 0..<btnTitleArray.count {
            let btn = UIButton(type: .custom)
            btn.setTitle(btnTitleArray[index], for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.backgroundColor = UIColor.clear
            btn.tag = index
            btn.addTarget(self, action: #selector(btnSelect), for: .touchUpInside)
            btnArray.append(btn)
            btnView.addSubview(btn)
            if isBtnHorizontal {
                //按钮水平布局
                btn.snp.makeConstraints({ (make) in
                    make.top.equalTo(btnView)
                    make.height.equalTo(btnView)
                    if index == 0 {
                        make.left.equalTo(btnView)
                    }else{
                        make.left.equalTo(btnArray[index-1].snp.right)
                        make.width.equalTo(btnArray[index-1].snp.width)
                    }
                    if index == btnTitleArray.count-1 {
                        make.right.equalTo(btnView)
                    }
                })
                //如有需要，添加分割线
                if isNeedBtnsSeparateLine && index != btnTitleArray.count-1{
                    let btnsSeparateLine = UILabel()
                    btnsSeparateLine.backgroundColor = separateLineColor
                    btn.addSubview(btnsSeparateLine)
                    btnsSeparateLine.snp.makeConstraints({ (make) in
                        make.top.equalTo(btn)
                        make.bottom.equalTo(btn)
                        make.right.equalTo(btn)
                        make.width.equalTo(separateLineWidth)
                    })
                }
            }else{
                //按钮垂直布局
                btn.snp.makeConstraints({ (make) in
                    make.left.equalTo(btnView)
                    make.right.equalTo(btnView)
                    make.height.equalTo(ahScreenFitSize(btnHeight))
                    if index == 0{
                        make.top.equalTo(btnView)
                    }else{
                        make.top.equalTo(btnArray[index-1].snp.bottom)
                    }
                })
                
                if isNeedBtnsSeparateLine && index != btnTitleArray.count-1 {
                    let btnsSeparateLine = UILabel()
                    btnsSeparateLine.backgroundColor = separateLineColor
                    btn.addSubview(btnsSeparateLine)
                    btnsSeparateLine.snp.makeConstraints({ (make) in
                        make.left.equalTo(btn)
                        make.right.equalTo(btn)
                        make.bottom.equalTo(btn)
                        make.height.equalTo(separateLineWidth)
                    })
                }
            }
            
        }
        if let btnAttributeClosure = btnAttributeClosure{
            btnAttributeClosure(btnArray)
        }
        
        //messageView
        let messageView: UIView
        if let customMessageView = customMessageView {
            //若自定义了customMessageView， 添加之
            messageView = customMessageView
        }else{
            //若没有自定义customMessageView，添加默认messageLabel
            messageLabel = UILabel()
            messageLabel?.text = message
            messageLabel?.textColor = messageColor
            messageLabel?.font = messageTextFont
            messageLabel?.textAlignment = .center
            messageLabel?.numberOfLines = 0
            messageView = messageLabel!
        }
        messageView.clipsToBounds = true
        cornerRadiusBackView.insertSubview(messageView, belowSubview: titleLabel)
        messageView.snp.makeConstraints({ (make) in
//            make.centerX.equalTo(alertView)
            
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(alertView).offset(messageLeftRightDistance)
            make.right.equalTo(alertView).offset(-messageLeftRightDistance)
            make.bottom.equalTo(btnView.snp.top)
        })
        
        if let titleMessageLabelsAttributeClosure = titleMessageLabelsAttributeClosure {
            titleMessageLabelsAttributeClosure(titleLabel, messageLabel)
        }
        
        
        //分割线
        if isNeedTitleMessageSeparateLine {
            let titleMessageSeparateLine = UILabel()
            titleMessageSeparateLine.backgroundColor = separateLineColor
            titleLabel.addSubview(titleMessageSeparateLine)
            titleMessageSeparateLine.snp.makeConstraints({ (make) in
                make.left.equalTo(titleLabel)
                make.bottom.equalTo(titleLabel)
                make.right.equalTo(titleLabel)
                make.height.equalTo(separateLineWidth)
            })
        }
        
        if isNeedMessageBtnSeparateLine {
            let messageBtnSeparateLine = UILabel()
            messageBtnSeparateLine.backgroundColor = separateLineColor
            btnView.addSubview(messageBtnSeparateLine)
            messageBtnSeparateLine.snp.makeConstraints({ (make) in
                make.left.equalTo(btnView)
                make.top.equalTo(btnView)
                make.right.equalTo(btnView)
                make.height.equalTo(separateLineWidth)
            })
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("AlertViewController deinit")
    }
    
    func btnSelect(btn: UIButton) {
        if btnSelectClosure != nil {
            btnSelectClosure!(btn, btn.tag)
        }
    }
    
    func quitAlert(completeClosure: ( () -> () )? ) {
        dismiss(animated: true, completion: completeClosure)
    }
}
