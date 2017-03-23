//
//  Dictionary_String.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

extension Dictionary{
    public func DictToString() -> String{
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let string = String(data: jsonData, encoding: String.Encoding.utf8)
            return string!
            
        }catch let error{
            print(error.localizedDescription)
            return ""
        }
    }
}

extension String{
    public func StringToDict() -> [String: Any]{
        do{
            let jsonData = self.data(using: String.Encoding.utf8)
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            let dict = jsonDict as! Dictionary<String, Any>
            return dict
        }catch let error{
            print(error.localizedDescription)
            return [:]
        }
    }
}
