//
//  TableKVStore.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation
import FMDB

public class TableKVStore: StoreBase, KeyValueStoreProtocol{
    public init(dbPath: String, tableName: String){
        self.tableName = tableName
        self.databaseQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        self.databaseQueue.inDatabase { (db) -> Void in
            let sql = "CREATE TABLE IF NOT EXISTS \(self.tableName) (\(self.schema))"
            db?.executeStatements(sql)
        }
    }
    
    init(databaseQueue: FMDatabaseQueue, tableName: String){
        self.tableName = tableName
        self.databaseQueue = databaseQueue
        super.init()
        self.databaseQueue.inDatabase { (db) -> Void in
            let sql = "CREATE TABLE IF NOT EXISTS \(self.tableName) (\(self.schema))"
            db?.executeStatements(sql)
        }
    }
    
    public override func objectForKey(_ key: String) -> DataType{
        var ret = DataType.null
        databaseQueue.inDatabase { (db) -> Void in
            let sql = "select * from \(self.tableName) where key=?"
            do {
                let rs = try db?.executeQuery(sql, values: [key])
                while (rs?.next())! {
                    let typename = rs?.string(forColumn: "typename")
                    let content = rs?.string(forColumn: "data")
                    if typename != nil && content != nil {
                        ret = DataType(type: typename!, rawValue: content!)
                    }
                    break
                }
                rs?.close()
            } catch let error{
                printLog("TableObjectStore objectForKey failed: \n \(error.localizedDescription)")
            }
        }
        return ret
    }
    
    public override func setObject(_ data : DataType, forKey key: String){
        switch data{
        case .null:
            removeForKey(key)
        default:
            databaseQueue.inDatabase { (db) -> Void in
                let sql = "INSERT OR REPLACE INTO \(self.tableName)(key, typename, data) VALUES (?, ?, ?)"
                do {
                    try db?.executeUpdate(sql, values: [key, data.typeString(), data.toString()])
                } catch let error{
                    printLog("TableObjectStore setObject failed: \n \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func removeForKey(_ key: String){
        databaseQueue.inDatabase { (db) -> Void in
            let sql = "delete from \(self.tableName) where key=?"
            do {
                try db?.executeUpdate(sql, values: [key])
            } catch let error{
                printLog("TableObjectStore removeForKey failed: \n \(error.localizedDescription)")
            }
        }
    }
    
    public func enumerateKeysAndObjectsUsingBlock(block: @escaping (_ key: String, _ data: DataType)->()){
        databaseQueue.inDatabase { (db) -> Void in
            let sql = "select * from \(self.tableName)"
            do {
                let rs = try db?.executeQuery(sql, values: nil)
                while (rs?.next())! {
                    let key = rs?.string(forColumn: "key")
                    let typename = rs?.string(forColumn: "typename")
                    let content = rs?.string(forColumn: "data")
                    if typename != nil && content != nil && key != nil{
                        let data = DataType(type: typename!, rawValue: content!)
                        block(key!, data)
                    }
                }
                rs?.close()
            } catch let error{
                printLog("TableObjectStore objectForKey failed: \n \(error.localizedDescription)")
            }
        }
    }
    
    public func cleanAll() {
        databaseQueue.inDatabase { (db) -> Void in
            let sql = "delete from \(self.tableName)"
            do {
                try db?.executeUpdate(sql, values: nil)
            }
            catch let error{
                printLog("TableObjectStore cleanAll failed: \n \(error.localizedDescription)")
            }
        }
    }
    
    public var tableName : String
    var databaseQueue: FMDatabaseQueue
    let schema = "key varchar(255) primary key, typename varchar(128), data blob"
}
