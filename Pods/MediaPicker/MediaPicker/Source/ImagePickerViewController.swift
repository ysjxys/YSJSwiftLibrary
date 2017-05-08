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
    
    private var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    private var collectionView: UICollectionView!
    private var cellModelArray: [ImageCellModel] = []
    private var updateSelectArray: [ImageCellModel] = [] {
        didSet {
            rightBarButtonItem.isEnabled = !updateSelectArray.isEmpty
        }
    }
    
    //用于更新collectionCellView的选中状态
    private var tempUpdateCellSet: Set<IndexPath> = []
    //获得数据是否成功
    private var isGetMediaSuccess = true
    //最初通过push进入的VC
    private var shouldPopVC: UIViewController?
    
    //navigationBar左侧导航按钮属性配置
    public var leftBarBtnAttributeClosure: ((UIBarButtonItem) -> ())?
    //navigationBar右侧导航按钮属性配置
    public var rightBarBtnAttributeClosure: ((UIBarButtonItem) -> ())?
    //是否需要拍照按钮
    public var isNeedCameraBtn = true
    //拍照按钮图片
    public var cameraBtnImage: UIImage?
    //选择是否新的照片在前
    public var isNewPhotoFront = true
    //选择类型，默认为只选择图片
    public var detailType: DetailType = .imageOnlyType
    
    override public var prefersStatusBarHidden: Bool{
        return false
    }
    
    // MARK: - LifeCircle Method
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initConstraint()
        initNotification()
        
        PHPhotoLibrary.requestAuthorization({ [weak self] (status: PHAuthorizationStatus) in
            guard let weakSelf = self else {
                return
            }
            if status == PHAuthorizationStatus.authorized{
                weakSelf.initData()
                DispatchQueue.main.async {
                    weakSelf.collectionView.reloadData()
                }
            }else{
                weakSelf.isGetMediaSuccess = false
                showHud(targetView: weakSelf.view, title: IPStringPhotoLibraryForbiddenWarningMsg, completeClosure: {
                    if let failClosure = MPProperty.failClosure {
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    private func initNotification() {
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
    
    private func updateCollectionItems() {
        var indexPathArray: [IndexPath] = []
        for indexPath in tempUpdateCellSet {
            indexPathArray.append(indexPath)
        }
        collectionView.reloadItems(at: indexPathArray)
        updateSortNumbers()
    }
    
    // MARK: - Custom Method
    private func initView() {
        view.backgroundColor = UIColor.white
        
        var rightItemTitle = ""
        
        switch MPProperty.chooseType {
        case .shareImageType:
            navigationItem.title = IPStringCamera
            rightItemTitle = IPStringComplete
        case .headImageType:
            navigationItem.title = IPStringCameraRoll
            rightItemTitle = IPStringNextStep
        }
        
        let leftBarButtonItem = UIBarButtonItem()
        if let closure = leftBarBtnAttributeClosure {
            closure(leftBarButtonItem)
        } else {
            leftBarButtonItem.title = IPStringBack
            leftBarButtonItem.style = .plain
        }
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(backBarBtnClick)
        
        if let closure = leftBarBtnAttributeClosure {
            closure(rightBarButtonItem)
        } else {
            rightBarButtonItem.title = rightItemTitle
            rightBarButtonItem.style = .plain
        }
        rightBarButtonItem.target = self
        rightBarButtonItem.action = #selector(rightBtnClick)
        rightBarButtonItem.isEnabled = false
        rightBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: MPProperty.themeColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .disabled)
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        //导航栏按钮颜色
        navigationController?.navigationBar.tintColor = MPProperty.themeColor
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
    
    private func initConstraint() {
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
    
    private func initData() {
        if !MPProperty.isShowByPresent && navigationController != nil {
            shouldPopVC = navigationController?.viewControllers[navigationController!.viewControllers.count-2]
        }
        
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var fetchResult: PHFetchResult<PHAsset>?
        for i in 0..<albumsResult.count {
            let assetCollection = albumsResult.object(at: i)
            if let title = assetCollection.localizedTitle {
                print(title)
                if ( title.contains(IPStringCameraRoll) || title.contains(IPStringAllPhotos) || title.contains(IPStringCameraRollEnglish) || title.contains(IPStringAllPhotosEnglish) )  {
                    let options = PHFetchOptions()
                    //排序
                    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !isNewPhotoFront)]
                    //是否包含连拍照片
                    options.includeAllBurstAssets = true
                    //是否包含隐藏照片
                    options.includeHiddenAssets = true
                    fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                    break
                }
            }
        }
        guard let result = fetchResult else {
            return
        }
        
        cellModelArray.removeAll()
        for index in 0..<result.count {
            let cellModel = ImageCellModel(phAsset: result[index])
            
            switch MPProperty.chooseType {
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
        
        if isNeedCameraBtn {
            for i in 0..<cellModelArray.count {
                cellModelArray[i].index = i+1
            }
            var cameraCellModel = ImageCellModel()
            cameraCellModel.index = 0
            cellModelArray.insert(cameraCellModel, at: 0)
        } else {
            for i in 0..<cellModelArray.count {
                cellModelArray[i].index = i
            }
        }
    }
    
    private func updateSortNumbers() {
        for i in 0..<updateSelectArray.count {
            let selectCell = collectionView.cellForItem(at: IndexPath(row: updateSelectArray[i].index, section: 0))
            if let cell = selectCell as? ImageCollectionCellView {
                cell.numbleLabel.text = "\(i+1)"
            }
        }
    }
    
    private func updateUserEnable(_ isEnable: Bool) {
        collectionView.allowsSelection = isEnable
        collectionView.isScrollEnabled = isEnable
        rightBarButtonItem.isEnabled = isEnable
        for cell in collectionView.visibleCells {
            guard let imageCell = cell as? ImageCollectionCellView  else { continue
            }
            imageCell.selectBtn.isEnabled = isEnable
        }
    }
    
    private func changeCellSelectState(cell: ImageCollectionCellView) {
        //改变选择与数字显示状态
        cell.cellModel.isSelected = !cell.cellModel.isSelected
        cell.selectCoverView.isHidden = !cell.cellModel.isSelected
        //改变数据源状态
        if let indexPath = collectionView.indexPath(for: cell) {
            cellModelArray[indexPath.row].isSelected = cell.cellModel.isSelected
        }
    }
    
    // MARK: - Click Method
    public func backBarBtnClick() {
        checkAndChangeBars(controller: self, shouldPopVC: shouldPopVC)
    }
    
    public func rightBtnClick() {
        guard let first = updateSelectArray.first else {
            showHud(targetView: view, title: IPStringSelectAtLeastOne, completeClosure: nil)
            return
        }
        
        switch MPProperty.chooseType {
        case .headImageType:
            guard let phAsset = first.phAsset else {
                return
            }
            //PHImageManagerMaximumSize
            RequestImageHelper.shared.requestImage(showHudView: view, targetSize: PHImageManagerMaximumSize, phAsset: phAsset, progressHandle: { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.updateUserEnable(false)
            }, resultHandle: { [weak self]  (alert, image) in
                DispatchQueue.main.async {
                    if alert.superview != nil {
                        alert.removeFromSuperview()
                    }
                }
                guard let weakSelf = self else {
                    return
                }
                guard let image = image else {
                    return
                }
                weakSelf.updateUserEnable(true)
                let editHeadImageVC = EditHeadImageViewController()
                editHeadImageVC.headImage = image
                editHeadImageVC.updateSelectArray = weakSelf.updateSelectArray
                editHeadImageVC.isComingFromDetail = false
                editHeadImageVC.shouldPopVC = weakSelf.shouldPopVC
                
                weakSelf.hidesBottomBarWhenPushed = true
                weakSelf.navigationController?.setNavigationBarHidden(true, animated: true)
                weakSelf.navigationController?.pushViewController(editHeadImageVC, animated: true)
            })
            
        case .shareImageType:
            if let closure = MPProperty.chooseShareAssetClosure {
                var phAssetArray: [PHAsset] = []
                
                for index in 0..<updateSelectArray.count {
                    guard let phAsset = updateSelectArray[index].phAsset else {
                        continue
                    }
                    phAssetArray.append(phAsset)
                }
                backBarBtnClick()
                closure(phAssetArray)
            }
            if let closure = MPProperty.chooseShareImageClosure {
                var imageArray: [UIImage] = []
                
                for index in 0..<updateSelectArray.count {
                    guard let phAsset = updateSelectArray[index].phAsset else {
                        imageArray.append(UIImage())
                        continue
                    }
                    RequestImageHelper.shared.requestImage(showHudView: view, targetSize: MPProperty.resultImageTargetSize, phAsset: phAsset, progressHandle: { [weak self] in
                        guard let weakSelf = self else {
                            return
                        }
                        weakSelf.updateUserEnable(false)
                    }, resultHandle: { [weak self] (alert, image) in
                        guard let weakSelf = self else {
                            return
                        }
                        
                        if let image = image {
                            imageArray.append(image)
                        } else {
                            imageArray.append(UIImage())
                        }
                        
                        if imageArray.count == weakSelf.updateSelectArray.count {
                            DispatchQueue.main.async {
                                if alert.superview != nil {
                                    alert.removeFromSuperview()
                                }
                                weakSelf.updateUserEnable(true)
                                weakSelf.backBarBtnClick()
                                closure(imageArray)
                            }
                        }
                    })
                }//for(){...}      end
            }//if let closure = MPProperty.chooseShareImageClosure    end
        }//switch-case  end
    }//method   end
    
    
    // MARK: - ImageCollectionCellViewDelegate Delegate Method
    func selectBtnClicked(cell: ImageCollectionCellView) {
        switch MPProperty.chooseType {
        case .headImageType:
            //选中的cell改变状态
            changeCellSelectState(cell: cell)
            //判断旧cell与新cell是否相同，若相同，相当于取消选中，不进行后续操作
            if cell.cellModel.index != updateSelectArray.first?.index{
                //旧cell改版状态
                if let shouldHideCellIndex = updateSelectArray.first?.index {
                    //若旧cell正在显示，改变显示状态
                    if let shouldHideCell = collectionView.cellForItem(at: IndexPath(row: shouldHideCellIndex, section: 0)) as? ImageCollectionCellView {
                        shouldHideCell.cellModel.isSelected = !shouldHideCell.cellModel.isSelected
                        shouldHideCell.selectCoverView.isHidden = !shouldHideCell.cellModel.isSelected
                    }
                    cellModelArray[shouldHideCellIndex].isSelected = false
                }
            }
            
            updateSelectArray.removeAll()
            if cell.cellModel.isSelected{
                updateSelectArray.append(cell.cellModel)
            }
            
        case .shareImageType:
            var maxNum = MPProperty.maxChooseNum
            if MPProperty.chooseType == .headImageType {
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
            updateSortNumbers()
        }
    }
    
    // MARK: - imagePickerController Delegate Method
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            showHud(targetView: view, title: "获取照片失败", completeClosure: { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.dismiss(animated: true, completion: nil)
            })
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { [weak self] (isSuccess, error) in
            guard let weakSelf = self else {
                return
            }
            switch MPProperty.chooseType {
            case .headImageType:
                if let closure = MPProperty.chooseHeadImageClosure {
                    DispatchQueue.main.async {
                        weakSelf.backBarBtnClick()
                        closure(image)
                    }
                }
            case .shareImageType:
                weakSelf.updateSelectArray.removeAll()
                weakSelf.initData()
                DispatchQueue.main.async {
                    weakSelf.collectionView.reloadData()
                }
            }
            weakSelf.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: - collectionViewDelegate&DataSource Method
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImageCollectionCellView.cellView(collectionView: collectionView, indexPath: indexPath, cellModel: cellModelArray[indexPath.row])
        cell.delegate = self
        if let image = cameraBtnImage {
            cell.cameraBtnImage = image
        }
        
        switch MPProperty.chooseType {
        case .headImageType:
            cell.selectImageView.image = MPProperty.selectImage
            cell.selectImageView.isHidden = false
        case .shareImageType:
            if MPProperty.isUseSelectImageInShareImageType {
                cell.selectImageView.image = MPProperty.selectImage
                cell.selectImageView.isHidden = false
            }else{
                cell.selectImageView.isHidden = true
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
            guard cellModel.phAsset != nil else {
                return
            }
            let detailVC = ImageDetailViewController()
            detailVC.comingIndex = cellModel.index
            detailVC.cellModelArray = cellModelArray
            detailVC.updateSelectArray = updateSelectArray
            detailVC.shouldPopVC = shouldPopVC
            
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
