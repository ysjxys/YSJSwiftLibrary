//
//  ExtensionLabel.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/6/21.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func setLineSpaceing(lineSpace: CGFloat, text: String? = nil, alignment: NSTextAlignment = .left) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.alignment = alignment
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        if text != nil {
            self.numberOfLines = 0
            self.attributedText = NSMutableAttributedString(string: text!, attributes: attributes)
        } else if self.text != nil{
            self.numberOfLines = 0
            self.attributedText = NSMutableAttributedString(string: self.text!, attributes: attributes)
        }
    }
}
