//
//  SJTransitionAnimations.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/3/21.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit



final internal class BounceDownTransition: SJTransitionAnimator {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch direction {
        case .in:
            toVC.view.bounds.origin = CGPoint(x: 0, y: fromVC.view.bounds.size.height)
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            UIView.animate(withDuration: inDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.toVC.view.bounds = self.fromVC.view.bounds
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.fromVC.view.bounds.origin = CGPoint(x: 0, y: self.fromVC.view.bounds.size.height)
//                self.fromVC.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
}

final internal class BounceUpTransition: SJTransitionAnimator {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch direction {
        case .in:
            toVC.view.bounds.origin = CGPoint(x: 0, y: -fromVC.view.bounds.size.height)
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            UIView.animate(withDuration: inDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.toVC.view.bounds = self.fromVC.view.bounds
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.fromVC.view.bounds.origin = CGPoint(x: 0, y: -self.fromVC.view.bounds.size.height)
//                self.fromVC.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
}

final internal class ZoomTransition: SJTransitionAnimator{
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch direction {
        case .in:
            toVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            UIView.animate(withDuration: inDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.toVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.fromVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.fromVC.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}


final internal class FadeTransition: SJTransitionAnimator {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        
        switch direction {
        case .in:
            toVC.view.alpha = 0
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            UIView.animate(withDuration: inDuration, delay: 0, options: [.curveEaseOut],
                           animations: {
                            self.toVC.view.alpha = 1
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0, options: [.curveEaseIn], animations: {
                self.fromVC.view.alpha = 0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
