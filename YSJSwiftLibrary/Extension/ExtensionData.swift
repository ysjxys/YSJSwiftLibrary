//
//  ExtensionData.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/11/8.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation

extension Data {
    func toDictionary() -> [String: Any]? {
        do{
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return json as? Dictionary<String, Any>
        } catch {
            return nil
        }
    }
}
