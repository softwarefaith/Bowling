//
//  Interceptor.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/21.
//

import Foundation
///  拦截器协议
public protocol IPlugin{
    
    //表示是否要把当前请求拦截下来
    func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool
    
    func didReceive<T>(request: IRequest,response:GenericResponse<T>)
    
    func afterCompletion<T>(request: IRequest,response:GenericResponse<T>)
}

public extension IPlugin {
    
    func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool{
        return true
    }
    func didReceive<T>(request: IRequest,response:GenericResponse<T>){
        
    }
    func afterCompletion<T>(request: IRequest,response:GenericResponse<T>){
        
    }
}



open class NetLoggerPlugin: IPlugin {

    open var logSuccess: Bool

    open var logFailures: Bool


    public init(
        logSuccess: Bool = true,
        logFailures: Bool = true
        ) {
        self.logSuccess = logSuccess
        self.logFailures = logFailures
       
    }
    
    //表示是否要把当前请求拦截下来
    open func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool {
        
        if request.openLog {
            log(request.requestLog)
        }

        return true
    }
       
    open  func didReceive<T>(request: IRequest,response:GenericResponse<T>){
        
        switch response.result {
            case .success(_): do {
                if self.logSuccess {
                    log(response.toString())
                    print("Request success ✅")
                }
            }
            case .failure(_):do {
                if self.logFailures {
                                  
                    print("❗️ Request errored, gathered debug information: ")
                    log(response.toString())
                    log(response.error.debugDescription)
                }
             }
    
        case .none:do{log("log none")
            }
            
        }
    }
}
