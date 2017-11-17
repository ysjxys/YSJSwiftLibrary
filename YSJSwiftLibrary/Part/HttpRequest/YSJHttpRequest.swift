//
//  YSJHttpRequest.swift
//  TestHandyJson
//
//  Created by ysj on 2017/10/30.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import HandyJSON

public enum Method: String {
    case post = "POST"
    case get = "GET"
}


public protocol YSJHttpRequest {
    
    var host: String { get }
    
    var path: String { get }
    
    var method: Method { get }
    
    var header: [String: String]? { get }
    
    var param: [String: Any]? { get }
    
    associatedtype Model: YSJModeling
}
