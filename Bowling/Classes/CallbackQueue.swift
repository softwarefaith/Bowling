//
//  CallbackQueue.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/12.
//

import Foundation

//数据返回 Queue

public enum CallbackQueue {
   
    case main

    case sessionQueue

    case operationQueue(OperationQueue)

    case dispatchQueue(DispatchQueue)

    public func execute(closure: @escaping () -> Void) {
        switch self {
        case .main:
            DispatchQueue.main.async {
                closure()
            }
        case .sessionQueue:
            closure()

        case .operationQueue(let operationQueue):
            operationQueue.addOperation {
                closure()
            }
        case .dispatchQueue(let dispatchQueue):
            dispatchQueue.async {
                closure()
            }
        }
    }
}
