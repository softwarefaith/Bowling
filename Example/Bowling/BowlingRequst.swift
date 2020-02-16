//
//  BowlingRequst.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/7/8.
//

import Foundation


//默认rawvalue GET: "GET"
public enum method:String{
    case GET,HEAD,POST,PUT
}

public enum RequestSerializer{
    case Raw
    case Json
    case PropertyList
}

public enum ResponseSerializer{
    case Raw
    case Json
    case PropertyList
    case XML
}

//MARK: BowlingRequst 请求配置协议
///BowlingRequst 请求配置协议
public protocol BowlingRequst{
    
    var URLString: String?{get}
    /// 发出网络请求的基础地址字符串
    var baseURL: String?{get}
    
    /// 网络请求的路径字符串
    var path: String {get}
    
    /// 网络请求的方式，默认返回get
    var method: HTTPMethod {get}
    
    /// 网络请求参数
    var parameters: Parameters? {get}
    
    /// 网络请求头，默认返回 nil
    var headers: HTTPHeaders? {get}
    
    /// 网络请求超时时间，默认返回 60s
    var timeoutInterval: TimeInterval {get}
    
    /// 是否允许蜂窝数据网络连接，yes【待定参数】
    var allowsCellularAccess: Bool {get}
    
    /// 生成请求后是否立即进行请求，默认返回 ture[待定考虑]
    var startImmediately: Bool {get}
    
    ///编码类型,默认 URLEncoding.default
    var parameterEncoding: ParameterEncoding {get}
    
    /// 日志打印 默认取：globalConfig.openLog
    var openLog:Bool{get}
    
    /// 拦截器 - 注意循环引用问题，默认 nil
    var interceptor : BowlingInterceptor?{get}
    
    /// 安全策略默认 nil
    var serverTrustPolicies: [String : ServerTrustPolicy]? {get}
    
    /// HandJSON 解析path默认 nil
    var dataKeyPath:String?{get}
}
//MARK: BowlingRequst 请求配置协议 部分参数m默认实现
/// BowlingRequst 请求配置协议 部分参数m默认实现
public extension BowlingRequst {
    
    var URLString: String?{ return nil }

    var baseURL: String? {
        return globalConfig.serverHost
    }
    
    var method: HTTPMethod { return .get }
    
     var headers: HTTPHeaders? { return nil }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var allowsCellularAccess: Bool { return true }
    
    var startImmediately: Bool { return true }
    
    var openLog:Bool{
       return  globalConfig.openLog
    }
    
    var serverTrustPolicies: [String : ServerTrustPolicy]? {
         return  globalConfig.commonServerTrustPolicies
    }
    
    var timeoutInterval: TimeInterval {
        return globalConfig.timeoutInterval
    }
    
    var interceptor : BowlingInterceptor?{ return nil }
    
    var dataKeyPath:String?{ return nil }
}


//MARK: 请求参数【packageHeaders，asURL】与globalConfig参数拼接
extension BowlingRequst {
    
    ///URL 拼接：优先使用 URLString-> baseURL + Path ->global.serverHost+Path
   internal var asURL:String? {
    
    
        if let urlSring = self.URLString {
            return urlSring;
        }
         if let _ = self.baseURL, self.baseURL!.count>0 {
                   return self.baseURL! + self.path
         }
        
        if let serverHost = globalConfig.serverHost {
            return serverHost + self.path;
        }
        return nil
    }
    
    ///header 合并 global.header + request.header
   internal var packageHeaders: HTTPHeaders? {
        
        if let commonHeader = globalConfig.commonHTTPHeaderMap {
            
            if let customHeader = self.headers{
                return commonHeader.merging(customHeader) { $1 }
            }
            return commonHeader
        }
        
        return self.headers
    }
    
    /// 拦截器合并 global.Interceptor + request.Interceptor
   internal var packageInterceptor: [BowlingInterceptor]? {
        
        guard let commonInterceptor = globalConfig.commonInterceptor,let _ = self.interceptor  else {
            
            if(self.interceptor != nil){ return [self.interceptor!]}
            return globalConfig.commonInterceptor
            
        }
        
        var interceptors = [BowlingInterceptor]()
        interceptors.append(contentsOf: commonInterceptor)
        interceptors.append(self.interceptor!)
        return interceptors
    }
    
}

