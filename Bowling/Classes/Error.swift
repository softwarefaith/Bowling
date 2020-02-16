//
//  Error.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/12.
//

import Foundation


public enum ResponseError: Error {
    ///第三框架返回error
    case  net(Error?)

    case  parse(code: Int?, message: String, object: Any?, underlying: Error?)
    
    case  emptyObj(messge:String)
    
    case  validateFail(message:String)
    
}
