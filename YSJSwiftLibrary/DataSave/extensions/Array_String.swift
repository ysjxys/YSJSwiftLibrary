//
//  Array_String.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//


import Foundation

extension Array{
    public func ArrayToString() -> String{
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
    public func StringToArray() -> Array<Any>{
        do{
            let jsonData = self.data(using: String.Encoding.utf8)
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            let array = jsonArray as! Array<Any>
            return array
        }catch let error as NSError{
            print(error.localizedDescription)
            return []
        }
    }
}
