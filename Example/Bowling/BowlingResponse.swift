//
//  BowlingResponse.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/7/8.
//

import Foundation
import Alamofire
import HandyJSON

public enum ResultError:Error {
    //HandJSON解析错误
    case parseModelError(String)
    //对应结果 status  msg
    case resultError(Int,String)
    //其他错误
    case otherError(String)
}



extension BowlingRequst {
    public func buildResponse()-> BowlingResponse?{
        let response = BowlingManager.default.call(self)
        if(response != nil){
            BowlingManager.default.addResponse(response: response)
        }
        return response;
    }
}

public extension BowlingRequst {
    
     func decideTo<T>(type:T.Type)->BowlingRequestCall<T>{
       
        let  call = BowlingRequestCall<T>(request: self)
        return call
    }
}

//MARK: - BowlingRequst 保留了底层框架的回调方式
extension BowlingRequst {
    
    public func responseData(completion: @escaping (BowlingValue<Data>)->()){
        let response =  buildResponse()
        response?.responseData(completion: completion)
    }
    
    public func responseJson(completion: @escaping (BowlingValue<Any>)->()) {
         let response =  buildResponse()
         response?.responseJson(completion: completion)
    }

}
//MARK: - 拦截器
extension BowlingRequst {
    
    func willSend() -> Bool{
        guard  let interceptors = self.packageInterceptor else {
            return true
        }
        for interceptor in interceptors {
           let  flag = interceptor.willSend(request: self)
           if(flag == false){
                if(self.openLog){
                    print("======请求\(String(describing: self.asURL))被打断=====")
                }
                return false
            }
        }
        return true
    }
    
    func didReceive<T>(resultValue:BowlingValue<T>){
        guard  let interceptors = self.packageInterceptor else {
            return
        }
        for interceptor in interceptors {
            interceptor.didReceive(request: self,resultValue:resultValue)
        }
    }
    func afterCompletion<T>(resultValue:BowlingValue<T>){
        guard  let interceptors = self.packageInterceptor else {
            return
        }
        for interceptor in interceptors {
            interceptor.afterCompletion(request: self,resultValue:resultValue)
        }
    }
}

// MARK: 响应体
public class BowlingResponse {
    
    public var request: BowlingRequst!
    
    internal  var dataRequest: DataRequest? = nil

    init() {
        
    }
    init?(request: BowlingRequst!,sessionManager:SessionManager) {
        self.process(request, manager: sessionManager)
    }
    
    @discardableResult
    func process(_ request: BowlingRequst!,manager:SessionManager? = nil) -> BowlingResponse? {
        
        //拦截器 willSend
        if request.willSend() == false {
            return nil
        }
        
        self.request = request
        
        if request.openLog {
            print(request.requestLog)
        }

        
        if manager != nil {
            dataRequest =  manager?.request(request.asURL!, method: request.method, parameters:request.parameters, encoding: request.parameterEncoding, headers: request.packageHeaders)
        } else {
            dataRequest = Alamofire.request(request.asURL!, method: request.method, parameters: request.parameters, encoding: request.parameterEncoding, headers: request.packageHeaders)
        }
        return self
    }
    
    deinit {
        print("BowlingResponse 消失")
    }
    
    ///结果返回
    fileprivate final func response<T>(response: DataResponse<T>, completion: @escaping (BowlingValue<T>)->()) {

        if request.openLog {
            debugPrint("----------------------------")
            debugPrint(response)
        }
         //拦截器 didReceive
        var result = BowlingValue(originResponse: response)
        result.request = request;
        request.didReceive(resultValue: result)
        
        completion(result)
         //拦截器 afterCompletion
        BowlingManager.default.removeResponse(response:self)
        
        request.afterCompletion(resultValue: result)
    }
}
extension BowlingResponse {
    
    public func cancel() -> Void {
        dataRequest?.cancel()
    }
    public func suspend() {
        dataRequest?.suspend()

    }
    public func resume() {
        dataRequest?.resume()
    }
}


extension BowlingResponse{
    public func responseData(completion: @escaping (BowlingValue<Data>)->()) {
       dataRequest?.responseData(queue: nil) {
          (originalResponse) in
          // guard let strongSelf = self else { return }
        self.response(response: originalResponse, completion: completion);
        }
    }
    
