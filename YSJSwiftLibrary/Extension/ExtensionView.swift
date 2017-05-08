//
//  ExtensionView.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    ///返回x坐标
    func left() -> CGFloat {
        return self.frame.origin.x
    }
    
    ///设置x坐标
    func setLeft(_ left: CGFloat) {
        self.frame.origin.x = left
    }
    
    ///返回右侧边缘坐标
    func right() -> CGFloat {
        return self.frame.origin.x + self.frame.size.width
    }
    
    ///设置右侧边缘坐标
    func setRight(_ right: CGFloat) {
        var frame = self.frame
        frame.size.width = right - self.frame.origin.x
        self.frame = frame
    }
    
    ///返回顶部坐标
    func top() -> CGFloat {
        return self.frame.origin.y
    }
    
    ///设置顶部坐标
    func setTop(_ top: CGFloat) {
        self.frame.origin.y = top
    }
    
    ///返回底部坐标
    func bottom() -> CGFloat {
        return self.frame.origin.y + self.frame.size.height
    }
    
    ///设置底部坐标
    func setBottom(_ bottom: CGFloat) {
        var frame = self.frame
        frame.size.height = bottom - self.frame.origin.y
        self.frame = frame
    }
    
    ///返回中心点x坐标
    func centerX() -> CGFloat {
        return self.center.x
    }
    
    ///设置中心点x坐标
    func setCenterX(_ centerX: CGFloat) {
        self.center.x = centerX
    }
    
    ///返回中心点y坐标
    func centerY() -> CGFloat {
        return self.center.y
    }
    
    ///设置中心点y坐标
    func setCenterY(_ centerY: CGFloat) {
        self.center.y = centerY
    }
    
    ///返回宽度值
    func width() -> CGFloat {
        return self.frame.size.width
    }
    
    ///设置宽度值
    func setWidth(_ width: CGFloat) {
        self.frame.size = CGSize(width: width, height: self.frame.size.height)
    }
    
    ///返回高度值
    func heigth() -> CGFloat {
        return self.frame.size.height
    }
    
    ///设置高度值
    func setHeight(_ height: CGFloat) {
        self.frame.size = CGSize(width: self.frame.size.width, height: height)
    }
    
    ///返回原点值
    func origin() -> CGPoint {
        return self.frame.origin
    }
    
    ///设置原点值
    func setOrigin(_ origin: CGPoint) {
        self.frame.origin = origin
    }
    
    ///设置size
    func size() -> CGSize {
        return self.frame.size
    }
    
    ///返回size
    func setSize(_ size: CGSize) {
        self.frame.size = size
    }
}
