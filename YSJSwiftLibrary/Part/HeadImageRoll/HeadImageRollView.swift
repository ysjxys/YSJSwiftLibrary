//
//  HeadImageRollView.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/6.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public enum HeadImageShapeType {
    case roundType
    case rectType
}

public class HeadImageRollView: UIView {
    public var isHorizontalShow: Bool = true {
        didSet{
            updateScrollContentSize()
            updateHeadImageFrame()
        }
    }
    //显示头像图片数组
    public var headImagesArray: [UIImage]? {
        didSet{
            updateScrollContentSize()
            updateHeadImages()
            updateHeadImageFrame()
            updateHeadImageShape()
            updateBorder()
        }
    }
    //边框颜色
    public var borderColor: UIColor = UIColor.clear{
        didSet{
            updateBorder()
        }
    }
    //边框宽度
    public var borderWidth: CGFloat = 0 {
        didSet{
            updateBorder()
        }
    }
    //头像图片的长宽
    public var headWidth: CGFloat = 40 {
        didSet{
            updateHeadImageFrame()
            updateScrollContentSize()
            updateHeadImageShape()
        }
    }
    //头像图片间的间距
    public var distance: CGFloat = 10 {
        didSet{
            updateHeadImageFrame()
            updateScrollContentSize()
        }
    }
    //最左与最右头像图片与边框的间距
    public var headTailEdge: CGFloat = 5 {
        didSet{
            updateHeadImageFrame()
            updateScrollContentSize()
        }
    }
    //头像图形，圆形or方形
    public var headImageShapeType: HeadImageShapeType = .rectType{
        didSet {
            updateHeadImageShape()
        }
    }
    //点击某个头像后的处理闭包
    public var selectImageClosure: ( (Int, UIImage) -> () )?
    
    var insideScroll: UIScrollView = UIScrollView()
    var headImageViewArray: [UIImageView] = []
    
    func updateBorder() {
        for index in 0..<headImageViewArray.count {
            let imageView = headImageViewArray[index]
            imageView.layer.borderColor = borderColor.cgColor
            imageView.layer.borderWidth = borderWidth
        }
    }
    
    func updateScrollContentSize() {
        if let imageCount = headImagesArray?.count {
            let long = headTailEdge*2+headWidth*CGFloat(imageCount)+distance*CGFloat(imageCount-1)
            if isHorizontalShow {
                insideScroll.contentSize = CGSize(width: long, height: 0)
            }else{
                insideScroll.contentSize = CGSize(width: 0, height: long)
            }
        }
    }
    
    func updateHeadImageFrame() {
        for index in 0..<headImageViewArray.count {
            let imageView = headImageViewArray[index]
            if isHorizontalShow {
                imageView.frame = CGRect(x: headTailEdge+CGFloat(index)*(headWidth+distance), y: (insideScroll.frame.height-headWidth)/2, width: headWidth, height: headWidth)
            }else{
                imageView.frame = CGRect(x:(insideScroll.frame.width-headWidth)/2 , y: headTailEdge+CGFloat(index)*(headWidth+distance), width: headWidth, height: headWidth)
            }
        }
    }
    
    func updateHeadImages() {
        headImageViewArray.removeAll()
        for subView in insideScroll.subviews {
            subView.removeFromSuperview()
        }
        guard (headImagesArray != nil) else {
            return
        }
        for index in 0..<headImagesArray!.count {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.clear
            imageView.clipsToBounds = true
            imageView.image = headImagesArray?[index]
            imageView.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(headImageSelect(tap:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tap)
            insideScroll.addSubview(imageView)
            headImageViewArray.append(imageView)
        }
    }
    
    func updateHeadImageShape() {
        for imageView in headImageViewArray {
            switch headImageShapeType {
            case .rectType:
                imageView.layer.cornerRadius = 0
            case .roundType:
                imageView.layer.cornerRadius = imageView.frame.width/2
            }
        }
    }
    
    @objc func headImageSelect(tap: UITapGestureRecognizer) {
        if let view = tap.view {
            if selectImageClosure != nil {
                selectImageClosure!(view.tag, headImagesArray![view.tag])
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        insideScroll.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        insideScroll.backgroundColor = UIColor.clear
        insideScroll.showsVerticalScrollIndicator = false
        insideScroll.showsHorizontalScrollIndicator = false
        
        addSubview(insideScroll)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
