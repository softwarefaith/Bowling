//
//  Bowling.swift
//  Pods
//
//  Created by 蔡杰 on 2019/7/8.
//

import Foundation
import Alamofire


private let BowlingResponseQueue: String  = "com.Bowling.ResponseQueue"

extension BowlingRequst {
    public var requestID: String {
        return ""
       // return String.buildRequestID(method: self.method, url: self.asURL!)
    }
}

let defaultManager = BowlingManager.default

public class BowlingManager {
    // MARK: - Properties
    public let sessionManager: SessionManager
    public var serverTrustPolicyManager: ServerTrustPolicyManager?
    
    private var requesManager = [String: BowlingResponse]()
    
    private lazy var responseQueue = { return DispatchQueue(label: BowlingResponseQueue) }()
    
    internal let seriQueue = DispatchQueue(label: "BowlingManager")
    
    public static let `default`: BowlingManager =  BowlingManager.init()
    
    
    // MARK: - Lifecycle
    public init() {

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = globalConfig.timeoutInterval
    
        var policyManager: ServerTrustPolicyManager?
        if let serverTrustPolicies = globalConfig.commonServerTrustPolicies {
            policyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
            self.serverTrustPolicyManager = policyManager
        }
        //TODO:认证策略
        self.sessionManager = SessionManager(configuration: configuration,  serverTrustPolicyManager: policyManager)
    }
}
// MARK: - sendRequest
extension BowlingManager {
    public func call(_ request: BowlingRequst)->BowlingResponse? {
        let response = BowlingResponse(request: request, sessionManager: self.sessionManager)
        
        if(response != nil){self.addResponse(response: response)}
    
        return response;
    }
}
// MARK: - response manager

extension BowlingRequst {
    
   public func onCancel(){
        BowlingManager.default.cancelRequest(request: self)
    }
    
}


//MARK: 添加 | 删除 Response ； 取消请求
extension BowlingManager {
   
    func addResponse(response:BowlingResponse!){
           print("addResponse")
        requesManager[response.request.requestID] = response
    }
    
    func removeResponse(response:BowlingResponse){
         print("removeResponse")
        let key = response.request.requestID
        if requesManager.keys.contains(key) {
            requesManager.removeValue(forKey: response.request.requestID)
        }
    }
    
   public func cancelRequest(request:BowlingRequst!) {
        self.cancelRequest(method: request.method, url: request.asURL!)
    }
    
   public func cancelRequest(method:HTTPMethod!,url:String!) {
       // let key =  String.buildRequestID(method: method, url: url)
      let key = ""
        if requesManager.keys.contains(key) {
            
            print("cancelRequest")
            let response:BowlingResponse? = requesManager[key]
            response?.cancel()
        }
    }
    
}
