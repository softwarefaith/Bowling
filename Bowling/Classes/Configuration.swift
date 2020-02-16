//
//  Configuration.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/10.
//

import Foundation


/// 公共网络配置
///  必须提供 serverHost
public class Configuration {
    
    ///公共服务端地址 eg: https://www.xxx.com
    public var  baseURL:String!
    
    //  `nil` by default.
    public var version: String?
   
    ///请求响应时间
    public var  timeoutInterval: TimeInterval = 60.0
    
    ///公共静态请求头 [String: String]
    private var HTTPHeaderMap:HTTPHeaders=HTTPHeaders()
    
    ///公共动态请求头
    private var dynamicHTTPHeader:(()->[String:String])?
    
    ///用于表示是否在控制台输出请求和响应的信息，默认为 NO
    public var openLog: Bool = false
    
    public var responseParser:IResponsePasrser = JSONResponseParser(readingOptions: .allowFragments)
    
    public var vertify:IVerify?
    
     var plugins: [IPlugin]?
    
    public init(){}
    
    /// 默认配置
    public static let `default` = Configuration();
    

}


extension Configuration {
    
    public  func addHTTPHeader(key:String, value:String){
        HTTPHeaderMap[key] = value
    }
    
    public  func addHTTPHeaders(headers:[String : String]){
        HTTPHeaderMap =    HTTPHeaderMap.merging(headers) { $1 }
    }
    
    //公共动态请求头
    public  func dynamicFetchHTTPHeader(closure: @escaping ()->[String:String]){
        dynamicHTTPHeader = closure
    }
}

internal extension Configuration {
    // 公共请求头组装
    var commonHTTPHeaderMap: [String : String]{
        if let dynamicHeader = dynamicHTTPHeader {
            let combinedDict = HTTPHeaderMap.merging((dynamicHeader())) { $1 }
            return combinedDict;
        }
        return HTTPHeaderMap;
    }
}



