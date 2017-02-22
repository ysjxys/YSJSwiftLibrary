//
//  PlistKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public class PlistKVStore : StoreBase, KeyValueStoreProtocol{
    public var path: String
    public var dict: Dictionary<String, Dictionary<String, String>>!
    public init(path: String){
        self.path = path
        
        if FileManager.default.contents(atPath: path) == nil {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        let plistData: Data
        if let tempData = FileManager.default.contents(atPath: path) {
            plistData = tempData
        }else{
            return
        }
        
        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        
        do {
            self.dict = try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! Dictionary<String, Dictionary<String, String>>
        }catch let error {
            printLog("get plist data error: \n \(error.localizedDescription)")
        }
    }
    
    
    func keepNotNil() {
        //存储key对应的dataType
        if dict == nil{
            dict = ["typeDict": Dictionary<String, String>(), "dataDict": Dictionary<String, String>()]
        }
    }
    
    
    public override func setObject(_ data: DataType, forKey key: String) {
        switch data {
        case .null:
            removeForKey(key)
        default:
            keepNotNil()
            
            var typeDict = dict["typeDict"]
            typeDict?[key] = data.typeString()

            var dataDict = dict["dataDict"]
            dataDict?[key] = data.toString()

            dict["typeDict"] = typeDict
            dict["dataDict"] = dataDict
            
            (dict as NSDictionary).write(toFile: path, atomically: true)
        }
    }
    
    
    public override func objectForKey(_ key: String) -> DataType {
        keepNotNil()
        let tempTypeDict = dict["typeDict"]
        guard let type = tempTypeDict?[key]
            else{
                return .null
        }
        
        let tempDataDict = dict["dataDict"]
        guard let val = tempDataDict?[key]
            else{
                return .null
        }
        
        return DataType(type: type, rawValue: val)
    }
    
    
    public func removeForKey(_ key: String) {
        keepNotNil()
        guard var typeDict = dict["typeDict"]
            else{
                return
        }
        guard var dataDict = dict["dataDict"]
            else{
                return
        }
        typeDict.removeValue(forKey: key)
        dataDict.removeValue(forKey: key)
        
        (dict as NSDictionary).write(toFile: path, atomically: true)
    }
    
    
    public func enumerateKeysAndObjectsUsingBlock(block: @escaping (_ key: String, _ data: DataType) -> ()) {
        keepNotNil()
        guard let typeDict = dict["typeDict"]
            else{
                return
        }
        guard let dataDict = dict["dataDict"]
            else{
                return
        }
        for key in typeDict.keys{
            if let type = typeDict[key], let val = dataDict[key]{
                let data = DataType(type: type, rawValue: val)
                block(key, data)
            }else{
                continue
            }
        }
    }
    
    public func cleanAll() {
        dict.removeAll()
        (dict as NSDictionary).write(toFile: path, atomically: true)
    }

}

extension PlistKVStore{}

