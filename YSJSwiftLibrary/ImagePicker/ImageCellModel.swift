//
//  ImageCellModel.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import Photos

enum ModelType {
    case cameraModel
    case addModel
    case imageAssetModel
    case videoAssetModel
    case audioAssetModel
    case unknowAssetModel
}


struct ImageCellModel {
    var phAsset: PHAsset?
    var isSelected: Bool = false
    var modelType: ModelType
    var index: Int = 0
    
    init() {
        self.modelType = .cameraModel
    }
    
    init(phAsset: PHAsset) {
        self.phAsset = phAsset
        switch phAsset.mediaType {
        case .image:
            self.modelType = .imageAssetModel
        case .video:
            self.modelType = .videoAssetModel
        case .audio:
            self.modelType = .audioAssetModel
        default:
            self.modelType = .unknowAssetModel
        }
    }
}
