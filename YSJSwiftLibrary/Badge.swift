//
//  Badge.swift
//  Rider
//
//  Created by ysj on 2017/7/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
//
//  Badge.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/7/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, isFilled: Bool) {
        fillColor = isFilled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        //        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        let origin = CGPoint(x: location.x, y: location.y)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(color: UIColor = UIColor.red, isFilled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        var location = CGPoint(x: view.frame.width, y: 0)
        if let insideImage = image {
            location = CGPoint(x: view.frame.width - insideImage.size.width, y: 0)
        }
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(4)
        //        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, isFilled: isFilled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        //        let label = CATextLayer()
        //        label.string = "\(number)"
        //        label.alignmentMode = kCAAlignmentCenter
        //        label.fontSize = 11
        //        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        //        label.foregroundColor = isFilled ? UIColor.white.cgColor : color.cgColor
        //        label.backgroundColor = UIColor.clear.cgColor
        //        label.contentsScale = UIScreen.main.scale
        //        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
