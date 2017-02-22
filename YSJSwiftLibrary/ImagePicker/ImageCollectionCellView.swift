//
//  ImageCollectionCellView.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol ImageCollectionCellViewDelegate: NSObjectProtocol {
    func selectBtnClicked(cell: ImageCollectionCellView)
}

class ImageCollectionCellView: UICollectionViewCell {
    var selectBtn: UIButton!
    var imageView: UIImageView!
    var cellModel: ImageCellModel!
    var selectCoverView: UIView!
    var timeDurationView: UIView!
    var numbleLabel: UILabel!
    var timeLabel: UILabel!
    var singleChooseImageView: UIImageView!
    
    weak var delegate: ImageCollectionCellViewDelegate?
    
    
    
    static func cellView(collectionView: UICollectionView, indexPath: IndexPath, cellModel: ImageCellModel) -> (ImageCollectionCellView){
        let cellView: ImageCollectionCellView = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCellViewIdentifier, for: indexPath) as! ImageCollectionCellView
        cellView.backgroundColor = UIColor.white
        cellView.cellModel = cellModel
        cellView.initView()
        cellView.showImage()
        return cellView
    }
    
    func initView() {
        backgroundColor = UIColor.white
        
        if imageView == nil {
            imageView = UIImageView(frame: bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = UIColor.white
            imageView.clipsToBounds = true
            addSubview(imageView)
        }
        
        if selectBtn == nil {
            selectBtn = UIButton(type: .custom)
            //按键判定面积增大一些 避免用户误点造成体验不佳
            let x = ipFitSize(IPCGFloatCellWidth - 2*IPCGFloatCollectionSelectRoundDiameter)
            let diameter = ipFitSize(IPCGFloatCollectionSelectRoundDiameter)*2
            
            selectBtn.frame = CGRect(x: x, y: 0, width: diameter, height: diameter)
            selectBtn.backgroundColor = UIColor.clear
            
            selectBtn.addSubview(initSelectBtnBackgroundView())
            selectBtn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
            selectBtn.isHidden = cellModel.modelType == .cameraModel ? true : false
            addSubview(selectBtn)
        }
        selectBtn.isHidden = cellModel.modelType == .cameraModel
        selectCoverView.isHidden = !cellModel.isSelected
        
        if cellModel.modelType == .videoAssetModel {
            if timeDurationView == nil {
                timeDurationView = UIView(frame: CGRect(x: 0, y: bounds.height*0.8, width: bounds.width, height: bounds.height*0.2))
                timeDurationView.backgroundColor = ipColorFromHex(hex: IPHexColorNextBtn, alpha: 0.7)
                addSubview(timeDurationView)
            }
            
            if cellModel.phAsset != nil {
                let durationSecond = Int((cellModel.phAsset?.duration)! + 0.5)/1
                
                let hour = durationSecond/(60*60)
                let minute = durationSecond%(60*60)/60
                let second = durationSecond%60
                
                let minStr = minute < 10 ? "0\(minute):" : "\(minute):"
                let secStr = second < 10 ? "0\(second)" : "\(second)"
                
                var time = hour == 0 ? "" : "\(durationSecond/(60*60)):"
                time = time + minStr + secStr
                
                if timeLabel == nil {
                    timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: timeDurationView.bounds.width-5, height: timeDurationView.bounds.height))
                    timeLabel.textAlignment = .right
                    timeLabel.textColor = UIColor.white
                    timeLabel.numberOfLines = 1
                    timeLabel.font = UIFont.systemFont(ofSize: 15)
                    timeDurationView.addSubview(timeLabel)
                }
                timeLabel.text = time
            }
            
            timeDurationView.isHidden = false
        }else{
            timeDurationView?.isHidden = true
        }
    }
    
    func initSelectBtnBackgroundView() -> UIView {
        let x = selectBtn.frame.width - ipFitSize(IPCGFloatCollectionSelectRoundDiameter+IPCGFloatCollectionSelectRoundDistance)
        let y = ipFitSize(IPCGFloatCollectionSelectRoundDistance)
        
        let backView = UIImageView(frame: CGRect(x: x, y: y, width: ipFitSize(IPCGFloatCollectionSelectRoundDiameter), height: ipFitSize(IPCGFloatCollectionSelectRoundDiameter)))
        backView.image = UIImage(named: "um_select_camera")
        backView.isUserInteractionEnabled = false
        
        selectCoverView = UIView(frame: backView.bounds)
        
        selectCoverView.backgroundColor = ipColorFromHex(IPHexColorNextBtn)
        selectCoverView.layer.cornerRadius = ipFitSize(IPCGFloatCollectionSelectRoundDiameter/2)
        selectCoverView.isUserInteractionEnabled = false
        backView.addSubview(selectCoverView)
        selectCoverView.isHidden = true
        
        numbleLabel = UILabel(frame: selectCoverView.bounds)
        numbleLabel.backgroundColor = UIColor.clear
        numbleLabel.textColor = UIColor.white
        numbleLabel.font = UIFont.systemFont(ofSize: 15)
        numbleLabel.isUserInteractionEnabled = false
        numbleLabel.textAlignment = .center
        selectCoverView.addSubview(numbleLabel)
        
        
        singleChooseImageView = UIImageView(frame: selectCoverView.bounds)
        singleChooseImageView.backgroundColor = UIColor.clear
        selectCoverView.addSubview(singleChooseImageView)
        
        return backView
    }
    
    
    func showImage() {
        switch cellModel.modelType {
        case .cameraModel:
            imageView.image = UIImage(named: "Photo_album_icon")
        case .addModel:
            imageView.image = UIImage(named: "addition_icon")
        default:
            guard (cellModel.phAsset != nil) else {
                return
            }
            PHImageManager.default().requestImage(for: cellModel.phAsset!, targetSize: CGSize(width: frame.width*2, height: frame.height*2), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) in
                self.imageView.image = image
            }
        }
    }
    
    func selectBtnClick() {
        delegate?.selectBtnClicked(cell: self)
    }
    
    
    func cellModelChangedSelectState() {
        cellModel.isSelected = !cellModel.isSelected
        selectCoverView.isHidden = !cellModel.isSelected
    }
}
