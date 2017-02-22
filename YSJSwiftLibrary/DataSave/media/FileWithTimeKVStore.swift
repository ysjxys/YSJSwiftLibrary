//
//  FileWithTimeKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public class FileWithTimeKVStore : StoreBase, KeyValueStoreProtocol{
    public init(storeDirectory: String){
        do {
            try FileManager.default.createDirectory(atPath: storeDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            printLog("create file error: \n \(error.localizedDescription)")
        }
        let dbPath = storeDirectory + kvtableFile
        pathTable = TableKVStore(dbPath: dbPath, tableName: pathTableName)
        typeTable = TableKVStore(databaseQueue: pathTable.databaseQueue, tableName: typeTableName)
        timestampTable = TableKVStore(databaseQueue: pathTable.databaseQueue, tableName: timestampTableName)
        self.storeDirectory = storeDirectory
    }
    
    public override func objectForKey(_ key: String) -> DataType{
        let fileNameData = pathTable.objectForKey(key)
        if fileNameData != .null{
            let fileName = fileNameData.toString()
            let typeName = typeTable.objectForKey(key).toString()
            let timestamp = timestampTable.objectForKey(key).toString()
            do{
                let filePath = filePathFromKey(key: fileName)
                let content = try String(contentsOfFile:filePath, encoding:String.Encoding.utf8)
                return DataType(type: typeName, rawValue: content, timestamp: timestamp)
            }catch let error {
                printLog("FileObjectStore read file error: \n \(error.localizedDescription)")
                return .null
            }
        } else{
            return .null
        }
    }
    
    public override func setObject(_ data : DataType, forKey key: String){
        if data == .null{
            self.removeForKey(key)
            return;
        }
        
        let filePath = filePathFromKey(key: key)
        let content = data.toString()
        let type = data.typeString()
        let timestamp = data.timestamp()
        
        do{
            try content.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            pathTable.setObject(.string(key), forKey: key)
            typeTable.setObject(.string(type), forKey: key)
            timestampTable.setObject(.string(timestamp), forKey: key)
        } catch let error {
            printLog("FileObjectStore write file error: \n \(error.localizedDescription)")
        }
    }
    
    public func removeForKey(_ key: String){
        let fileNameData = pathTable.objectForKey(key)
        if fileNameData == .null{
            return
        }
        
        do{
            let fileName = fileNameData.toString()
            let filePath = filePathFromKey(key: fileName)
            try FileManager.default.removeItem(atPath: filePath)
            pathTable.removeForKey(key)
            typeTable.removeForKey(key)
            timestampTable.removeForKey(key)
        }catch let error{
            printLog("removeForKey error: \n \(error.localizedDescription)")
        }
    }
    
    public func enumerateKeysAndObjectsUsingBlock(block: @escaping (_ key: String, _ data: DataType)->()){
        var kvs : [(String, DataType)] = []
        pathTable.enumerateKeysAndObjectsUsingBlock { (key, data) -> () in
            kvs.append((key, data))
        }
        
        for (key, data) in kvs{
            let typeName = self.typeTable.objectForKey(key).toString()
            let timestamp = self.timestampTable.objectForKey(key).toString()
            let fileName = data.toString()
            do{
                let val = try String(contentsOfFile: filePathFromKey(key: fileName), encoding: String.Encoding.utf8)
                let data = DataType(type: typeName, rawValue: val, timestamp: timestamp)
                block(key , data)
            }catch let error{
                printLog("get file content error: \n \(error.localizedDescription)")
            }
        }
    }
    
    public func cleanAll(){
        pathTable.enumerateKeysAndObjectsUsingBlock { (key, data) -> () in
            let fileName = data.toString()
            do{
                try FileManager.default.removeItem(atPath: self.filePathFromKey(key: fileName))
            }catch let error{
                printLog("delete file error: \n \(error.localizedDescription)")
            }
        }
        
        pathTable.cleanAll()
        typeTable.cleanAll()
        timestampTable.cleanAll()
    }
    
    func filePathFromKey(key: String) -> String{
        return self.storeDirectory + "/" + key
    }
    let pathTable : TableKVStore
    let typeTable : TableKVStore
    let timestampTable: TableKVStore
    
    let storeDirectory : String
    let kvtableFile = "/fileKV.db"
    let pathTableName = "filepath"
    let typeTableName = "datatype"
    let timestampTableName = "timestamp"
    
}
