//
//  SJTransitionAnimator.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/21.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

internal class SJTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var toVC: UIViewController!
    var fromVC: UIViewController!
    var containerView: UIView!
    let direction: SJAnimationDirection
    var inDuration: TimeInterval
    var outDuration: TimeInterval
    
    
    init(direction: SJAnimationDirection, inDuration: TimeInterval, outDuration: TimeInterval) {
        self.direction = direction
        self.inDuration = inDuration
        self.outDuration = outDuration
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        toVC = transitionContext.viewController(forKey: .to)
        fromVC = transitionContext.viewController(forKey: .from)
        containerView = transitionContext.containerView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
