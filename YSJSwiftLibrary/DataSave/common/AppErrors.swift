//
//  AppErrors.swift
//  Miss
//
//  Created by apple on 16/11/24.
//  Copyright © 2016年 Xinguang. All rights reserved.
//

import Foundation

// MARK: - Protocol
public protocol ErrorMessageProtocol {
    var errorMessage: String { get }
}


// MARK: - Error Defines
/// 网络请求相关错误
enum NetworkError: Error {
    case MissURLString
    case MissAppInitID
    case MissAppKey
    case MissLoginInfo
    case MissReloginResponseToken
    
    case AlamofireError(error: NSError)
    case ResponseStatusCodeError(statusCode: Int)
    
    case InvalidJSONObject
    case MissValidThreeComponents
    
    case DataCompressFail
    
    case ServerError(code: Int, message: String?)
    
}

extension NetworkError: ErrorMessageProtocol {
    var errorMessage: String {
        get {
            switch self {
            case .MissURLString:
                return "URL 缺失"
            case .MissAppInitID:
                return "App Init ID 缺失"
            case .MissAppKey:
                return "App Init Key 缺失"
            case .MissLoginInfo:
                return "已登录用户信息缺失"
            case .MissReloginResponseToken:
                return "重登录 Token 缺失"
            case .AlamofireError(let error):
                return error.localizedDescription
            case .ResponseStatusCodeError(let statusCode):
                return "请求出错，错误码：\(statusCode)"
            case .InvalidJSONObject:
                return "JSON返回数据缺失"
            case .MissValidThreeComponents:
                return "返回数据三件套(code、message、result)缺失"
            case .DataCompressFail:
                return "视频/图片 压缩失败"
            case .ServerError(_, message: let message):
                return message ?? ""
            }
        }
    }
}

enum AppError {
    case alertInfo(info: String)
}

extension AppError: ErrorMessageProtocol {
    var errorMessage: String {
        get {
            switch self {
            case .alertInfo(info: let info):
                return info
            }
        }
    }
}

/// 服务端错误码
enum ServerError: Int {
    case None = 0
    case NotLogin
    case TokenInvalid
    case ProtocolParseFail
}

// MARK: - Function

/// 打印文件名、函数名、行号及自定义信息
public func printLog<T>(_ message: T,
                     file: String = #file,
                     method: String = #function,
                     line: Int = #line)
{
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}


/// 错误信息展示方法
func showError(error: ErrorMessageProtocol) {
//    printLog(error.errorMessage)
//    ToastError(error.errorMessage)
    print("error.errorMessage:\(error.errorMessage)")
}
