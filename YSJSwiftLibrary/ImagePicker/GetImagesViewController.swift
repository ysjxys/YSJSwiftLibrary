//
//  GetImagesViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/2/14.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos

class GetImagesViewController: UIViewController {
    
    var isComingFromDetail = false
    var updateSelectArray: [ImageCellModel] = []
    var maxChooseNum = 1
    
    // MARK: - LifeCircle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: IPStringBack, style: .plain, target: self, action: #selector(popVC))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func popToDetailVC() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.post(name: updateArrayDetailVCNotificationName, object: self, userInfo: [updateArrayDetailVCUserInfoKey:updateSelectArray])
        NotificationCenter.default.post(name: changeScreenDirectionNotificationName, object: self, userInfo: [changeScreenDirectionUserInfoKey: view.frame.size])
        _ = navigationController?.popViewController(animated: true)
    }
    
    func popToListVC() {
        NotificationCenter.default.post(name: updateArrayCollectionVCNotificationName, object: self, userInfo: [updateArrayCollectionVCUserInfoKey: updateSelectArray])
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - BtnClick Method
    func popVC() {
        if isComingFromDetail {
            popToDetailVC()
        }else{
            popToListVC()
        }
    }
}
