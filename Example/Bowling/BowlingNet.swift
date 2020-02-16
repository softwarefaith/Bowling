//
//  BowlingNet.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/7/16.
//

import Foundation

//let globalConfig = BowlingGlobalConfig.default



public  class  BowlingNet {
    
}

public var globalConfig: BowlingGlobalConfig {
      return BowlingGlobalConfig.default
}

@discardableResult
public func post(path: String,
                        parameters: Parameters? = nil )->BowlingDefaultRequst{
    
    let post = BowlingDefaultRequst(method: .post,path: path,parameters: parameters)
    return post
}

extension BowlingNet{
    
    @discardableResult
    public static func get(path: String,parameters: Parameters? = nil)->BowlingDefaultRequst{
        let get = BowlingDefaultRequst(method: .get,path: path,parameters: parameters)
        return get
    }
    
    @discardableResult
    public static func post(path: String,
                            parameters: Parameters? = nil )->BowlingDefaultRequst{
        
        let post = BowlingDefaultRequst(method: .post,path: path,parameters: parameters)
        return post
    }
    
    @discardableResult
    public static func put(path: String,parameters: Parameters? = nil)->BowlingDefaultRequst{
        let get = BowlingDefaultRequst(method: .put,path: path,parameters: parameters)
        return get
    }
    
    @discardableResult
    public static func delete(path: String,
                            parameters: Parameters? = nil )->BowlingDefaultRequst{
        
        let post = BowlingDefaultRequst(method: .delete,path: path,parameters: parameters)
        return post
    }
}


extension BowlingNet {
    
    public static func cancelRequest(method:HTTPMethod!,url:String!){
        defaultManager.cancelRequest(method: method, url: url)
    }
}
