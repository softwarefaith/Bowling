//
//  BowlingChainRequest.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/8/6.
//

import Foundation



public class BowlingChainRequest {
    
    public var currentRequest:BowlingRequst? = nil
    
    fileprivate var responseList: [Any?] = []

    typealias nextClosure = (Any?)->BowlingRequst?
    
    fileprivate var nextClosureList:[nextClosure] = []

    fileprivate var finishedTask = 0
    
    fileprivate var count = -1
    
    fileprivate var error:Error? = nil
    
    fileprivate var responseErrors = [Error?]()

    fileprivate let seriQueue = DispatchQueue(label: "BowlingChainRequest")
    
    fileprivate var successCallback: (([Any?]?) -> Void)?
    
    fileprivate var failureCallback:  ((_ error: [Error?]?) -> Void)?
    
    fileprivate var finishedCallback: (([Any?]?,_ error: [Error?]?) -> Void)?
    
    deinit {
        #if DEBUG
        print("BolingChainRequest deinit")
        #endif
    }
    
    public init() {
        
    }
    
    public func onFirst(_ requestClosure: @escaping ()->BowlingRequst) -> Self {
        
        let request =  requestClosure()
        currentRequest = request
        responseList.append(nil)
        responseErrors.append(nil)
        count=count+1
        return self;
    }
    
    public func onNext(requestClosure: @escaping (Any?)->BowlingRequst?) -> Self {
        count=count+1
        nextClosureList.append(requestClosure)
        responseList.append(nil)
        responseErrors.append(nil)
        return self;
    }
    
    public func onSuccess(_ resultCallback: @escaping (Any?) -> Void) -> Self  {
        self.successCallback = resultCallback
        return self
    }
    
    public func onFailure(_ resultCallback: @escaping ([Error?]?) -> Void) -> Self {
        self.failureCallback = resultCallback
        return self
    }
    
    public func onFinished(_ resultCallback: @escaping ([Any?]?,_ error: [Error?]?) -> Void) -> Self {
        self.finishedCallback = resultCallback
        return self
    }
    
    
    public func start() {

        if (count < 0) {
            return;
        }
        if(currentRequest == nil){
            return;
        }
       startCurrenRequest()
    }
    

    fileprivate func startCurrenRequest() {
        
        currentRequest?.responseJson(completion: { result in
            if (!self.onFinished(preResult: result)){
    
                self.startCurrenRequest()
            } else {
                
                if(self.error == nil){
                     self.successCallback?(self.responseList)
                } else {
                     self.failureCallback?(self.responseErrors)
                }
                self.finishedCallback?(self.responseList,self.responseErrors)
            }
            
        })
    }
    
    fileprivate func onFinished(preResult:BowlingValue<Any>) -> Bool {
        
       if(preResult.isFailure) {
            // error
            self.error = preResult.error
            responseErrors[finishedTask] =  preResult.error
            return true
       }
        responseList[finishedTask] = preResult.transformData
        
        if(finishedTask == count) {
            return true
        }
        
        let  next: (Any?)->BowlingRequst? = nextClosureList[self.finishedTask]
        
        // nextRequest 为nil 代表jsons输入不符合一个请求
        let nextRequest = next(preResult.transformData)
        
        self.finishedTask+=1
        if let _ = nextRequest {
            
          
            currentRequest = nextRequest
            return false
        } else {
            self.error = ResultError.otherError("next request is nil")
            responseErrors[finishedTask] =  ResultError.otherError("next request is nil")
            return true
        }
    }
    
    public func stop() {
        currentRequest?.onCancel()
        nextClosureList.removeAll()
        self.failureCallback = nil
        self.successCallback = nil
        self.finishedCallback = nil
    }
}

