//
//  PresentationManager.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/20.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

internal enum AHAnimationDirection {
    case `in`
    case out
}

@objc public enum AHTransitionStyle: Int {
    case bounceUp
    case bounceDown
    case zoom
    case fade
    case none
}

final internal class PresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    var transitionStyle: AHTransitionStyle
    var inDuration: TimeInterval
    var outDuration: TimeInterval
    
    var interactVC: UIViewController?
    
    init(transitionStyle: AHTransitionStyle, interactVC: UIViewController?, inDuration: TimeInterval, outDuration: TimeInterval) {
        self.transitionStyle = transitionStyle
        self.interactVC = interactVC
        self.inDuration = inDuration
        self.outDuration = outDuration
        super.init()
    }
    
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        print("presented:\(presented) \n presenting:\(presenting) \n source:\(source) \n")
//        return nil
//    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceDown:
            transition = BounceDownTransition(direction: .in, inDuration: inDuration, outDuration: outDuration)
        case .bounceUp:
            transition = BounceUpTransition(direction: .in, inDuration: inDuration, outDuration: outDuration)
        case .fade:
            transition = FadeTransition(direction: .in, inDuration: inDuration, outDuration: outDuration)
        case .zoom:
            transition = ZoomTransition(direction: .in, inDuration: inDuration, outDuration: outDuration)
        case .none:
            transition = NoneTransition(direction: .in, inDuration: inDuration, outDuration: outDuration)
        }
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceDown:
            transition = BounceDownTransition(direction: .out, inDuration: inDuration, outDuration: outDuration)
        case .bounceUp:
            transition = BounceUpTransition(direction: .out, inDuration: inDuration, outDuration: outDuration)
        case .fade:
            transition = FadeTransition(direction: .out, inDuration: inDuration, outDuration: outDuration)
        case .zoom:
            transition = ZoomTransition(direction: .out, inDuration: inDuration, outDuration: outDuration)
        case .none:
            transition = NoneTransition(direction: .out, inDuration: inDuration, outDuration: outDuration)
        }
        return transition
    }
    
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactVC
//    }
}
