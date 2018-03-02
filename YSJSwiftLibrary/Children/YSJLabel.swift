//
//  YSJLabel.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

enum VerticalAlignment {
    case top
    case middle
    case bottom
}

class YSJLabel: UILabel {
    
    var verticalAlignment: VerticalAlignment = .middle {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawText(in rect: CGRect) {
        let realRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: realRect)
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        
        switch verticalAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .middle:
            textRect.origin.y = (bounds.origin.y + bounds.size.height - textRect.size.height)/2
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        }
        
        return textRect
    }
    
    
}


