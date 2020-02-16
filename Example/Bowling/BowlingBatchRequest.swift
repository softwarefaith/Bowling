//
//  BolingBatchRequest.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/8/6.
//

import Foundation

public class BowlingBatchRequest {
    
    fileprivate var requests: [BowlingRequst] = []
    
    fileprivate var responseList: [Any?] = []
        
    fileprivate var responseErrors: [Error?]? = nil
    
    fileprivate var successCallback: (([Any?]?) -> Void)?
    
    fileprivate var failureCallback:  ((_ error: [Error?]?) -> Void)?
    
    fileprivate var finishedCallback: (([Any?]?,_ error: [Error?]?) -> Void)?


    fileprivate var finishedTask = 0
    lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        operationQueue.isSuspended = true
        return operationQueue
    }()
    
    fileprivate let seriQueue = DispatchQueue(label: "BowlingBatchRequest")
    
    deinit {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = false
        #if DEBUG
         print("BowlingBatchRequest deinit")
        #endif
       

    }
    
    public init(requests: [BowlingRequst], maxConcurrent: Int = 3) {
        self.requests = requests
        self.operationQueue.maxConcurrentOperationCount = maxConcurrent
        
        for req in self.requests {
            _addRequest(req)
        }
    }
    
    fileprivate func _addRequest(_ req: BowlingRequst) {
        operationQueue.addOperation { () -> Void in
            req.responseJson(completion: { (json) -> Void in
                if json.isSuccess{
                    DispatchQueue.main.async(execute: { () -> Void in
                        for case let (index,req) in self.requests.enumerated() {
                            if(req.requestID == json.request.requestID){
                                 self.responseList[index] = json.transformData
                                 break;
                            }
                        }
                        self.finishedTask += 1
                       
                        if self.finishedTask == self.requests.count {
                            
                            self.successCallback?(self.responseList)
                            self.finishedCallback?(self.responseList,self.responseErrors)
                        }
                    })
                    
                } else {
                    
                    for case let (index,req) in self.requests.enumerated() {
                        if(req.requestID == json.request.requestID){
                            self.responseErrors?[index] = json.error
                            break;
                        }
                    }
                    self.stop()
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.failureCallback?(self.responseErrors)
                        self.finishedCallback?(self.responseList,self.responseErrors)
                    })
                    
                }
            })
        }
        responseList.append(nil)
    }
    
    public func addRequest(_ req: BowlingRequst)->Self {
        seriQueue.sync {
            self.requests.append(req)
        }
        
        _addRequest(req)
        return self
    }
    
    public func start() {
        operationQueue.isSuspended = false
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
    
    public func stop() {
        operationQueue.cancelAllOperations()
        for req in self.requests {
            req.onCancel()
        }
        seriQueue.sync {
            self.requests.removeAll()
        }
    }
}
