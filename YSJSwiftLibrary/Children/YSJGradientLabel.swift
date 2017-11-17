//
//  YSJGradientLabel.swift
//  TestComplexEasyAnimation
//
//  Created by ysj on 2017/7/6.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public enum FlashTextVerticalAlignment {
    case top
    case center
    case bottom
}

class YSJGradientLabel: UILabel {
    
    lazy var gradientLayer: CAGradientLayer = {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.white.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.25, 0.5, 0.75]
        
        return gradientLayer
    }()
    
    var flashText: String?
    var iFlashTextOn = false
    var flashTextVerticalAlignment: FlashTextVerticalAlignment = .center
    
    override var text: String? {
        didSet {
            if iFlashTextOn {
                flashText = text
            }
        }
    }
    
    var gradientAnimation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
    
    private func addAnimation() {
        gradientAnimation.fromValue = [0, 0, 0.25]
        gradientAnimation.toValue = [0.75, 1, 1]
        gradientAnimation.repeatCount = Float.infinity
        gradientAnimation.duration = 3.0
        gradientLayer.add(gradientAnimation, forKey: nil)
    }
    
    private func createFlashText() {
        text = flashText
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        var topDistance = CGFloat(0)
        if let size = text?.size(withAttributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: style]) {
            switch flashTextVerticalAlignment {
            case .center:
                topDistance = (bounds.height - size.height) / 2
            case .bottom:
                topDistance = bounds.height - size.height
            default:
                print("is top")
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
        text?.draw(in: CGRect(x: 0, y: topDistance, width: bounds.width, height: bounds.height), withAttributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: style])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
        maskLayer.contents = image?.cgImage
        gradientLayer.mask = maskLayer
        text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if iFlashTextOn {
            gradientLayer.frame = CGRect(x: -bounds.size.width, y:0 , width: bounds.size.width*3, height: bounds.size.height)
            layer.addSublayer(gradientLayer)
        }
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if iFlashTextOn {
            createFlashText()
            addAnimation()
        }
    }
}
