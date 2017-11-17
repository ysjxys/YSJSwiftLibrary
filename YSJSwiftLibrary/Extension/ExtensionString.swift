//
//  ExtensionString.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func size(font: UIFont, maxSize: CGSize, lineSpace: CGFloat? = nil) -> CGSize {
        var attributeDic: [NSAttributedStringKey: NSObject] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): font]
        
        if let lineSpace = lineSpace {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpace
            attributeDic[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        }
        
        return self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributeDic, context: nil).size
    }
}
