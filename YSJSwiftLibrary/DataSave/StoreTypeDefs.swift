//
//  StoreTypeDefs.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public enum LifecycleType{
    case persistent
    case cache
    case temp
    case security
}


public protocol StringInitable{
    init?(string : String)
}

extension Float : StringInitable{
    public init?(string : String){
        self.init(string)
    }
}
extension Int : StringInitable{
    public init?(string : String){
        self.init(string, radix:10)
    }
}
extension Double : StringInitable{
    public init?(string : String){
        self.init(string)
    }
}
extension Bool : StringInitable{
    public init?(string : String){
        if string == "true" {
            self = true
        }
        else{
            self = false
        }
    }
}


public protocol KeyValueStoreProtocol : NSObjectProtocol {
    func objectForKey(_ key: String) -> DataType
    func setObject(_ data : DataType, forKey key: String)
    func valueForKey<T:StringInitable>(_ key: String) -> T?
    func setValue<T>(_ value: T?, forKey key: String)
    
    func removeForKey(_ key: String)
    func enumerateKeysAndObjectsUsingBlock(block: @escaping(_ key: String, _ data: DataType)->())
    func cleanAll()
}

public class StoreBase : NSObject{
    public func valueForKey<T:StringInitable>(_ key: String) -> T? {
        //Float
        var ret : T?
        let data = self.objectForKey(key)
        switch data {
        case .string(let str):
            ret = T(string: String(str))
        default:
            ret = nil
        }
        
        return ret
    }
    
    public func setValue<T>(_ value: T?, forKey key: String) {
        if value == nil {
            self.setObject(.null, forKey: key)
        } else{
            let str = "\(value!)"
            self.setObject(.string(str), forKey: key)
        }
    }
    
    func objectForKey(_ key: String) -> DataType{return .null}
    func setObject(_ data : DataType, forKey key: String){}
    
    func objectForOCKey(_ key: String) -> AnyObject?{
        let data = self.objectForKey(key);
        let ret = data.toOCObject()
        return ret
    }
    
    func setOCObject(_ data : AnyObject?, forKey key: String){
        let data = DataType.fromOCObject(data: data)
        self.setObject(data, forKey: key)
    }
}

protocol SecurityStoreProtocol: KeyValueStoreProtocol{
    var accessGroup : String { get }
}

