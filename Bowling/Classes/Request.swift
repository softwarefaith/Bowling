//
//  Request.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/9/18.
//

import Foundation


//MARK: IRequest 协议
public protocol IRequest {
    
    var requestIdentifier:String { get }

    /// 配置，defaur is  Configuration.`default`
    var  configuration: Configuration { get }
    
    /// 网络请求的方式，默认返回get
    var method: HTTPMethod {get}
    
    /// 发出网络请求的基础地址字符串
    var baseURL: String {get}
    
    ///
    var version: String? { get }

    /// 网络请求的相对路径字符串
    var path: String {get}
    
    /// query parameters.  ?key=value&key=Value
    var queryParameters: [String: Any]? { get }
      
    /// 网络请求头，默认返回 nil [String: String]
    var headers: HTTPHeaders? {get}
   
    /// 网络请求参数 [String: Any]
    var bodyParameters: Parameters? {get}
    
    ///编码类型,默认 URLEncoding.default
    var parameterEncoding: ParameterEncoding {get}
    
    /// 网络请求超时时间，默认返回 60s
    var timeoutInterval: TimeInterval {get}
    
    /// 是否允许蜂窝数据网络连接，yes【待定参数】
    var allowsCellularAccess: Bool {get}
    
    /// 生成请求后是否立即进行请求，默认返回 ture[待定考虑]
    var startImmediately: Bool {get}
    
    /// 日志打印 默认取：globalConfig.openLog
    var openLog:Bool{get}
    
    ///  response 解析  默认 json
    var responseParser:IResponsePasrser {get}
    
    var plugins: [IPlugin]?{get}
    
}

extension IRequest {
    
    var vertify:IVerify? {
        return configuration.vertify
    }
    
}

//MARK: IRequest 请求配置协议 部分参数m默认实现
/// IRequestProtocol 请求配置协议 部分参数m默认实现
public extension IRequest {
    
    var requestIdentifier:String {
        return  String.buildRequestID(method: method, url: baseURL+"/\(path)")
    }
    
    var configuration: Configuration { return Configuration.default}

    var baseURL: String { return configuration.baseURL}

    var version: String? { return configuration.version }

    var method: HTTPMethod { return .get}

    var headers: HTTPHeaders? { return nil }

    var queryParameters: [String: Any]? { return nil}

    var bodyParameters: Parameters? { return nil}

    var parameterEncoding: ParameterEncoding { return URLEncoding.default }

    var timeoutInterval: TimeInterval { return configuration.timeoutInterval }

    var allowsCellularAccess: Bool { return true }

    var startImmediately: Bool { return true }

    var openLog:Bool{ return  configuration.openLog }

    var responseParser:IResponsePasrser {return configuration.responseParser}
    
     var plugins: [IPlugin]?{ return nil}
    
}

extension IRequest {
    
    
    
    public var urlRequest: URLRequest {
        let url = [baseURL, version, path]
            .compactMap { $0 }
            .joined(separator: "/")
        
        var allHeaders = configuration.commonHTTPHeaderMap
        
        if let rHeader = headers {
            allHeaders = configuration.commonHTTPHeaderMap.merging(rHeader) { $1 }
        }
        var request = try! URLRequest(url: url, method: method, headers: allHeaders)

        let allQueryParameters = queryParameters
        request = try! URLEncoding.queryString.encode(request, with: allQueryParameters)

        if let parameters = bodyParameters {
           request = try! parameterEncoding.encode(request, with: parameters)
        }
        return request
    }
    
    internal var allPlugins: [IPlugin]? {
    
        let s = (self is IPlugin) ? [self] : [] + (plugins ?? [])
        return  s + (configuration.plugins ?? []) + (openLog ? [NetLoggerPlugin()] : []) as? [IPlugin]
    }
    
    func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool {
        
        
        guard let all = allPlugins else {
            return true
        }
        
        for plugin in all {
            
            let flag = plugin.willSend(request: request, task: task)
            if flag == false {
                return flag
            }
        }
        
        return true
    }
       
    func didReceive<T>(request: IRequest,response:GenericResponse<T>){
        
        allPlugins?.forEach({ (plugin) in
            plugin.didReceive(request: request, response: response)
        })
    }
       
    func afterCompletion<T>(request: IRequest,response:GenericResponse<T>){
        allPlugins?.forEach({ (plugin) in
            plugin.afterCompletion(request: request, response: response)
        })
    }
}




internal extension String {
   static func buildRequestID(method:HTTPMethod!,url:String!) -> String {
        let string = url! + method.rawValue
        return string.data(using: .utf8)?.base64EncodedString() ?? ""
    }
}


public protocol ArrayParameterEncoding {

    func encode(_ urlRequest: URLRequestConvertible, with parameters: [Any]?) throws -> URLRequest
}

/// An extension of Alamofire.JSONEncoding to support [Any] parameters
extension JSONEncoding: ArrayParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: [Any]?) throws -> URLRequest {
        return try encode(urlRequest, withJSONObject: parameters)
    }
    
}


extension IRequest {
    
    public var requestLog: String {
        
        var headersString: String? = "nil"
        var parametersString: String? = "nil"
        
        if let _ = headers {
            let headersData = try? JSONSerialization.data(withJSONObject: headers!, options: [.prettyPrinted])
            if let data = headersData {
                headersString = String(data: data, encoding: .utf8)
            }
        }
        if let _ = bodyParameters {
            let parametersData = try? JSONSerialization.data(withJSONObject: bodyParameters!, options: [.prettyPrinted])
            parametersString = String(data: parametersData ?? Data(), encoding: .utf8)
        }
        
       
        
        return """
        
        ------------------------ BowlingHTTPRequst -----------------------
        URL:\((self.baseURL+"\\(self.path)"))
        Headers:\(headersString!)
        Parameters:\(parametersString!)
        ----------------------------------------------------------
        """
    }
}


