//
//  NetworkingProvider.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/11.
//

import Foundation
import Alamofire


public typealias ResponseCompletionCallback = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void


/// 网络提供者
public protocol INetProvider {
    
    @discardableResult
    func startRequest(
            _ request: URLRequest,
            completion: @escaping ResponseCompletionCallback)->ITask?
}

public protocol NetProviderFactory {
   static var bowlingNetworkingProvider: INetProvider { get }
}


public class AlamofireProvider:INetProvider {
    

    public let manager: SessionManager

    public init(manager:SessionManager = SessionManager.default)
        { self.manager = manager }
    
    public convenience init(configuration: URLSessionConfiguration,serverTrustPolicyManager:ServerTrustPolicyManager?=nil){
      
        self.init(manager: SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager))
    }
    
    public convenience init(serverTrustPolicyManager:ServerTrustPolicyManager){
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
           self.init(manager: SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager))
    }
    
    public convenience init(policies:[String:ServerTrustPolicy]){
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        self.init(manager: SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)))
    }
    
    
    public func startRequest(_ request: URLRequest, completion: @escaping ResponseCompletionCallback)->ITask? {
        
        let dataRequest =  manager.request(request)
        
         dataRequest.responseData { (response) in
            completion(response.request,response.response,response.data,response.error)
            
        }
        return dataRequest as? ITask
    }
    
    /// 无HTTPS 认证
    public static var `default` = AlamofireProvider();
    
    //public static let  defalutHTTPS
    
    
    public static func sharedHTTPS(policies:[String:ServerTrustPolicy]?) -> AlamofireProvider {
        
        if policies != nil {
            return AlamofireProvider(policies: policies!)
        }
        return AlamofireProvider.default
    }
    
}

extension DataRequest:ITask {
    
}

extension AlamofireProvider:NetProviderFactory {
    public static var bowlingNetworkingProvider: INetProvider {
        return AlamofireProvider.default
    }
}

/*  HTTPS 事例
 
 let trustPolicyManager = ServerTrustPolicyManager(policies: [
     "github.com": .pinCertificates(
         certificates:ServerTrustPolicy.certificates(in: Bundle.main),
         validateCertificateChain: true,
         validateHost: true),
     "ms-common.test.com": .pinCertificates(
         certificates:ServerTrustPolicy.certificates(in: Bundle.main),
         validateCertificateChain: true,
         validateHost: true),
     ]);
 let configuration = URLSessionConfiguration.default
 configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
 return Alamofire.SessionManager(configuration: configuration,
                                 serverTrustPolicyManager: trustPolicyManager);
 
 host是全匹配的, 证书可以是通用(*.test.com), 但是host要写全(api.test.com)
 如果你用了其他的SessionDelegate，那么会覆盖该设置
 */


