//
//  FileKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import CryptoSwift

public class FileKVStore : StoreBase, KeyValueStoreProtocol{
    public init(storeDirectory: String){
        do {
            try FileManager.default.createDirectory(atPath: storeDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            printLog("create file error: \n \(error.localizedDescription)")
        }
        
        let dbPath = storeDirectory + kvtableFile
        pathTable = TableKVStore(dbPath: dbPath, tableName: pathTableName)
        typeTable = TableKVStore(databaseQueue: pathTable.databaseQueue, tableName: typeTableName)
        self.storeDirectory = storeDirectory
    }
    
    public override func objectForKey(_ key: String) -> DataType{
        let fileNameData = pathTable.objectForKey(key)
        if fileNameData != .null{
            let fileName = fileNameData.toString()
            let typeName = typeTable.objectForKey(key).toString()
            do{
                let content = try String(contentsOfFile:fileNameFromKey(key: fileName) , encoding:String.Encoding.utf8)
                return DataType(type: typeName, rawValue: content)
            } catch let error {
                printLog("FileObjectStore read file error: \n \(error.localizedDescription)")
                return .null
            }
        } else{
            return .null
        }
    }
    
    
    public override func setObject(_ data: DataType, forKey key: String){
        if data == .null{
            self.removeForKey(key)
            return;
        }
        
        let fileName = key.md5()
        let content = data.toString()
        let type = data.typeString()
        do{
            try content.write(toFile: fileNameFromKey(key: fileName), atomically: true, encoding: String.Encoding.utf8)
            pathTable.setObject(.string(fileName), forKey: key)
            typeTable.setObject(.string(type), forKey: key)
            
        }catch let error {
            printLog("FileObjectStore write file error: \n \(error.localizedDescription)")
        }
    }
    
    
    public func removeForKey(_ key: String){
        let fileNameData = pathTable.objectForKey(key)
        if fileNameData == .null{
            return
        }
        
        do{
            let fileName = fileNameFromKey(key: fileNameData.toString())
            try FileManager.default.removeItem(atPath: fileName)
            pathTable.removeForKey(key)
            typeTable.removeForKey(key)
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
            let fileName = data.toString()
            do{
                let val = try String(contentsOfFile: fileNameFromKey(key: fileName), encoding: String.Encoding.utf8)
                let data = DataType(type: typeName, rawValue: val)
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
                try FileManager.default.removeItem(atPath: self.fileNameFromKey(key: fileName))
            }catch let error {
                printLog("delete file error: \n \(error.localizedDescription)")
            }
        }
        
        pathTable.cleanAll()
        typeTable.cleanAll()
    }

    func fileNameFromKey(key: String) -> String{
        return storeDirectory + "/" + key.md5()
    }
    let pathTable : TableKVStore
    let typeTable : TableKVStore
    let storeDirectory : String
    let kvtableFile = "/fileKV.db"
    let pathTableName = "filepath"
    let typeTableName = "datatype"
}
