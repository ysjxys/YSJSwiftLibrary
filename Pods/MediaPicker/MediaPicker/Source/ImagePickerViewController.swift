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

public let updateArrayCollectionVCNotificationName = Notification.Name("updateArrayCollectionVCNotificationName")
public let updateArrayCollectionVCUserInfoKey = "updateArrayCollectionVCUserInfoKey"

public enum ChooseType {
    case headImageType
    case shareImageType
}

public enum DetailType {
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

public class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageCollectionCellViewDelegate{
    
    var collectionView: UICollectionView!
    var cellModelArray: [ImageCellModel] = []
    var updateSelectArray: [ImageCellModel] = []
    
    //用于更新collectionCellView的选中状态
    var tempUpdateCellSet: Set<IndexPath> = []
    //获得数据是否成功
    var isGetMediaSuccess = true
    //最初通过push进入的VC
    var shouldPopVC: UIViewController?
    
    
    
    //主题颜色
    public var themeColor = ipColorFromHex(IPHexColorNextBtn)
    //图片选择按钮背景色
    public var selectBackgroundColor = ipColorFromHex(IPHexColorNextBtn)
    //图片选择按钮文字颜色
    public var selectNumTextColor = ipColorFromHex(IPHexColorSelectNumLabelText)
    //拍照按钮图片
    public var cameraBtnImage: UIImage?
    //选择是否新的照片在前
    public var isNewPhotoFront = false
    //选择模式，头像模式或分享模式，默认为分享模式
    public var chooseType: ChooseType = .shareImageType
    //选择类型，默认为只选择图片
    public var detailType: DetailType = .imageOnlyType
    //选择分享模式时的最大可选图片数量
    public var maxChooseNum = 9
    //勾选图片
    public var selectImage: UIImage? = imageFromBundle(imageName: IPImageNameSelectCamera)
    //是否在shareImage模式下启用勾选图片
    public var isUseSelectImageInShareImageType = false
    //头像选择模式回调
    public var chooseHeadImageClosure: ( (UIImage?) -> () )?
    //分享模式回调
    public var chooseImagesClosure: ( ([PHAsset]?) -> () )?
    //失败回调
    public var failClosure: ( () -> () )?
    
    //展示模式，默认为present式
    public var isShowByPresent = true
    //进入MediaPlayer的页面的tabBar是否显示
    public var isComingVCTabBarShow = true
    //进入MediaPlayer的页面的navigationBar是否显示
    public var isComingVCNavigationBarShow = true
    //进入MediaPlayer的页面的statusBar是否显示
    public var isComingVCStatusBarShow = true
    
    override public var prefersStatusBarHidden: Bool{
        return false
    }
    
