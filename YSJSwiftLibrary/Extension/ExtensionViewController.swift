//
//  ExtensionViewController.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/6/13.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func currentController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first else {
            return nil
        }
        var tempView: UIView?
        for subview in window.subviews.reversed() {
            if subview.classForCoder.description() == "UILayoutContainerView" {
                tempView = subview
                break
            }
        }
        if tempView == nil {
            tempView = window.subviews.last
        }
        var nextResponder = tempView?.next
        var next: Bool {
            return !(nextResponder is UIViewController) || nextResponder is UINavigationController || nextResponder is UITabBarController
        }
        while next{
            tempView = tempView?.subviews.first
            if tempView == nil {
                return nil
            }
            nextResponder = tempView!.next
        }
        return nextResponder as? UIViewController
    }
    
    
}
