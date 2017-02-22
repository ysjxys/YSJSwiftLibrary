//
//  ImagePickerViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MBProgressHUD

public let updateArrayCollectionVCNotificationName = Notification.Name("updateArrayCollectionVCNotificationName")
public let updateArrayCollectionVCUserInfoKey = "updateArrayCollectionVCUserInfoKey"

public enum ChooseType {
    case headImageType
    case shareImageType
}

enum DetailType {
    case imageOnlyType
    case videoOnlyType
    case audioOnlyType
    case imageVideoType
    case imageAudioType
    case videoAudioType
    case allType
    
    func contentTypes() -> Set<ModelType> {
        var resultSet: Set<ModelType> = []
        switch self {
        case .imageOnlyType:
            resultSet.insert(.imageAssetModel)
        case .videoOnlyType:
            resultSet.insert(.videoAssetModel)
        case .audioOnlyType:
            resultSet.insert(.audioAssetModel)
        case .imageVideoType:
            resultSet.insert(.imageAssetModel)
            resultSet.insert(.videoAssetModel)
        case .imageAudioType:
            resultSet.insert(.imageAssetModel)
            resultSet.insert(.audioAssetModel)
        case .videoAudioType:
            resultSet.insert(.videoAssetModel)
            resultSet.insert(.audioAssetModel)
        case .allType:
            resultSet.insert(.imageAssetModel)
            resultSet.insert(.videoAssetModel)
            resultSet.insert(.audioAssetModel)
        }
        return resultSet
    }
}

class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageCollectionCellViewDelegate{
    
    var collectionView: UICollectionView!
    var cellModelArray: [ImageCellModel] = []
    var updateSelectArray: [ImageCellModel] = []
    
    //用于更新collectionCellView的选中状态
    var tempUpdateCellSet: Set<IndexPath> = []
    
    var isNeedResizeCollectionView = false
    
    //主题颜色
    public var themeColor = ipColorFromHex(IPHexColorNextBtn)
    //选择是否新的照片在前
    public var isNewPhotoFront = false
    //选择模式，头像模式或分享模式，默认为分享模式
    public var chooseType: ChooseType = .shareImageType
    //选择类型，默认为只选择图片
    public var detailType: DetailType = .imageOnlyType
    //选择分享模式时的最大可选图片数量
    public var maxChooseNum = 9
    //头像选择模式下的勾选图片
    public var singleChooseImage: UIImage? = UIImage(named: "select_cameta")
    //头像选择模式回调
    public var chooseHeadImageClosure: ( (UIImage, EditHeadImageViewController?) -> () )?
    //分享模式回调
    public var chooseImagesClosure: ( ([PHAsset], GetImagesViewController?) -> () )?
    //用户自定义结果viewcontroller
    public var customResultVCName: String = ""
    
    // MARK: - LifeCircle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        let hud = MBProgressHUD(view: view)
        hud.mode = .indeterminate
        view.addSubview(hud)
        hud.show(animated: true)
        
