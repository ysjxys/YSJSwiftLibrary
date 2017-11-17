//
//  ExtensionDictionary.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/11/8.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation

extension Dictionary {
    func toData() -> Data? {
        if(!JSONSerialization.isValidJSONObject(self)) {
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        return data
    }
}
