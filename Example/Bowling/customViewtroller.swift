//
//  customViewtroller.swift
//  Bowling_Example
//
//  Created by 蔡杰 on 2019/8/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Bowling
import HandyJSON

struct CustomStruct {}
extension CustomStruct:IRequest {
   
    var path: String {
        return "postStruct0"
    }
    var method: HTTPMethod {return .post}
    var bodyParameters: Parameters?{return ["name":"ccjj","age":100]}
    var headers: HTTPHeaders?{return ["header100":"value100"]}
}


struct ErrorStruct {
    

}
extension ErrorStruct:IRequest {
   
    var path: String {
        return "postStruct1"
    }
    var method: HTTPMethod {return .post}
    var bodyParameters: Parameters?{return ["name":"ccjj","age":100]}
    var headers: HTTPHeaders?{return ["header100":"value100"]}
}

extension CustomStruct:IPlugin {
    func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool{
        return true
    }
    
    func didReceive<T>(request: IRequest,response:GenericResponse<T>){
        print("didReceive CustomStruct")
    }
    
    func afterCompletion<T>(request: IRequest,response:GenericResponse<T>){
          print("afterCompletion CustomStruct")
    }
    
}

enum LogiError:Error {
    case bussinses(Int,String)
}


struct DefaultVerify:IVerify{
   
    func validate(_ data: Any?) throws -> Bool {
        guard let map = data as? [String:Any], let status = map["status"] as? Int else{
            return false
        }
    
        if status != 0{
            let msg = (map["message"] as? String) ?? ""
            throw LogiError.bussinses(status, msg)
        }
        return true
    }
    
    func keyPath() -> String? {
        return "data"
    }
}



class customViewtroller: BaseViewController{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defalutConfig = Configuration.default
        defalutConfig.baseURL = "http://localhost:3000"
        defalutConfig.addHTTPHeaders(headers: ["commondH":"commondV"])
        defalutConfig.dynamicFetchHTTPHeader { () -> [String : String] in
            return ["dynamicKey":"value"]
        }
        defalutConfig.openLog = true
        defalutConfig.vertify = DefaultVerify()
        
       let post = CustomStruct()
        
   
        NetTask<Info>(request: post).onSuccess { (entity) in
            
            let info = entity.value
            
        }.onFailure { (error) in
             print("error --- \(error)")
        }.onCompletion { (response) in
            
            if  case .success(let entity) = response.result {
                    let info = entity.value
            }
             print("onCompletion")
            print(response.toString())
        }.onCompletion { (response) in
            
            if  case .success(let entity) = response.result {
                    let info = entity.value
            }
             print("onCompletion")
            print(response.toString())
        }.onCompletion { (response) in
            
            if  case .success(let entity) = response.result {
                    let info = entity.value
            }
             print("onCompletion")
            print(response.toString())
        }.start()
        
         let postError = ErrorStruct()
        
        NetTask<Any>(request: postError).onSuccess { (entity) in
                   
                   
                   
               }.onFailure { (error) in
                    print("error --- \(error)")
               }.onCompletion { (response) in
                   
                   if  case .success(let entity) = response.result {
                          // let info = entity.value
                   }
                    print("onCompletion")
                   print(response.toString())
               }.start()
        
    }

}