        initConstraint()
        initNotification()
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
            if status == PHAuthorizationStatus.authorized{
                self.initPhotoData()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    hud.hide(animated: true)
                }
            }else{
                showHudWith(targetView: self.view, title: IPStringPhotoLibraryForbiddenWarningMsg)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: updateArrayCollectionVCNotificationName, object: nil)
        print("ImagePickerViewController  deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Notification Method
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateArrayCollectionVC(notification:)), name: updateArrayCollectionVCNotificationName, object: nil)
    }
    
    func updateArrayCollectionVC(notification: Notification) {
        var updateArray: [ImageCellModel] = notification.userInfo?[updateArrayCollectionVCUserInfoKey] as! Array
        for i in 0..<updateArray.count {
            if updateArray[i].modelType == .cameraModel {
                updateArray.remove(at: i)
            }
        }
        updateSelectArray = updateArray
        
        tempUpdateCellSet.removeAll()
        for i in 0..<cellModelArray.count {
            if cellModelArray[i].isSelected == true {
                tempUpdateCellSet.insert(IndexPath(row: i, section: 0))
            }
            cellModelArray[i].isSelected = false
        }
        for cellModel in updateArray {
            cellModelArray[cellModel.index].isSelected = cellModel.isSelected
            tempUpdateCellSet.insert(IndexPath(row: cellModel.index, section: 0))
        }
        
        updateCollectionItems()
    }
    
    func updateCollectionItems() {
        var indexPathArray: [IndexPath] = []
        for indexPath in tempUpdateCellSet {
            indexPathArray.append(indexPath)
        }
        collectionView.reloadItems(at: indexPathArray)
        updateSortNumbers()
    }
    
    // MARK: - Custom Method
    func initView() {
        view.backgroundColor = UIColor.white
        
        switch chooseType {
        case .shareImageType:
            navigationItem.title = IPStringCamera
        case .headImageType:
            navigationItem.title = IPStringCameraRoll
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: IPStringBack, style: .plain, target: self, action: #selector(backBarBtnClick))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: IPStringNextStep, style: .plain, target: self, action: #selector(rightBtnClick))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: themeColor], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .disabled)
        
        //导航栏按钮颜色
        navigationController?.navigationBar.tintColor = themeColor
        //导航栏背景色
        navigationController?.navigationBar.barTintColor = UIColor.white
        //导航栏文字颜色
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ipColorFromHex(IPHexColorNavigationTitle)]
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionCellView.self, forCellWithReuseIdentifier: ImageCollectionCellViewIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
    }
    
    func initConstraint() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let collectionCenterXConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let collectionCenterYConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let collectionWidthConstraint = NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        
        let collectionHeightConstraint = NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
        
        collectionCenterXConstraint.isActive = true
        collectionCenterYConstraint.isActive = true
        collectionWidthConstraint.isActive = true
        collectionHeightConstraint.isActive = true
    }
    
    func initPhotoData() {
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        var fetchzResult: PHFetchResult<PHAsset>?
        for i in 0..<albumsResult.count {
            let assetCollection = albumsResult.object(at: i)
            print("\(assetCollection.localizedTitle)")
            if ( assetCollection.localizedTitle?.contains(IPStringCameraRoll) == true || assetCollection.localizedTitle?.contains(IPStringAllPhotos) == true )  {
                fetchzResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                break
            }
        }
        if fetchzResult == nil {
            return
        }
        
        for index in 0..<fetchzResult!.count {
            let cellModel = ImageCellModel(phAsset: fetchzResult![index])
            
            switch chooseType {
            case .headImageType:
                if cellModel.modelType == .imageAssetModel {
                    cellModelArray.append(cellModel)
                }
            case .shareImageType:
                if detailType.contentTypes().contains(cellModel.modelType){
                    cellModelArray.append(cellModel)
                }
            }
            
        }
        cellModelArray.sort { (model1, model2) -> Bool in
            if isNewPhotoFront {
                return model1.phAsset!.creationDate! > model2.phAsset!.creationDate!
            }else{
                return model1.phAsset!.creationDate! < model2.phAsset!.creationDate!
            }
        }
        
        for i in 0..<cellModelArray.count {
            cellModelArray[i].index = i+1
        }
        
        var cameraCellModel = ImageCellModel()
        cameraCellModel.index = 0
        cellModelArray.insert(cameraCellModel, at: 0)
    }
    
    func updateSortNumbers() {
        for i in 0..<updateSelectArray.count {
            let selectCell = collectionView.cellForItem(at: IndexPath(row: updateSelectArray[i].index, section: 0))
            if selectCell != nil {
                (selectCell as! ImageCollectionCellView).numbleLabel.text = "\(i+1)"
            }
        }
    }
    
    func updateRightBarBtnEnable() {
        if updateSelectArray.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }else{
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func changeCellSelectState(cell: ImageCollectionCellView) {
        //改变选择与数字显示状态
        cell.cellModel.isSelected = !cell.cellModel.isSelected
        cell.selectCoverView.isHidden = !cell.cellModel.isSelected
        //改变数据源状态
        let indexPath: IndexPath! = collectionView.indexPath(for: cell)
        cellModelArray[indexPath.row].isSelected = cell.cellModel.isSelected
    }
    
    // MARK: - Click Method
    func backBarBtnClick() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func rightBtnClick() {
        if updateSelectArray.count == 0 {
            showHudWith(targetView: view, title: IPStringSelectAtLeastOne)
            return
        }
        switch chooseType {
        case .headImageType:
            PHImageManager.default().requestImage(for: updateSelectArray.last!.phAsset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                
                let editHeadImageVC = EditHeadImageViewController()
                editHeadImageVC.headImage = image
                editHeadImageVC.updateSelectArray = self.updateSelectArray
                editHeadImageVC.isComingFromDetail = false
                editHeadImageVC.chooseHeadImageClosure = self.chooseHeadImageClosure
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(editHeadImageVC, animated: true)
            })
        case .shareImageType:
            var customResultVC: GetImagesViewController? = nil
            
            if let customResultVCType = NSClassFromString(customResultVCName) as? GetImagesViewController.Type {
                customResultVC = customResultVCType.init()
            }else if let customResultVCType = NSClassFromString("\(appName()).\(customResultVCName)") as? GetImagesViewController.Type{
                customResultVC = customResultVCType.init()
            }
            customResultVC?.isComingFromDetail = false
            customResultVC?.maxChooseNum = maxChooseNum
            customResultVC?.updateSelectArray = updateSelectArray
            
            if let closure = chooseImagesClosure {
                var phAssetArray: [PHAsset] = []
                
                for index in 0..<updateSelectArray.count {
                    guard (updateSelectArray[index].phAsset != nil)  else {
                        continue
                    }
                    phAssetArray.append(updateSelectArray[index].phAsset!)
                }
                closure(phAssetArray, customResultVC)
            }
        }
    }
    
    // MARK: - ImageCollectionCellViewDelegate Delegate Method
    func selectBtnClicked(cell: ImageCollectionCellView) {
        switch chooseType {
        case .headImageType:
            //选中的cell改变状态
            changeCellSelectState(cell: cell)
            //判断旧cell与新cell是否相同，若相同，相当于取消选中，不进行后续操作
            if cell.cellModel.index != updateSelectArray.first?.index{
                //旧cell改版状态
                if let shouldHideCellIndex = updateSelectArray.first?.index {
                    //若旧cell正在显示，改变显示状态
                    if let shouldHideCell = collectionView.cellForItem(at: IndexPath(row: shouldHideCellIndex, section: 0)) {
                        let collectionCell = shouldHideCell as! ImageCollectionCellView
                        
                        collectionCell.cellModel.isSelected = !collectionCell.cellModel.isSelected
                        collectionCell.selectCoverView.isHidden = !collectionCell.cellModel.isSelected
                    }
                    cellModelArray[shouldHideCellIndex].isSelected = false
                }
            }
            
            updateSelectArray.removeAll()
            if cell.cellModel.isSelected{
                updateSelectArray.append(cell.cellModel)
            }
            updateRightBarBtnEnable()
            
        case .shareImageType:
            var maxNum = maxChooseNum
            if chooseType == .headImageType {
                maxNum = 1
            }
            
            // >maxChooseNum 且还想继续选择更多  返回
            if updateSelectArray.count >= maxNum && cell.cellModel.isSelected == false{
                showHudWith(targetView: view, title: IPStringSelectTheMost)
                return
            }
            changeCellSelectState(cell: cell)
            
            //改变 传递给下一页面的 updateSelectArray 状态
            if cell.cellModel.isSelected {
                updateSelectArray.append(cell.cellModel)
            }else{
                for i in 0..<updateSelectArray.count {
                    if updateSelectArray[i].index == cell.cellModel.index {
                        updateSelectArray.remove(at: i)
                        break
                    }
                }
            }
            updateRightBarBtnEnable()
            
            updateSortNumbers()
        }
    }
    
    // MARK: - imagePickerController Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        switch chooseType {
        case .headImageType:
            self.dismiss(animated: true, completion: nil)
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            if let closuer = self.chooseHeadImageClosure {
                backBarBtnClick()
                closuer(image, nil)
            }
        case .shareImageType:
            self.dismiss(animated: true, completion: nil)
            var identifierString: String? = nil
            PHPhotoLibrary.shared().performChanges({ 
                let assetChangeRequet = PHAssetChangeRequest.creationRequestForAsset(from: info[UIImagePickerControllerEditedImage] as! UIImage)
                identifierString = assetChangeRequet.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (isSuccess, error) in
                guard (identifierString != nil) else{
                    return
                }
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifierString!], options: nil)
                
                var lastImageAsset: PHAsset? = nil
                if (fetchResult.firstObject != nil){
                    lastImageAsset = fetchResult.firstObject
                }
                
                var customResultVC: GetImagesViewController? = nil
                if let customResultVCType = NSClassFromString(self.customResultVCName) as? GetImagesViewController.Type {
                    customResultVC = customResultVCType.init()
                }else if let customResultVCType = NSClassFromString("\(appName()).\(self.customResultVCName)") as? GetImagesViewController.Type{
                    customResultVC = customResultVCType.init()
                }
                customResultVC?.isComingFromDetail = false
                customResultVC?.maxChooseNum = self.maxChooseNum
                var cellModel = ImageCellModel()
                cellModel.index = 0
                cellModel.isSelected = false
                cellModel.phAsset = lastImageAsset
                customResultVC?.updateSelectArray = [cellModel]
                
                if let closure = self.chooseImagesClosure {
                    self.backBarBtnClick()
                    if let lastImageAsset = lastImageAsset {
                        closure([lastImageAsset], customResultVC)
                    }else {
                        closure([], customResultVC)
                    }
                }
            })
        }
    }
    
    // MARK: - collectionViewDelegate&DataSource Method
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImageCollectionCellView.cellView(collectionView: collectionView, indexPath: indexPath, cellModel: cellModelArray[indexPath.row])
        cell.delegate = self
        
        switch chooseType {
        case .headImageType:
            cell.singleChooseImageView.image = singleChooseImage
            cell.singleChooseImageView.isHidden = false
        case .shareImageType:
            cell.singleChooseImageView.isHidden = true
            if cell.cellModel.isSelected {
                for i in 0..<updateSelectArray.count {
                    if cell.cellModel.index == updateSelectArray[i].index {
                        cell.numbleLabel.text = "\(i+1)"
                        break
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModelArray[indexPath.row]
        
        if cellModel.modelType == ModelType.cameraModel {
            let cameraVC = UIImagePickerController()
            cameraVC.sourceType = .camera
            cameraVC.allowsEditing = true
            cameraVC.delegate = self
            self.present(cameraVC, animated: true, completion: nil)
        }else{
            let detailVC = ImageDetailViewController()
            switch chooseType {
            case .headImageType:
                guard cellModel.phAsset != nil else {
                    return
                }
                detailVC.chooseHeadImageClosure = chooseHeadImageClosure
                detailVC.maxChooseNum = 1
                detailVC.singleChooseImage = singleChooseImage
            case .shareImageType:
                detailVC.chooseImagesClosure = chooseImagesClosure
                detailVC.maxChooseNum = maxChooseNum
                detailVC.customResultVCName = customResultVCName
            }
            detailVC.chooseType = chooseType
            detailVC.comingIndex = cellModel.index
            detailVC.cellModelArray = cellModelArray
            detailVC.updateSelectArray = updateSelectArray
            
            hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cellModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ipFitSize(IPCGFloatCellWidth), height: ipFitSize(IPCGFloatCellWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(ipFitSize(IPCGFloatCollectionViewTopDistance), 0, ipFitSize(IPCGFloatCellBetweenDistance), 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatCellBetweenDistance)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatCellBetweenDistance)
    }
}
