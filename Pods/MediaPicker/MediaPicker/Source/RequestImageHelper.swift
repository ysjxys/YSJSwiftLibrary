//
//  RequestImageHelper.swift
//  MediaPicker
//
//  Created by ysj on 2017/5/4.
//  Copyright © 2017年 XGN. All rights reserved.
//

import Foundation
import Photos

class RequestImageHelper: NSObject {
    private let alertImage = createAlert(title: "正在下载iCloud图片")
    private let alertVideo = createAlert(title: "正在下载iCloud视频")
    static let shared = RequestImageHelper()
    
    func requestVideo(showHudView: UIView, phAsset: PHAsset, progressHandle: (() -> ())?, resultHandle: ((UIView, AVAsset?) -> ())? ) {
        alertVideo.center = showHudView.center
        
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { [weak self] (percent, error, pointer, info) in
            guard let weakSelf = self else {
                return
            }
            DispatchQueue.main.async {
                if weakSelf.alertVideo.superview == nil {
                    showHudView.addSubview(weakSelf.alertVideo)
                }
            }
            if let closure = progressHandle {
                closure()
            }
        }
        
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { [weak self] (avAsset: AVAsset?, avAudioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
            guard let weakSelf = self else {
                return
            }
            
            if let errorInfo = info?[PHImageErrorKey] {
                showHud(targetView: showHudView, title: errorInfo as!String, completeClosure: nil)
                return
            }
            
            guard avAsset != nil else {
                showHud(targetView: showHudView, title: "无法获得iCloud视频", completeClosure: nil)
                return
            }
            
            if let handle = resultHandle {
                handle(weakSelf.alertVideo, avAsset)
            }
        }
    }
    
    func requestImage(options: PHImageRequestOptions? = nil, showHudView: UIView, targetSize: CGSize, phAsset: PHAsset, progressHandle: (() -> ())?, resultHandle: ((UIView, UIImage?) -> ())? ) {
        alertImage.center = showHudView.center
        
        var op: PHImageRequestOptions?
        
        if options == nil {
            //是否裁剪图片由 targetSize、contentMode来控制，裁剪的尺寸由targetSize、contentMode、resizeMode指定
            op = PHImageRequestOptions()
            //同步/异步执行，在这里同步执行会阻塞progressHandler线程
            //            options.isSynchronous = true
            
            //resizeMode
            //none:  不缩放
            //fast:  尽快地提供接近或稍微大于要求的尺寸
            //exact:  精准提供要求的尺寸
            op?.resizeMode = .exact
            
            //deliveryMode  options.isSynchronous = false时 异步
            //fastFormat:   请求图片一次，保证速度尽可能保证图片质量
            //highQualityFormat:    请求图片一次，只返回高质量图
            //opportunistic:    请求图片两次，第一次模糊，第二次高清
            op?.deliveryMode = .highQualityFormat
            
            //是否允许网络传图(icloud图片)
            op?.isNetworkAccessAllowed = true
            //isNetworkAccessAllowed = true 时才调用，当前传图进度
            op?.progressHandler = { [weak self] (percent, error, pointer, info) in
                guard let weakSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    if weakSelf.alertImage.superview == nil {
                        showHudView.addSubview(weakSelf.alertImage)
                    }
                }
                if let closure = progressHandle {
                    closure()
                }
            }
        } else {
            op = options
        }
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFit, options: op) { [weak self] (image: UIImage?, info: [AnyHashable : Any]?) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let errorInfo = info?[PHImageErrorKey] {
                showHud(targetView: showHudView, title: errorInfo as!String, completeClosure: nil)
                return
            }
            
            guard image != nil else {
                showHud(targetView: showHudView, title: "无法获得iCloud照片", completeClosure: nil)
                return
            }
            
            if let handle = resultHandle {
                handle(weakSelf.alertImage, image)
            }
        }
    }
    
}

