//
//  ExtensionTextView.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/6/26.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func setLineSpaceing(lineSpace: CGFloat, text: String? = nil, alignment: NSTextAlignment = .left, attributes: [String : Any]? = nil) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.alignment = alignment
        
        var attributes: [NSAttributedStringKey: Any] = [:]
        attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        
//        NSForegroundColorAttributeName
//        NSParagraphStyleAttributeName
//        NSFontAttributeName
//        NSBackgroundColorAttributeName
        
        if text != nil {
            self.attributedText = NSMutableAttributedString(string: text!, attributes: attributes)
        } else if self.text != nil{
            self.attributedText = NSMutableAttributedString(string: self.text!, attributes: attributes)
        }
    }
}
