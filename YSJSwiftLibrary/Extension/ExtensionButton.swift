//
//  ExtensionButton.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/11/17.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    public func setButtonBackgroundColor(color: UIColor, forState state: UIControlState) {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        guard let contexts = context else {
            return
        }
        contexts.setFillColor(color.cgColor)
        contexts.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(image, for: state)
    }
}
