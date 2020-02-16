//
//  Task.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/9/18.
//

import Foundation
import HandyJSON

public protocol ITask {
    /// 取消
    func cancel()
    /// 挂起
    func suspend()
    ///恢复
    func resume()
}

public protocol INetTask{
    
    var origRequest:IRequest { get }
    
    var netProvider:INetProvider?{get}
    
    init(request:IRequest);
    
    func start()
}
public protocol IGenericNetTask:INetTask{
    
    associatedtype  ResultType

    @discardableResult
    func onCompletion(_ callback: @escaping (GenericResponse<ResultType>) -> Void) -> Self

    @discardableResult
    func onSuccess(_ callback: @escaping (ResponseEntity<ResultType>) -> Void) -> Self
          
    @discardableResult
    func onFailure(_ callback: @escaping (Error) -> Void) -> Self
    
}



extension INetTask {
    
    public var netProvider:INetProvider?{return  AlamofireProvider.bowlingNetworkingProvider }
}


public enum NetTaskState : Int {
    case  crteated, running, completed,suspended, canceling, waitingFoeConnective
}

/// MARK:NetTask
///common | Generic
open class NetTask<ResultType>:IGenericNetTask{

    public var origRequest: IRequest
    
    public var task:ITask?
    
    open var verify:IVerify?
    
    public var anyTransform = DefaultTransfrom<ResultType>()
    
    private var callbacks = CallbackGroup<GenericResponse<ResultType>>()
    
    open var netProvider: INetProvider? = AlamofireProvider.bowlingNetworkingProvider
    
    public required init(request: IRequest) {
        self.origRequest  = request
        self.verify  = self.origRequest.vertify
        
        if let https =  self.origRequest as? IHTTPS {
            self.netProvider = AlamofireProvider.sharedHTTPS(policies: https.policies)
        }
        
    }
    
    open func onCompletion(_ callback: @escaping (GenericResponse<ResultType>) -> Void) -> Self {
        callbacks.addCallback(callback)
        return self
    }
    
    @discardableResult
    open func onSuccess(_ callback: @escaping (ResponseEntity<ResultType>) -> Void) -> Self {
       return onCompletion { (response) in

            if  case .success(let entity) = response.result {
                    callback(entity)
            }
       }
    }
    @discardableResult
    open func onFailure(_ callback: @escaping (Error) -> Void) -> Self{

        return onCompletion { (response) in
             if  case .failure(let error) = response.result {
                      callback(error)
             }
        }
    }
    @discardableResult
    public func resetVerify(verify:IVerify)-> Self {
        self.verify = verify
        return self
    }
    
    @discardableResult
    public func clearCallbacks()-> Self {
        callbacks.clearCallbacks()
        return self
    }
    
    public func start() {
        print("start()")
//        //是否发起任务
//        let flag = self.origRequest.willSend(request: self.origRequest, task: self)
//        if(flag == false){
//            log("⚠️---已被拦截----\(origRequest.requestLog)")
//        }
//        //任务发起
//        task =  netProvider?.startRequest(origRequest.urlRequest) { (request,response, data, error) in
//                var result:ResponseResult<ResultType>?
//                //网络提供者 error
//                if let err = error {
//                        result = .failure(ResponseError.net(err))
//                } else {
//
//                    do {
//                        var type:ResultType?
//
//                        //二进制数据解析
//                        let paserData = try self.origRequest.responseParser.parse(data: data!)
//                        //数据解析认证
//                        try self.vertifyPaserData(paserData)
//
//                        type =  try self.anyTransform.transform(paserData)
//
//                        if type != nil {
//                            result = .success(ResponseEntity(value: type!))
//                        }else {
//                            result = .failure(ResponseError.emptyObj(messge: "transform func return nil obj[]"))
//                         }
//
//                        } catch let error {
//                            result = .failure(error)
//                        }
//                     }
//                    let response = GenericResponse(data: data, urlRequest: request, httpUrlResponse: response, error: error, result: result)
//
//                    self.origRequest.didReceive(request: self.origRequest, response: response)
//
//                    self.callbacks.exec(response)
//
//                    self.origRequest.afterCompletion(request: self.origRequest, response: response)
//                }
    }


    
    deinit {
        print("NetTask deinit")
    }
    
}

extension NetTask:ITask {
    
    public func cancel() {
        
        task?.cancel()
    }
    
    public func suspend() {
        task?.suspend()
    }
    
    public func resume() {
        task?.resume()
    }
}


extension NetTask {
    
    
    func send(transform:@escaping (Data) throws -> ResultType?){
        
        let flag = self.origRequest.willSend(request: self.origRequest, task: self)
        if(flag == false){
            log("⚠️---已被拦截----\(origRequest.requestLog)")
        }
        
        
        task =  netProvider?.startRequest(origRequest.urlRequest) { (request,response, data, error) in
            var result:ResponseResult<ResultType>?
            if let err = error {
                 result = .failure(ResponseError.net(err))
             } else {
                
                do {
                    let type =  try transform(data!)
                    if type != nil {
                        result = .success(ResponseEntity(value: type!))
                    }else {
                        result = .failure(ResponseError.emptyObj(messge: "transform func return nil obj[]"))
                    }
                    
                } catch let error {
                    result = .failure(error)
                }
             }
            let response = GenericResponse(data: data, urlRequest: request, httpUrlResponse: response, error: error, result: result)
            
            self.origRequest.didReceive(request: self.origRequest, response: response)
            
            self.callbacks.exec(response)
            
            self.origRequest.afterCompletion(request: self.origRequest, response: response)
        }
    }
}


////MARK: --- 泛型判断
extension NetTask where ResultType == Data {

    public func start() {

        
               // print("ResultType == Data")
             self.send { (responseData) -> Data? in
                 return responseData
             }
    }
}

public extension NetTask where ResultType == String{

    func start() {
           //print("ResultType == String")
        self.send { (responseData) -> String? in
            return try StringResponseParser().parse(data: responseData) as? String
        }
    }
}

public extension NetTask where ResultType == Any{
     func start() {
           //print("ResultType == Any")
        self.send { (responseData) -> ResultType? in

        let data =   try self.origRequest.responseParser.parse(data: responseData)
        try self.vertifyPaserData(data)

        return data
        }
     }
}

extension NetTask {
    
    
    func vertifyPaserData(_ data:Any?) throws {
        let isValid = try self.verify?.validate(data)
                       
        if(isValid == false){
            throw ResponseError.validateFail(message: "\(type(of: self.verify))  validate function return false")
         }
    }
    
    
    
}

// JSON: [String:Any]
public extension NetTask where ResultType:HandyJSON{
    func start() {
       // print("ResultType == ResultType:HandyJSON")
        
        self.send { (responseData) -> ResultType? in
           
            let json = try self.origRequest.responseParser.parse(data: responseData)
            
            try self.vertifyPaserData(json)
            
            
            let jsonString:String = try! StringResponseParser().parse(data: responseData) as! String
            
            let result = ResultType.deserialize(from: jsonString, designatedPath: self.verify?.keyPath())
            
            return  result
        }
    }
}
// JSON: [T]
public extension NetTask where ResultType:Sequence,ResultType.Element:HandyJSON{
    func start() {
             self.send { (responseData) -> ResultType? in
                      
             let json = try self.origRequest.responseParser.parse(data: responseData)
                
             try self.vertifyPaserData(json)
                       
             let jsonString:String = try! StringResponseParser().parse(data: responseData) as! String
                       
             let result:ResultType? =  [ResultType.Element].deserialize(from: jsonString, designatedPath: self.verify?.keyPath()) as? ResultType
                       
             return  result
        }
    }
}

