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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "right", style: .plain, target: self, action: #selector(rightBarBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_annou_un").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightBarBtnClick))
        navigationItem.rightBarButtonItem?.addBadge()
        
        let label = YSJLabel()
//        label.frame = CGRect(x: 120, y: 100, width: view.frame.width-120*2, height: 70)
        label.backgroundColor = UIColor.lightGray
        label.text = "我是测试文字"
        label.textAlignment = .center
        label.verticalAlignment = .top
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(100)
//            make.left.equalToSuperview().offset(120)
//            make.height.equalTo(70)
//            make.right.equalToSuperview().inset(120)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(200)
            make.width.equalTo(200)
            make.height.equalTo(70)
        }

//        let alertBtn = UIButton(frame: CGRect(x: 120, y: 200, width: view.frame.width-120*2, height: 70))
//        alertBtn.setTitle("显示Alert", for: .normal)
//        alertBtn.setTitleColor(UIColor.white, for: .normal)
//        alertBtn.backgroundColor = UIColor.lightGray
//        alertBtn.addTarget(self, action: #selector(alertBtnClick), for: .touchUpInside)
//        view.addSubview(alertBtn)
//
//
//        let hudBtn = UIButton(frame: CGRect(x: 120, y: 350, width: view.frame.width-120*2, height: 70))
//        hudBtn.setTitle("显示Hud", for: .normal)
//        hudBtn.setTitleColor(UIColor.white, for: .normal)
//        hudBtn.backgroundColor = UIColor.lightGray
//        hudBtn.addTarget(self, action: #selector(hudBtnClick), for: .touchUpInside)
//        view.addSubview(hudBtn)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.purple
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.top.equalToSuperview().offset(100)
        }
        imageView.image = UIImage.addLogoImage(oriImage: #imageLiteral(resourceName: "video_icon"), logoImage: #imageLiteral(resourceName: "delete_button_icon"), resultImageSize: CGSize(width: 100, height: 100), logoImageRect: CGRect(x: 75, y: 50, width: 25, height: 25))
    }
    
    @objc func rightBarBtnClick() {
        
    }
    
//    @objc func hudBtnClick() {
//        let hud = HudViewController()
//        let hudProperty = hud.hudProperty
//        hudProperty.message = "我就问你这有什么影响我就问你这有什么影响"
//        hudProperty.customImage = UIImage(named: "camera_button_icon")
//        hudProperty.imagePlace = .top
//        hudProperty.disappearClosure = {
//            print("hud is disappear")
//        }
//        hud.updateProperty()
//        self.present(hud, animated: true, completion: nil)
//    }
//
//    @objc func alertBtnClick() {
//        let alert = AlertViewController()
//        let alertProperty = alert.alertProperty
//        alertProperty.btnTitleArray = ["取消", "标题2", "标题3"]
//        alertProperty.titleText = "我是标题我是标题"
//        alertProperty.message = "我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容"
//        alertProperty.btnSelectClosure = {(btn, index) in
//            print("index:\(index) selected")
//            if index == 0{
//                alert.quitAlert(completeClosure: nil)
//            }
//        }
//        alert.updateProperty()
//        self.present(alert, animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
