//
//  BowlingCall.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/8/5.
//

import Foundation

public protocol BowlingCall:AnyObject {
    
    associatedtype Result
    
    var successCallback: ((Result?) -> Void)? { get set }

    var failureCallback: ((Error?) -> Void)? { get set }
    
    var finishCallback: ((BowlingValue<Result>) -> Void)? { get set }
}
//MARK:链式构建
 extension BowlingCall {

    @discardableResult
    public func onSuccess(_ resultCallback: @escaping (Result?) -> Void) -> Self {
        self.successCallback = resultCallback
        return self
    }
    @discardableResult
    public func onFailed(_ resultCallback: @escaping (Error?) -> Void) -> Self {
        self.failureCallback = resultCallback
        return self
    }
    @discardableResult
    public func onFinished(_ resultCallback: @escaping (BowlingValue<Result>) -> Void) -> Self {
        self.finishCallback = resultCallback
        return self
    }
}

//MARK:闭包执行
internal extension BowlingCall {
    
    func success(_ result: Result?) {
        self.successCallback?(result)
    }
    
    func failed(_ error: Error? = nil) {
        self.failureCallback?(error)
    }
    
    func finish(_ result: BowlingValue<Result>) {
        self.finishCallback?(result)
    }
}

public class BowlingRequestCall<Result>:BowlingCall{
    
    public var successCallback: ((Result?) -> Void)? = nil
    
    public var failureCallback: ((Error?) -> Void)? = nil
    
    public var finishCallback: ((BowlingValue<Result>) -> Void)? = nil
    
    public var request: BowlingRequst!
    
    public init() {
        
    }
    
    public init(request:BowlingRequst){
        self.request = request
    }
    
    //    public init(_ callback: @escaping (BowlingRequestCall<Result>) -> Void) {
    //        self.callback = callback
    //    }
    
//    public func call() {
//      //  callback?(self)
//    }
}