    // MARK: - init Method
    public init(chooseHeadImageClosure: ( (UIImage?) -> () )?, chooseImagesClosure: ( ([PHAsset]?) -> () )?, failClosure: ( () -> () )?) {
        super.init(nibName: nil, bundle: nil)
        self.chooseImagesClosure = chooseImagesClosure
        self.chooseHeadImageClosure = chooseHeadImageClosure
        self.failClosure = failClosure
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCircle Method
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initConstraint()
        initNotification()
        
        weak var weakSelf = self
        guard weakSelf != nil else {
            return
        }
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
            if status == PHAuthorizationStatus.authorized{
                weakSelf!.initData()
                DispatchQueue.main.async {
                    weakSelf!.collectionView.reloadData()
                }
            }else{
                weakSelf!.isGetMediaSuccess = false
                showHud(targetView: weakSelf!.view, title: IPStringPhotoLibraryForbiddenWarningMsg, completeClosure: {
                    if let failClosure = self.failClosure {
                        failClosure()
                    }
                })
            }
        })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: updateArrayCollectionVCNotificationName, object: nil)
        print("ImagePickerViewController  deinit")
    }
    
    public override func didReceiveMemoryWarning() {
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
        
        var rightItemTitle = ""
        
        switch chooseType {
        case .shareImageType:
            navigationItem.title = IPStringCamera
            rightItemTitle = IPStringComplete
        case .headImageType:
            navigationItem.title = IPStringCameraRoll
            rightItemTitle = IPStringNextStep
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: IPStringBack, style: .plain, target: self, action: #selector(backBarBtnClick))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightItemTitle, style: .plain, target: self, action: #selector(rightBtnClick))
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
    
    func initData() {
        if !isShowByPresent && navigationController != nil{
            shouldPopVC = navigationController?.viewControllers[navigationController!.viewControllers.count-2]
        }
        
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        var fetchzResult: PHFetchResult<PHAsset>?
        for i in 0..<albumsResult.count {
            let assetCollection = albumsResult.object(at: i)
            if let title = assetCollection.localizedTitle {
                print(title)
                if ( title.contains(IPStringCameraRoll) || title.contains(IPStringAllPhotos) || title.contains(IPStringCameraRollEnglish) || title.contains(IPStringAllPhotosEnglish) )  {
                    fetchzResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                    break
                }
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
        if isComingVCStatusBarShow {
            UIApplication.shared.setStatusBarHidden(false, with: .none)
        }else{
            UIApplication.shared.setStatusBarHidden(true, with: .none)
        }
        
        if isShowByPresent {
            self.dismiss(animated: true, completion: nil)
        }else{
            if let shouldPopVC = shouldPopVC {
                hidesBottomBarWhenPushed = isComingVCTabBarShow ? false : true
                if isComingVCNavigationBarShow {
                    navigationController?.setNavigationBarHidden(false, animated: true)
                }else{
                    navigationController?.setNavigationBarHidden(true, animated: true)
                }
                
                _ = navigationController?.popToViewController(shouldPopVC, animated: true)
            }
        }
    }
    
    func rightBtnClick() {
        if updateSelectArray.count == 0 {
            showHud(targetView: view, title: IPStringSelectAtLeastOne, completeClosure: nil)
            return
        }
        switch chooseType {
        case .headImageType:
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .fast
            PHImageManager.default().requestImage(for: updateSelectArray.last!.phAsset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                
                let editHeadImageVC = EditHeadImageViewController()
                editHeadImageVC.headImage = image
                editHeadImageVC.updateSelectArray = self.updateSelectArray
                editHeadImageVC.isComingFromDetail = false
                editHeadImageVC.chooseHeadImageClosure = self.chooseHeadImageClosure
                editHeadImageVC.isShowByPresent = self.isShowByPresent
                editHeadImageVC.shouldPopVC = self.shouldPopVC
                editHeadImageVC.isComingVCStatusBarShow = self.isComingVCStatusBarShow
                editHeadImageVC.isComingVCNavigationBarShow = self.isComingVCNavigationBarShow
                editHeadImageVC.isComingVCTabBarShow = self.isComingVCTabBarShow
                
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(editHeadImageVC, animated: true)
            })
        case .shareImageType:
            if let closure = chooseImagesClosure {
                var phAssetArray: [PHAsset] = []
                
                for index in 0..<updateSelectArray.count {
                    guard (updateSelectArray[index].phAsset != nil)  else {
                        continue
                    }
                    phAssetArray.append(updateSelectArray[index].phAsset!)
                }
                backBarBtnClick()
                closure(phAssetArray)
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
                showHud(targetView: view, title: IPStringSelectTheMost, completeClosure: nil)
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
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        switch chooseType {
        case .headImageType:
            self.dismiss(animated: true, completion: nil)
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            if let closuer = self.chooseHeadImageClosure {
                backBarBtnClick()
                closuer(image)
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
                
                var cellModel = ImageCellModel()
                cellModel.index = 0
                cellModel.isSelected = false
                cellModel.phAsset = lastImageAsset
                
                if let closure = self.chooseImagesClosure {
                    self.backBarBtnClick()
                    if let lastImageAsset = lastImageAsset {
                        closure([lastImageAsset])
                        return
                    }
                    if let failClosure = self.failClosure{
                        failClosure()
                    }
                }
            })
        }
    }
    
    // MARK: - collectionViewDelegate&DataSource Method
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImageCollectionCellView.cellView(collectionView: collectionView, indexPath: indexPath, cellModel: cellModelArray[indexPath.row])
        cell.delegate = self
        if cameraBtnImage != nil {
            cell.cameraBtnImage = cameraBtnImage!
        }
        
        switch chooseType {
        case .headImageType:
            cell.selectImageView.image = selectImage
            cell.selectImageView.isHidden = false
        case .shareImageType:
            if isUseSelectImageInShareImageType {
                cell.selectImageView.image = selectImage
                cell.selectImageView.isHidden = false
            }else{
                cell.selectImageView.isHidden = true
                cell.selectNumTextColor = selectNumTextColor
                cell.selectBackgroundColor = selectBackgroundColor
            }
            
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
                detailVC.selectImage = selectImage
            case .shareImageType:
                detailVC.chooseImagesClosure = chooseImagesClosure
                detailVC.maxChooseNum = maxChooseNum
            }
            detailVC.chooseType = chooseType
            detailVC.comingIndex = cellModel.index
            detailVC.cellModelArray = cellModelArray
            detailVC.updateSelectArray = updateSelectArray
            detailVC.isShowByPresent = isShowByPresent
            detailVC.themeColor = themeColor
            detailVC.selectNumTextColor = selectNumTextColor
            detailVC.selectBackgroundColor = selectBackgroundColor
            detailVC.shouldPopVC = shouldPopVC
            detailVC.isComingVCStatusBarShow = self.isComingVCStatusBarShow
            detailVC.isComingVCNavigationBarShow = self.isComingVCNavigationBarShow
            detailVC.isComingVCTabBarShow = self.isComingVCTabBarShow
            
            hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cellModelArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ipFitSize(IPCGFloatCellWidth), height: ipFitSize(IPCGFloatCellWidth))
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(ipFitSize(IPCGFloatCollectionViewTopDistance), 0, ipFitSize(IPCGFloatCellBetweenDistance), 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatCellBetweenDistance)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ipFitSize(IPCGFloatCellBetweenDistance)
    }
}
