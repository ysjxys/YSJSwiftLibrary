//
//  FileDirManager.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public class FileDirManager{

    public static func getDirectoryOfSubName(subName: String, lifecycle: LifecycleType) -> String{
        var parentDir: String? = nil
        switch lifecycle{
        case .temp:
            parentDir = NSTemporaryDirectory()
        case .cache:
            parentDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true).first
        case .persistent:
            parentDir = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .allDomainsMask, true).first
        default:
            break
        }
        
        if parentDir != nil{
            do{
                let ret = parentDir! + "/" + subName
                try FileManager.default.createDirectory(atPath: ret, withIntermediateDirectories: true, attributes: nil)
                return ret
            }
            catch(let error){
                printLog("create dir:\(subName) faile:\(error)")
                return ""
            }
        } else{
            return ""
        }
    }
}
