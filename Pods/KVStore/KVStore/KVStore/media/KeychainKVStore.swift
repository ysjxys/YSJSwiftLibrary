//
//  KeychainKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import SAMKeychain

class KeychainKVStore: StoreBase, KeyValueStoreProtocol{
    var accessGroup: String
    //serviceName
    var identifier: String
    init(accessGroup: String, identifier: String) {
        self.accessGroup = accessGroup
        self.identifier = identifier
    }
    
    override func objectForKey(_ key: String) -> DataType{
        guard let keyString = SAMKeychain.password(forService: identifier, account: key) else {
            return .null
        }
        let keychainDict = keyString.StringToDict()
        
        guard let typeDict: [String: String] = keychainDict["typeDict"] as? Dictionary<String, String> else {
            return .null
        }
        guard let type = typeDict[key] else {
            return .null
        }
        
        guard let dataDict: [String: String] = keychainDict["dataDict"] as? Dictionary<String, String> else {
            return .null
        }
        guard let val = dataDict[key] else {
            return .null
        }
        
        let ret = DataType(type: type, rawValue: val)
        return ret
    }
    
    override func setObject(_ data: DataType, forKey key: String) {
        switch data{
        case .null:
            removeForKey(key)
        default:
            var typeDict = Dictionary<String, String>()
            typeDict[key] = data.typeString()
            
            var dataDict = Dictionary<String, String>()
            dataDict[key] = data.toString()
            
            var keychainDict = Dictionary<String, Any>()
            keychainDict["typeDict"] = typeDict
            keychainDict["dataDict"] = dataDict
            SAMKeychain.setPassword(keychainDict.DictToString(), forService: identifier, account: key)
        }
    }
    
    func removeForKey(_ key: String){
        SAMKeychain.deletePassword(forService: identifier, account: key)
    }
    
    func enumerateKeysAndObjectsUsingBlock(block: @escaping (String, DataType)->()){
        guard let keyArray = SAMKeychain.accounts(forService: identifier)
            else{
                return
        }
        for keyDict in keyArray{
            guard let key = keyDict["acct"] as? String else {
                continue
            }
            guard let keyString = SAMKeychain.password(forService: identifier, account: key) else {
                continue
            }
            let keychainDict = keyString.StringToDict()
            
            guard let typeDict: [String: Any] = keychainDict["typeDict"] as? Dictionary else {
                continue
            }
            guard let dataDict: [String: Any] = keychainDict["dataDict"] as? Dictionary else {
                continue
            }
            guard let type = typeDict[key] as? String else {
                continue
            }
            guard let val = dataDict[key] as? String else {
                continue
            }
            let data = DataType(type: type , rawValue: val)
            block(key, data)
        }
    }
    
    func cleanAll() {
        guard let keyArray = SAMKeychain.accounts(forService: identifier)
            else{
                return
        }
        for keyDict in keyArray{
            guard let key = keyDict["acct"] as? String else {
                continue
            }
            removeForKey(key)
        }
    }
}

// MARK: - ObjectStoreProtocol协议的扩展
extension KeychainKVStore{
}
