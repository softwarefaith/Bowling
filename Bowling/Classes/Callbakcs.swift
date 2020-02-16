//
//  Callbakcs.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/18.
//

import Foundation


/// 返回方式---
public protocol ICallBacks {
    
    associatedtype CompletionType
    associatedtype SuccessType
    associatedtype FailureType
    
    @discardableResult
    func onCompletion(_ callback: @escaping (CompletionType) -> Void) -> Self

    @discardableResult
    func onSuccess(_ callback: @escaping (SuccessType) -> Void) -> Self
          
    @discardableResult
    func onFailure(_ callback: @escaping (FailureType) -> Void) -> Self
}


internal struct CallbackGroup<CallbackArguments> {
    
    private(set) var completedValue: CallbackArguments?
    private var callbacks: [(CallbackArguments) -> Void] = []

    mutating func addCallback(_ callback: @escaping (CallbackArguments) -> Void) {
            callbacks.append(callback)
    }

    func exec(_ arguments: CallbackArguments) {
        for callback in callbacks{
            callback(arguments)
        }
    }

    mutating func execOfCompletion(_ arguments: CallbackArguments) {
        
        precondition(completedValue == nil, "execOfCompletion() already called")

        completedValue = arguments

    
        let snapshot = self
        DispatchQueue.main.async
        { snapshot.exec(arguments) }

        self.clearCallbacks()
    }
    
    mutating func clearCallbacks(){
         callbacks = []
    }
}
