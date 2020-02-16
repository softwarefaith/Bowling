//
//  Transformer.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/14.
//

import Foundation

public protocol IVerify {
    func keyPath()-> String?
    
    /// 验证服务器返回数据
    /// - Parameter data: data 类型取决于 paser解析器
    func validate(_ data:Any?) throws ->Bool
}

extension IVerify {
    
    public  func keyPath()-> String? {
        return nil
    }
}

public protocol ITransform {
   
    associatedtype Obj
    
    func transform(_ data:Any?) throws ->Obj
}



public class AnyTransform<T>: ITransform {
    
    private var transformFunc: (_ data:Any?) throws -> T
    
    init<Inject: ITransform>(_ obj: Inject) where Inject.Obj == T {
        transformFunc = obj.transform
    }
                   
   public func transform(_ data:Any?) throws -> T {
        return try transformFunc(data)
    }
}
public extension AnyTransform where T == String{

     func transform(_ data: Any?) throws -> String {
        
        print("DefaultTransfrom where T == Any")
        
        return try transformFunc(data)
    }
}


public class DefaultTransfrom<T>:ITransform{
   
   public typealias Obj = T

    public func transform(_ data: Any?) throws -> Obj {

        print("DefaultTransfrom----")
        return "" as! T
    }

}

 extension DefaultTransfrom where T == String{

      public func transform(_ data: Any?) throws -> Obj {

        print("DefaultTransfrom where T == String")

        return ""
    }
}
//


