//
//  SecondViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController:  UIViewController{
    
    var transitionStyle: SJTransitionStyle = .bounceDown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "right", style: .plain, target: self, action: #selector(rightBarBtnClick))
        
        let alertBtn = UIButton(frame: CGRect(x: 120, y: 200, width: view.frame.width-120*2, height: 70))
        alertBtn.setTitle("显示Alert", for: .normal)
        alertBtn.setTitleColor(UIColor.white, for: .normal)
        alertBtn.backgroundColor = UIColor.lightGray
        alertBtn.addTarget(self, action: #selector(alertBtnClick), for: .touchUpInside)
        view.addSubview(alertBtn)
        
        
        let hudBtn = UIButton(frame: CGRect(x: 120, y: 350, width: view.frame.width-120*2, height: 70))
        hudBtn.setTitle("显示Hud", for: .normal)
        hudBtn.setTitleColor(UIColor.white, for: .normal)
        hudBtn.backgroundColor = UIColor.lightGray
        hudBtn.addTarget(self, action: #selector(hudBtnClick), for: .touchUpInside)
        view.addSubview(hudBtn)
    }
    
    func rightBarBtnClick() {
        
    }
    
    func hudBtnClick() {
        let hud = HudViewController { 
            print("hud is disappear")
        }
//        hud.isShowActivityIndicator = false
        hud.message = "我就问你这有什么影响我就问你这有什么影响"
//        hud.customImage = UIImage(named: "camera_button_icon")
        
//        let customHudView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
//        customHudView.backgroundColor = UIColor.purple
//        let insideView = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
//        insideView.backgroundColor = UIColor.blue
//        customHudView.addSubview(insideView)
//        hud.customView = customHudView
        self.present(hud, animated: true, completion: nil)
    }
    
    func alertBtnClick() {
        let alert = AlertViewController()
//        alert.inDuration = 0.4
//        alert.outDuration = 0.4
//        alert.titleMessageLabelsAttributeClosure = {(titleLabel, messageLabel) in
//            titleLabel.textColor = UIColor.purple
//        }
        
//        let customAlertView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
//        customAlertView.backgroundColor = UIColor.lightGray
//        let insideView = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
//        insideView.backgroundColor = UIColor.blue
//        customAlertView.addSubview(insideView)
//        alert.customMessageView = customAlertView
//        alert.customView = customView
//        alert.messageHeight = 50
//        alert.isBtnHorizontal = false
        
//        alert.separateLineColor = UIColor.yellow
//        alert.separateLineWidth = 2
//        alert.alertViewWidth = 250
//        alert.titleHeight = 100
//        alert.btnHeight = 100
//        alert.messageLeftRightDistance = 20
        alert.btnTitleArray = ["取消", "标题2", "标题3"]
        alert.titleText = "我是标题我是标题"
        alert.message = "我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容"
        
        alert.btnSelectClosure = {(btn, index) in
            print("\(index) btn click")
            if index == 0 {
                alert.quitAlert(completeClosure: nil)
//                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
