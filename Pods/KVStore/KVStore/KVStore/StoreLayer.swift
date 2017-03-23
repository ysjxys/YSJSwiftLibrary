//
//  StoreLayer.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public let Store = StoreLayer.defaultStore()

public class StoreLayer : NSObject {
    static func defaultStore() -> StoreLayer{
        return defaultInstance
    }
    private init(subDir: String){
        self.subDir = subDir
        
        let directory = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .persistent)
        let confFile = directory + StoreLayer.configFileName
        
        var configDic = NSMutableDictionary(contentsOfFile: confFile)
        if configDic == nil{
            configDic = NSMutableDictionary()
        }
        
        // 升级动作
        if configDic?["version"] == nil {
            version = StoreLayer.currentStoreLayerVersion
            configDic?["version"] = version
            configDic?.write(toFile: confFile, atomically: true)
        }else{
            var version = configDic?["version"] as! Int
            if version < StoreLayer.currentStoreLayerVersion{
                version = StoreLayer.currentStoreLayerVersion
                configDic?["version"] = version
                configDic?.write(toFile: confFile, atomically: true)
            }
        }
    }
    
    public func persistentStore() -> KeyValueStoreProtocol{
        return persistentKVStore
    }
    public func largePersistentStore() -> KeyValueStoreProtocol{
        return largePersistentKVStore
    }
    public func cacheStore() -> KeyValueStoreProtocol{
        return cacheKVStore
    }
    public func largeCacheStore() -> KeyValueStoreProtocol{
        return largeCacheKVStore
    }
    public func largeCacheWithTimeStore() -> KeyValueStoreProtocol{
        return largeCacheWithTimeKVStore
    }
    public func tempStore() -> KeyValueStoreProtocol{
        return tempKVStore
    }
    public func plistStore() -> KeyValueStoreProtocol{
        return plistKVStore
    }
    public func securityStore() -> KeyValueStoreProtocol{
        return keychainKVStore
    }
    
    lazy var keychainKVStore : KeychainKVStore = {
        return KeychainKVStore(accessGroup: "com.xinguangnet.Miss", identifier: "defaultStore")
    }()
    
    lazy var persistentKVStore : TableKVStore = {
        let dbPath = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .persistent) + StoreLayer.kvDBFileName
        printLog("persistentStore path: \n \(dbPath)")
        
        return TableKVStore(dbPath: dbPath, tableName: StoreLayer.kvtableName)
    }()
    lazy var largePersistentKVStore : FileKVStore = {
        let fileStoreDir = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .persistent) + "/fileStore"
        printLog("largePersistentStore path: \n \(fileStoreDir)")
        
        return FileKVStore(storeDirectory: fileStoreDir)
    }()
    lazy var cacheKVStore : TableKVStore = {
        let dbPath = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .cache) + StoreLayer.kvDBFileName
        printLog("cacheStore path: \n \(dbPath)")
        
        return TableKVStore(dbPath: dbPath, tableName: StoreLayer.kvtableName)
    }()
    lazy var largeCacheKVStore : FileKVStore = {
        let fileStoreDir = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .cache) + "/fileStore"
        printLog("largeCacheStore path: \n \(fileStoreDir)")
        
        return FileKVStore(storeDirectory: fileStoreDir)
    }()
    lazy var largeCacheWithTimeKVStore : FileWithTimeKVStore = {
        let fileStoreDir = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .cache) + "/fileStore"
        printLog("largeCacheWithTimeStore path: \n \(fileStoreDir)")
        
        return FileWithTimeKVStore(storeDirectory: fileStoreDir)
    }()
    lazy var tempKVStore : TableKVStore = {
        let dbPath = FileDirManager.getDirectoryOfSubName(subName: self.subDir, lifecycle: .temp) + StoreLayer.kvDBFileName
        printLog("tempStore path: \n \(dbPath)")
        
        return TableKVStore(dbPath: dbPath, tableName: StoreLayer.kvtableName)
    }()
    lazy var plistKVStore: PlistKVStore = {
        let documentDirectory: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = documentDirectory[0].appending("/test.plist")
        printLog("plistStore path: \n \(path)")
        return PlistKVStore(path: path)
    }()
    
    var version: Int = 0
    var subDir : String // 存储子目录
    
    static let defaultInstance = StoreLayer(subDir: "defaultStore")
    
    // 字符串和常量
    static let configFileName = "/_storeConfig.plist"
    static let kvDBFileName = "/kvstore.db"
    static let kvtableName = "kvtable"
    static let currentStoreLayerVersion = 1
}
