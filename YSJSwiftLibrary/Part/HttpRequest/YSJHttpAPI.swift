//
//  YSJHttpAPI.swift
//  TestHandyJson
//
//  Created by ysj on 2017/10/30.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

struct YSJHttpAPI {
    
    private static let shared = YSJHttpAPI()
    
    static func send<T: YSJHttpRequest> (request: T, successHandle: @escaping (T.Model?) -> Void, failHandle: ((Error?) -> Void)?, netErrorHandle: (() -> Void)? = nil ){
        
        //检测网络
        guard let reachability = NetworkReachabilityManager(host: "www.baidu.com") else {
            return
        }
        if !reachability.isReachable {
            if let closure = netErrorHandle {
                closure()
            }
            return
        }
        
        guard let urlString = URL(string: request.host) else {
            return
        }
        
        let url = urlString.appendingPathComponent(request.path)
        let method = HTTPMethod(rawValue: request.method.rawValue) ?? .post
        let param = request.param
        let encoding = JSONEncoding.default
        let header = request.header

        Alamofire.request(url, method: method, parameters: param, encoding: encoding, headers: header).responseJSON { (response) in
            let isSuccess = response.result.isSuccess
            
            if isSuccess {
                let valueDic = response.value as? [String: Any]
                successHandle(T.Model.deserialize(from: valueDic))
            } else {
                if let closure = failHandle {
                    closure(response.error)
                }
            }
        }
    }
}
