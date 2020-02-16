//
//  BowlingInterceptor.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/7/24.
//

import Foundation


///  拦截器协议
public protocol BowlingInterceptor{
    
    //表示是否要把当前请求拦截下来
    func willSend(request: BowlingRequst) -> Bool
    
    func didReceive<T>(request: BowlingRequst,resultValue:BowlingValue<T>)
    
    func afterCompletion<T>(request: BowlingRequst,resultValue:BowlingValue<T>)
}

public extension BowlingInterceptor {
    
    func willSend(request: BowlingRequst) -> Bool{
        return true
    }
    func didReceive<T>(request: BowlingRequst,resultValue:BowlingValue<T>){
        
    }
    func afterCompletion<T>(request: BowlingRequst,resultValue:BowlingValue<T>){
        
    }
}
