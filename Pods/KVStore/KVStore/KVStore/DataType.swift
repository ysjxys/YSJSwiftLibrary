//
//  .swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2016/12/20.
//  Copyright © 2016年 ysj. All rights reserved.
//

import Foundation

public protocol ObjectProtocol{
    func objectToString() -> String
    static func objectFromString(str: String) -> Object?
}

public class Object : NSObject, ObjectProtocol{
    public func objectToString() -> String {
        return ""
    }
    
    public class func objectFromString(str: String) -> Object?{
        let ret:Object = Object()
        
        return ret;
    }
}


public enum DataType : Equatable{
    case null
    case string(String)
    case dictionary([String: Any])
    case stringWithTime(String, String)
    case dictionaryWithTime([String: Any], String)
    case array([Any])
    case object(Object)
    
    public init(type:String, rawValue:String, timestamp:String = "0"){
        switch type{
        case "null":
            self = .null
        case "string":
            self = .string(rawValue)
        case "dictionary":
            self = .dictionary(rawValue.StringToDict())
        case "stringWithTime":
            self = .stringWithTime(rawValue, timestamp)
        case "dictionaryWithTime":
            self = .dictionaryWithTime(rawValue.StringToDict(), timestamp)
        case "array":
            self = .array(rawValue.StringToArray())
        case _ where type.hasPrefix("object:"):
            self = .null
            let realType = type.substring(from: "object:".endIndex)
            if let nsclass = NSClassFromString(realType){
                let aclass = nsclass as! Object.Type
                
                if let aObj = aclass.objectFromString(str: rawValue){
                    self = .object(aObj)
                }
            }
        default:
            self = .null
        }
    }
    
    public func toString() -> String{
        switch self{
        case .null:
            return "null"
        case .string(let val):
            return "\(val)"
        case .dictionary(let val):
            let dict = val.DictToString()
            return dict
        case .stringWithTime(let val, _):
            return "\(val)"
        case .dictionaryWithTime(let val, _):
            let dict = val.DictToString()
            return dict
        case .array(let val):
            let array = val.ArrayToString()
            return array
        case .object(let val):
            return val.objectToString()
        }
    }
    
    public func typeString() -> String{
        switch self{
        case .null:
            return "null"
        case .string:
            return "string"
        case .dictionary:
            return "dictionary"
        case .stringWithTime:
            return "stringWithTime"
        case .dictionaryWithTime:
            return "dictionaryWithTime"
        case .array:
            return "array"
        case .object(let val):
            let className = val.classForCoder.description()
            return "object:\(className)"
        }
    }
    
    public func timestamp() -> String {
        switch self {
        case .stringWithTime(_, let timestamp):
            return "\(timestamp)"
        case .dictionaryWithTime(_, let timestamp):
            return "\(timestamp)"
        default:
            return "0"
        }
    }
    
    public func toOCObject() -> AnyObject?{
        var ret : AnyObject?
        switch self {
        case .dictionary(let dict):
            ret = dict as NSDictionary
        case .dictionaryWithTime(let dict, _):
            ret = dict as NSDictionary
        case .array(let array):
            ret = array as NSArray
        case .string(let str):
            ret = str as NSString
        case .stringWithTime(let str, _):
            ret = str as NSString
        case .object(let obj):
            ret = obj
        default:
            ret = nil
        }

        return ret
    }
    
    public static func fromOCObject(data: AnyObject?) -> DataType{
        var newData:DataType
        if let str = data as? String{
            newData = .string(str)
        }
        else if let dic = data as? Dictionary<String, Any>{
            newData = .dictionary(dic)
        }
        else if let array = data as? Array<Any>{
            newData = .array(array)
        }
        else if let obj = data as? Object{
            newData = .object(obj)
        }
        else{
            newData = .null
        }
        return newData
    }
}

public func ==(lhs: DataType, rhs: DataType) -> Bool{
    let ret = lhs.typeString() == rhs.typeString() && lhs.toString() == rhs.toString()
    return ret
}

/// 这是Object示例类，所有Object继承者都需要实现这两个方法。
public class ExampleObj : Object{
    public init(content : String) {
        self.content = content
    }
    public override func objectToString() -> String {
        return self.content
    }
    
    public override class func objectFromString(str: String) -> ExampleObj?{
        let ret = ExampleObj(content: str)
        return ret;
    }
    var content = "example"
}

public class ExampleObj2 : Object{
    public init(content : Int) {
        self.content = content
    }
    public override func objectToString() -> String {
        return "\(self.content)"
    }
    
    public override class func objectFromString(str: String) -> ExampleObj2?{
        let i = Int.init(str)
        let ret = ExampleObj2(content: i!)
        return ret;
    }
    var content = 2
}

