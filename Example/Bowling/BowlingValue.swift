//
//  BowlingVale.swift
//  Alamofire
//
//  Created by 蔡杰 on 2019/7/17.
//

import Foundation

//// MARK: - Result
public struct BowlingValue<Value> {
  
    internal let originResponse:DataResponse<Value>;
    
    public var msg:String = ""
    
    public var status:Int?
    
    public var request:BowlingRequst!
    
    init(originResponse:DataResponse<Value>) {
       
        self.originResponse = originResponse
    }
}

extension BowlingValue {
    

    public var result: Result<Value>{
        return originResponse.result
    }
     public var response: HTTPURLResponse?{
        return originResponse.response
    }
    public var error: NSError?{
       switch result {
          case .failure(let error):
            return error as NSError
          case .success(_):
           return nil
        }
    }
    
    public var originData: Data? {
        return originResponse.data
    }
    
    public var statusCode: Int {
        return response?.statusCode ?? Int.min
    }
    
    public var header: [AnyHashable : Any] {
        return response?.allHeaderFields ?? [:]
    }
    
}

extension BowlingValue {
    
    public var isSuccess:Bool {
        return self.result.isSuccess
    }
    
    public var isFailure:Bool {
        return self.result.isFailure
    }
    
    public var transformData: Value? {
        switch result {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
}

extension BowlingValue {
    
    public func fetchAsData() -> Data? {
        return originData
    }
    
    public func fetchAsString() -> String? {
        guard let data = self.originData else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func fetchAsJSON() -> Any? {
        guard let data = self.originData else { return nil }
        
        do {
            let result =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return result
        }
        catch {
            
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("JSONSerialization error ---\(dataString)")
            }
        }
        return nil
    }
    
}

//MARK:BowlingResponse Degug Info
extension BowlingValue: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        var dataString: String? = "nil"
        
        dataString = (originData == nil) ? "nil" : String(data: originData!, encoding: .utf8)
        
        return """
        
        ------------------------ BowlingResponse ----------------------
        URL:\(String(describing: originResponse.request?.url))
        \(dataString!)
        error:\(String(describing: error))
        ----------------------------------------------------------
        """
    }
}
