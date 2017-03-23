//
//  UserDefaultKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.standard

public class UserDefaultKVStore : StoreBase, KeyValueStoreProtocol{
    
    private func keyDict() -> [String:String] {
        let keyDictValue = userDefaults.object(forKey: "keyDict")
        var keyDict: Dictionary<String, String>
        
        if keyDictValue == nil {
            keyDict = Dictionary<String, String>()
        }else{
            keyDict = keyDictValue as! Dictionary<String, String>
        }
        
        return keyDict
    }
    
    public override func setObject(_ data: DataType, forKey key: String) {
        switch data{
        case .null:
            removeForKey(key)
        default:
            userDefaults.set(data.toString(), forKey: key)
            
            var keyDict = self.keyDict()
            
            keyDict[key] = data.typeString()
            userDefaults.set(keyDict, forKey: "keyDict")
            
            userDefaults.synchronize()
        }
    }
    
    public func removeForKey(_ key: String) {
        var keyDict = self.keyDict()
        keyDict.removeValue(forKey: key)
        
        userDefaults.set(keyDict, forKey: "keyDict")
        
        userDefaults.removeObject(forKey: key)
        
        userDefaults.synchronize()
    }
    
    override public func objectForKey(_ key: String) -> DataType {
        let keyDict = self.keyDict()
        
        guard let type = keyDict[key] else{
            return .null
        }
        
        if let val = userDefaults.object(forKey: key) {
            let valStr = val as! String
            
            let ret = DataType(type: type, rawValue: valStr)
            
            return ret
        }
        return .null
    }
    
    public func enumerateKeysAndObjectsUsingBlock(block: @escaping (_ key: String, _ data: DataType) -> ()) {
        //获取所有的key
        let keyDict = self.keyDict()
        //        print(keyDict)
        for key in keyDict.keys{
            if let type = keyDict[key], let val = userDefaults.object(forKey: key) {
                let valStr = val as! String
                
                let data = DataType(type: type, rawValue: valStr)
                
                block(key, data)
            }
        }
    }
    
    public func cleanAll() {
        let keyDict = self.keyDict()
        for key in keyDict.keys{
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.removeObject(forKey: "keyDict")
        userDefaults.synchronize()
    }
}

// MARK: -ObjectStoreProtocol协议的扩展
extension UserDefaultKVStore{}

