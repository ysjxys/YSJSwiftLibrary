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
        
        let showBtn = UIButton(frame: CGRect(x: 120, y: 200, width: view.frame.width-120*2, height: 70))
        showBtn.setTitle("显示", for: .normal)
        showBtn.setTitleColor(UIColor.white, for: .normal)
        showBtn.backgroundColor = UIColor.lightGray
        showBtn.addTarget(self, action: #selector(showBtnClick), for: .touchUpInside)
        view.addSubview(showBtn)
    }
    
    func rightBarBtnClick() {
        
    }
    
    func showBtnClick() {
        let alert = SJAlertViewController()
//        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .custom
        alert.isNeedMaskView = true
        alert.transitionStyle = .fadeIn
        alert.inDuration = 0.8
        alert.outDuration = 0.1
        alert.btnTitleArray = ["取消", "标题2", "标题3"]
        alert.titleText = "我是标题我是标题"
        alert.message = "我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容"
        alert.isMessageFitSize = true
        alert.btnSelectClosure = {(btn, index) in
            print("\(index) btn click")
            if index == 0 {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