//MARK: BowlingDefaultRequst 实现BowlingRequst 支持 链式调用
/// BowlingDefaultRequst 实现协议 BowlingRequst
public class BowlingDefaultRequst:BowlingRequst {
    
    public var interceptor: BowlingInterceptor?
    
    public var baseURL: String = ""
    
    public var timeoutInterval: TimeInterval = 60
    
    public var parameterEncoding: ParameterEncoding = URLEncoding.default
   
    public var method: HTTPMethod
    
    public var URLString: String?
    
    public var path:String
    
    public var parameters: Parameters?
    
    public var headers:[String:String]?

    public var dataKeyPath: String?
    
    //MARK: - Life Cycle
    required init(method: HTTPMethod = .get,
                URLString: String? = nil,
                path: String = "",
                headers: [String: String]? = nil,
                parameters: Parameters? = nil,
                parameterEncoding: ParameterEncoding = URLEncoding.default) {
        self.method = method
        self.URLString = URLString
        self.path = path;
        self.parameters = parameters
        self.headers = headers
        self.parameterEncoding = parameterEncoding
        
    }
    
    deinit {
        print("HTTPRequst已销户")
    }
    
}

//MARK: 构建BowlingRequst 参数链式调用
extension BowlingDefaultRequst {
    
    convenience init(){
          self.init(method: .get, URLString: nil, path: "", headers: nil, parameters: nil)
    }
    
    @discardableResult
    public func urlString(url:String)->Self {
        self.URLString = url
        return self;
    }
    
    @discardableResult
    public func host(host:String)->Self {
        self.baseURL = host
        return self;
    }
    
    @discardableResult
    public func path(path:String)->Self {
         self.path = path
        return self;
    }
    
    @discardableResult
    public func addParams(params: Parameters!)->Self {
        if self.parameters == nil {
            self.parameters = [String:Any]()
        }
        self.parameters = self.parameters?.merging(params) { $1 }
        return self;
      
    }
     @discardableResult
    public func addParam(key:String,value:Any!)->Self {
        if self.parameters == nil {
            self.parameters = [String:Any]()
        }
        self.parameters![key] = value;
        return self;       
    }
    
  @discardableResult
    public func addHTTPHeader(key: String,value: String)->Self {
        if self.headers == nil {
             self.headers = [String:String]()
        }
        self.headers![key] = value;
        return self;
    }
    
    @discardableResult
    public func addHTTPHeaders(headrs:[String:String])->Self {
        if self.headers == nil {
            self.headers = [String:String]()
        }
        self.headers = self.headers?.merging(headrs) { $1 }
        return self;
    }
    
   @discardableResult
   public func setParameterEncoding(encoding:ParameterEncoding)->Self{
        self.parameterEncoding = encoding
        return self;
    }
    
    @discardableResult
    public func registerInterceptor(interceptor:BowlingInterceptor)->Self{
        self.interceptor = interceptor
        return self;
    }
    
    @discardableResult
    public func setDataKeyPath(path:String)->Self{
        self.dataKeyPath = path
        return self;
    }
}




//MARK: - DEBUG info
extension BowlingRequst {
    
    public var requestLog: String {
        
        var headersString: String? = "nil"
        var parametersString: String? = "nil"
        
        if let _ = headers {
            let headersData = try? JSONSerialization.data(withJSONObject: headers!, options: [.prettyPrinted])
            if let data = headersData {
                headersString = String(data: data, encoding: .utf8)
            }
        }
        if let _ = parameters {
            let parametersData = try? JSONSerialization.data(withJSONObject: parameters!, options: [.prettyPrinted])
            parametersString = String(data: parametersData ?? Data(), encoding: .utf8)
        }
        
        var url:String? = "nil"
        
        if let _ = asURL {
            url = asURL!
        }
        
        return """
        
        ------------------------ BowlingHTTPRequst -----------------------
        URL:\((url!))
        Headers:\(headersString!)
        Parameters:\(parametersString!)
        ----------------------------------------------------------
        """
    }
}