    public func responseString(completion: @escaping (BowlingValue<String>)->()) {
        dataRequest?.responseString(completionHandler: { (originalResponse) in
            self.response(response: originalResponse, completion: completion);
        })
    }
    
    public func responseJson(completion: @escaping (BowlingValue<Any>)->()) {
        dataRequest?.responseJSON(completionHandler: { (originalResponse) in
            self.response(response: originalResponse, completion: completion);
        })
    }
}



//MARK: 构建链式返回结果
extension BowlingRequestCall where Result == Data{
    
    func send() {
            self.request.buildResponse()?.responseData(completion: { value in
            
            if(value .isFailure){
                self.failed(value.error)
                return
            }
             self.success(value.transformData)
             self.finish(value)
        })
    }
}

public extension BowlingRequestCall where Result == String{
    func send() {
        
        self.request.buildResponse()?.responseString(completion: { value in
            
            if(value .isFailure){
                self.failed(value.error)
                return
            }
            self.success(value.transformData)
            self.finish(value)
        })
    }
}

public extension BowlingRequestCall where Result == Any{
    func send() {
        self.request.buildResponse()?.responseJson(completion: { value in
            
            if(value .isFailure){
                self.failed(value.error)
                return
            }
            self.success(value.transformData)
            self.finish(value)
        })
    }
}

public extension BowlingRequestCall where Result:HandyJSON{
    func send() {
        self.request.buildResponse()?.responseJson {
            value in
            var status:Int?
            var msg:String = ""
            
            let newResult =  value.result.flatMap({ (jsonObj) -> Result in
                
                if  let resultKey = globalConfig.result_key,let map = jsonObj as? [String:Any?]{
                    
                    status = map[resultKey.code] as? Int
                    
                    msg = (map[resultKey.msg] as? String) ?? ""
                    
                    guard let _  = status,status! == resultKey.successCode else {
                        throw ResultError.resultError(status ?? -1, msg)
                    }
                }
                
                let path:()->String? = {
                    if let dataPath = self.request.dataKeyPath {
                        return dataPath
                    }
                    return globalConfig.result_key?.data
                }
                
                guard  let result:Result = Result.deserialize(from: value.fetchAsString(),
                                                    designatedPath:path()) else {
                                                        throw ResultError.parseModelError("HandyJSON deserialize error")
                }
                return result
            })
            
            let response = DataResponse(request: value.originResponse.request, response: value.originResponse.response, data: value.originResponse.data, result: newResult)
            
            var newValue = BowlingValue(originResponse: response)
            newValue.status = status
            newValue.msg = msg
            
            if(newValue .isFailure){
                self.failed(newValue.error)
                return
            }
            self.success(newValue.transformData)
            self.finish(newValue)
        }
    }
    
}



public extension BowlingRequestCall where Result:Sequence,Result.Element:HandyJSON{

    func send() {
        
        self.request.buildResponse()?.responseJson {
            value in
            
            var status:Int?
            var msg:String = ""
            
            
            let newResult =  value.result.flatMap({ (jsonObj) -> Result in
                
                if  let resultKey = globalConfig.result_key,let map = jsonObj as? [String:Any?]{
                    
                    status = map[resultKey.code] as? Int
                    
                    msg = (map[resultKey.msg] as? String) ?? ""
                    
                    guard let _  = status,status! == resultKey.successCode else {
                        throw ResultError.resultError(status ?? -1, msg)
                    }
                    
                }
                
                let path:()->String? = {
                    if let dataPath = self.request.dataKeyPath {
                        return dataPath
                    }
                    return globalConfig.result_key?.data
                }
                
                guard  let result:Result =  [Result.Element].deserialize(from: value.fetchAsString(), designatedPath: path()) as? Result else {
                    throw ResultError.parseModelError("HandyJSON deserialize error")
                }
                return result
            })
            
            let response = DataResponse(request: value.originResponse.request, response: value.originResponse.response, data: value.originResponse.data, result: newResult)
            
            var newValue = BowlingValue(originResponse: response)
            newValue.status = status
            newValue.msg = msg
            
            if(newValue .isFailure){
                self.failed(newValue.error)
                return
            }
            self.success(newValue.transformData)
            self.finish(newValue)
    }
}


}

