//
//  EditImageTextCellView.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/30.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import UIKit
import Photos

class EditImageTextCellView: UICollectionViewCell {
    
    var cellModel: ImageCellModel!
    var deleteBtn: UIButton!
    var imageView: UIImageView!
    var deleteImageView: UIImageView!
    var deleteBtnClickClosure: ( (EditImageTextCellView)-> () )!
    var timeDurationView: UIView!
    var timeLabel: UILabel!

    
    static func cellView(collectionView: UICollectionView, indexPath: IndexPath, cellModel: ImageCellModel, deleteBtnClickClosure: @escaping (EditImageTextCellView)-> ()) -> (EditImageTextCellView){
        let cellView: EditImageTextCellView = collectionView.dequeueReusableCell(withReuseIdentifier: EditImageTextCellViewIdentifier, for: indexPath) as! EditImageTextCellView
        
        cellView.cellModel = cellModel
        cellView.initView()
        cellView.showImage()
        cellView.deleteBtnClickClosure = deleteBtnClickClosure
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
        
        if deleteBtn == nil {
            deleteBtn = UIButton(type: .custom)
            //按键判定面积增大一些 避免用户误点造成体验不佳
            let deleteBtnX = ipFitSize(IPCGFloatEditImageTextFieldHeight - IPCGFloatCollectionSelectRoundDiameter)
            deleteBtn.frame = CGRect(x: deleteBtnX, y: 0, width: ipFitSize(IPCGFloatCollectionSelectRoundDiameter), height: ipFitSize(IPCGFloatCollectionSelectRoundDiameter))
            deleteBtn.backgroundColor = UIColor.clear
            deleteBtn.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
            addSubview(deleteBtn)
            
            let deleteImageViewX = deleteBtn.frame.width-ipFitSize(IPCGFloatEditImageDeleteImageWidth)
            deleteImageView = UIImageView(frame: CGRect(x: deleteImageViewX, y: 0, width: ipFitSize(IPCGFloatEditImageDeleteImageWidth), height: ipFitSize(IPCGFloatEditImageDeleteImageWidth)))
            deleteImageView.image = UIImage(named: "delete_button_icon")
            
            deleteBtn.addSubview(deleteImageView)
        }
        
        if cellModel.modelType == .videoAssetModel {
            if timeDurationView == nil {
                timeDurationView = UIView(frame: CGRect(x: 0, y: bounds.height*0.8, width: bounds.width, height: bounds.height*0.2))
                timeDurationView?.backgroundColor = ipColorFromHex(hex: IPHexColorNextBtn, alpha: 0.7)
//                timeDurationView?.backgroundColor = ipColorFromHex(hex: IPHexColorCollectionSelectRoundInside, alpha: 0.7)
                addSubview(timeDurationView)
            }
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
            timeDurationView.isHidden = false
        }else{
            timeDurationView?.isHidden = true
        }
    }
    
    func showImage() {
        deleteBtn.isHidden = cellModel.modelType == .addModel
        
        switch cellModel.modelType {
        case .cameraModel:
            imageView.image = UIImage(named: "Photo_album_icon")
        case .addModel:
            imageView.image = UIImage(named: "addition_icon")
        default:
            guard (cellModel.phAsset != nil) else {
                return
            }
            PHImageManager.default().requestImage(for: cellModel.phAsset!, targetSize: CGSize(width: frame.width*2, height: frame.height*2), contentMode: PHImageContentMode.aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) in
                self.imageView.image = image
            }
        }
    }
    
    func deleteBtnClick() {
        deleteBtnClickClosure(self)
    }
    
}
