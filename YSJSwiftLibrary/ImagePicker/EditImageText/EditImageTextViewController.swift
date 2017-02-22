//
//  EditImageTextViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/30.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import UIKit

class EditImageTextViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
    
    var isComingFromDetail = false
    var updateSelectArray: [ImageCellModel] = []
    var maxChooseNum = 1
    
    
    var textCountLabel = UILabel()
    var textView = UITextView()
    var collectionView: UICollectionView!
    
    var textViewTopConstraint: NSLayoutConstraint!
    
    
    // MARK: - LifeCircle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let backImage = UIImage.init(named: "release_delete_icon")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:backImage , style: .plain, target: self, action: #selector(leftBarBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: IPStringNextStep, style: .plain, target: self, action: #selector(rightBarBtnClick))
        navigationItem.title = IPStringPublishState
        
        self.automaticallyAdjustsScrollViewInsets = false
//        initData()
        initView()
        initConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        _ = updateAddModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - ScreenDirectionChanged Listener Method
    //转屏监听
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if view.frame.width == size.width {
            return
        }
        if size.height > size.width {
            textViewTopConstraint.constant = 64 + ipFitSize(IPCGFloatEditImageTextFieldDistance)
        }else{
            textViewTopConstraint.constant = 52 + ipFitSize(IPCGFloatEditImageTextFieldDistance)
        }
    }
    
    // MARK: - Custom Method
    func initView() {
        guard (self.navigationController != nil) else {
            return
        }
//        textView.tintColor = UIColor.red
        textView.tintColor = ipColorFromHex(IPHexColorNextBtn)
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = ipColorFromHex(IPHexColorNavigationTitle)
        textView.textAlignment = .left
        view.addSubview(textView)
        
        textCountLabel.text = "0/200"
        textCountLabel.font = UIFont.systemFont(ofSize: 14)
        textCountLabel.textColor = UIColor.lightGray
        textCountLabel.textAlignment = .right
        view.addSubview(textCountLabel)
        
        let flowLayout = UICollectionViewFlowLayout()
        let collectionViewY = textCountLabel.frame.height+textCountLabel.frame.origin.y
        collectionView = UICollectionView(frame: CGRect(x: 0, y:collectionViewY , width: view.frame.width, height: view.frame.height - collectionViewY), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditImageTextCellView.self, forCellWithReuseIdentifier: EditImageTextCellViewIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
    }
    
    func initConstraint() {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let textViewLeftConstraint = NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: ipFitSize(IPCGFloatEditImageTextFieldDistance))
        
        let y = view.frame.width < view.frame.height ? CGFloat(64) : CGFloat(52)
        textViewTopConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: y+ipFitSize(IPCGFloatEditImageTextFieldDistance))
        
        let textViewWidthConstraint = NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: -2*ipFitSize(IPCGFloatEditImageTextFieldDistance))
        
        let textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: ipFitSize(IPCGFloatEditImageTextFieldHeight))
        
        textViewLeftConstraint.isActive = true
        textViewTopConstraint.isActive = true
        textViewWidthConstraint.isActive = true
        textViewHeightConstraint.isActive = true
        
        
        textCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textCountLabelLeftConstraint = NSLayoutConstraint(item: textCountLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let textCountLabelTopConstraint = NSLayoutConstraint(item: textCountLabel, attribute: .top, relatedBy: .equal, toItem: textView , attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let textCountLabelWidthConstraint = NSLayoutConstraint(item: textCountLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: -ipFitSize(IPCGFloatEditImageTextFieldDistance))
        
        let textCountLabelHeightConstraint = NSLayoutConstraint(item: textCountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 20)
        
        textCountLabelLeftConstraint.isActive = true
        textCountLabelTopConstraint.isActive = true
        textCountLabelWidthConstraint.isActive = true
        textCountLabelHeightConstraint.isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let collectionViewLeftConstraint = NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        
        let collectionViewTopConstraint = NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: textCountLabel, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        let collectionViewWidthConstraint = NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        
        let collectionViewBottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        collectionViewLeftConstraint.isActive = true
        collectionViewTopConstraint.isActive = true
        collectionViewWidthConstraint.isActive = true
        collectionViewBottomConstraint.isActive = true
    }
    
    func updateAddModel() -> Bool{
        if updateSelectArray.last?.modelType == .addModel {
            if updateSelectArray.count >= maxChooseNum+1 {
                updateSelectArray.removeLast()
                return true
            }
        }else{
            if updateSelectArray.count < maxChooseNum {
                var addModel = ImageCellModel()
                addModel.modelType = .addModel
                updateSelectArray.append(addModel)
                return true
            }
        }
        return false
    }
    
    // MARK: - BtnClick Method
    func leftBarBtnClick() {
        if updateSelectArray.last?.modelType == ModelType.addModel {
            updateSelectArray.remove(at: updateSelectArray.count-1)
        }
        if isComingFromDetail {
            navigationController?.setNavigationBarHidden(true, animated: false)
            NotificationCenter.default.post(name: updateArrayDetailVCNotificationName, object: self, userInfo: [updateArrayDetailVCUserInfoKey:updateSelectArray])
            NotificationCenter.default.post(name: changeScreenDirectionNotificationName, object: self, userInfo: [changeScreenDirectionUserInfoKey: view.frame.size])
            _ = navigationController?.popViewController(animated: true)
        }else{
            NotificationCenter.default.post(name: updateArrayCollectionVCNotificationName, object: self, userInfo: [updateArrayCollectionVCUserInfoKey: updateSelectArray])
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func rightBarBtnClick() {
        print("textView.text: \(textView.text)")
        print("updateSelectArray: \(updateSelectArray)")
    }
    
    // MARK: - TextViewDelegate Method
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.characters.count)/200"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard (textView.text != nil) else {
            return true
        }
        if textView.text!.characters.count + text.characters.count - range.length > 200{
            return false
        }
        return true
    }
    
    // MARK: - CollectionView Delegate & Datasource Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = EditImageTextCellView.cellView(collectionView: collectionView, indexPath: indexPath, cellModel: updateSelectArray[indexPath.row]) { (cellView) in
            guard (collectionView.indexPath(for: cellView) != nil) else{
                return
            }
            let deleteIndex: IndexPath! = collectionView.indexPath(for: cellView)
            
            self.updateSelectArray.remove(at: deleteIndex.row)
            collectionView.deleteItems(at: [deleteIndex])
            if self.updateAddModel() == true {
                collectionView.insertItems(at: [IndexPath(row: self.updateSelectArray.count-1, section: 0)])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if updateSelectArray[indexPath.row].modelType != .addModel{
            return
        }
        leftBarBtnClick()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updateSelectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ipFitSize(IPCGFloatEditImageTextFieldHeight), height: ipFitSize(IPCGFloatEditImageTextFieldHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, ipFitSize(IPCGFloatEditImageTextFieldDistance), 0, ipFitSize(IPCGFloatEditImageTextFieldDistance))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatEditImageViewDistance)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatEditImageViewDistance)
    }
    
}
