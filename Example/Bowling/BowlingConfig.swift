//
//  BowlingConfig.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/7/8.
//

import Foundation

/// 全局网络配置【单例】
public class BowlingGlobalConfig {
    
    //公共服务端地址 https://www.xxx.com
    public var  serverHost:String?
   
    //请求响应时间
    public var  timeoutInterval: TimeInterval = 60.0
    
    // 公共静态请求头
    private var HTTPHeaderMap:[String : String]=[String : String]()
    
    ///公共安全策略
    public var commonServerTrustPolicies: [String : ServerTrustPolicy]?
    
    //公共拦截器
    public var commonInterceptor: [BowlingInterceptor]?
    
     //结构化数据 配置
    public var result_key: ResultKey?
    
    //公共动态请求头
    private var dynamicHTTPHeader:(()->[String:String])?
    
    //用于表示是否在控制台输出请求和响应的信息，默认为 NO
    public var openLog: Bool = false
    
    private init(){}
    
    //单例
    public static let `default` = BowlingGlobalConfig();

    public struct ResultKey {
        var code: String = "status"
        var msg: String = "msg"
        var data: String = "data"
        var successCode: Int = 0
        public init(code: String = "status",
                    msg: String = "msg",
                    data: String = "data",
                    success: Int = 0) {
            self.code = code
            self.msg = msg
            self.data = data
            self.successCode = success
        }
        init() {
            
        }
        
    }
}

extension BowlingGlobalConfig {
    
    public func addHTTPHeader(key:String, value:String){
        HTTPHeaderMap[key] = value
    }
    
    public func addHTTPHeaders(headers:[String : String]){
        HTTPHeaderMap =    HTTPHeaderMap.merging(headers) { $1 }
    }
    
    //公共动态请求头
    public func dynamicFetchHTTPHeader(closure: @escaping ()->[String:String]){
        dynamicHTTPHeader = closure
    }
    
    public func registerInterceptor(interceptor:BowlingInterceptor){
        
        if let _ = commonInterceptor { } else {
            commonInterceptor = [BowlingInterceptor]()
        }
        commonInterceptor?.append(interceptor)
    }
    
    public func registerServerTrustPolicies(policies:[String : ServerTrustPolicy]){
        self.commonServerTrustPolicies = policies;
    }
}


extension BowlingGlobalConfig {
    // 公共请求头组装
    internal var commonHTTPHeaderMap: [String : String]?{
        if let dynamicHeader = dynamicHTTPHeader {
            let combinedDict = HTTPHeaderMap.merging((dynamicHeader())) { $1 }
            return combinedDict;
        }
        return HTTPHeaderMap;
    }
}
