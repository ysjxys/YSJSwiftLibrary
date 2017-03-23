//
//  String_Empty.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

extension String{
    var isEmptyOrBlankOnly: Bool{
        if self.isEmpty{
            return true
        }
        if self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).isEmpty{
            return true
        }
        return false
    }
}
