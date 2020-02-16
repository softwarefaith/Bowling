//
//  Response.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/9/20.
//

import Foundation


//MARK: StatusCodeType

public enum StatusCodeType {
    case informational, successful, redirection, clientError, serverError, cancelled, unknown
}

public extension Int {

    var statusCodeType: StatusCodeType {
        switch self {
        case URLError.cancelled.rawValue:
            return .cancelled
        case 100 ..< 200:
            return .informational
        case 200 ..< 300:
            return .successful
        case 300 ..< 400:
            return .redirection
        case 400 ..< 500:
            return .clientError
        case 500 ..< 600:
            return .serverError
        default:
            return .unknown
        }
    }
}

//MARK: protocol IResponse

public protocol IResponse  {
    
    var urlRequest: URLRequest?{get}
    var httpUrlResponse: HTTPURLResponse?{get}
    var error: Error?{get}
    
    init(data: Data?, urlRequest: URLRequest?, httpUrlResponse: HTTPURLResponse?,error:Error?)
    
    
    /// 验证 statusCode 合法性，默认为 200 ..<300
    /// - Parameter response: httpUrlResponse
    static func validate(_ response: URLResponse?) -> Bool
}

/// 默认实现
public extension IResponse {
    
     static func validate(_ response: URLResponse?) -> Bool {

        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        } else {
            return true
        }
    }
}

/// 扩展IResponse协议
public extension IResponse {
    
    /// 若 httpUrlResponse == nil，则 return 0
    var statusCode: Int {
        return httpUrlResponse?.statusCode ?? 0
     }

}


// ----------------------------------

//MARK: ResponseEntity<ContentType>

public struct ResponseEntity<ContentType> {
    
    public var value:ContentType
    

    init(value:ContentType) {
        self.value = value
    }

}

// ----------------------------------

//MARK: ResponseEntity<ContentType>


public enum GenericResult<T,E> {
    case success(T)
    case failure(E)
    
}

public enum ResponseResult<T>{
    
     case success(ResponseEntity<T>)
    
     case failure(Error)
    
     public var description: String {
        switch self {
            case .success(let value):
               return "ResponseResult--Success:\(value)"
            case .failure(let error):
               return "ResponseResult--failuere:\(error)"
        }
    }
    
    public var isSuccess:Bool {
        switch self {
            case .success:
               return true
            case .failure:
               return false
        }
    }
    
    public var isFailure:Bool {
        return !isSuccess
    }
}

// ----------------------------------

//MARK: Response

public class Response:IResponse{
   
    public let  urlRequest: URLRequest?
    public let  httpUrlResponse: HTTPURLResponse?
    public let  data: Data?
    public var  error: Error?
    
    public required  init(data: Data?, urlRequest: URLRequest?, httpUrlResponse: HTTPURLResponse?,error:Error?) {
        self.data = data
        self.httpUrlResponse = httpUrlResponse
        self.urlRequest = urlRequest
        self.error = error
    }
    

   public func toString()->String {
        return String(data: self.data!, encoding: .utf8) ?? ""
    }
  
   public func toJsonObject()->[String: Any] {
        return ((try? JSONSerialization.jsonObject(with: self.data!, options: [])) as? [String: Any]) ?? [String: Any]()
    }
    
   public func toJsonArray()-> [[String: Any]] {
           return ((try? JSONSerialization.jsonObject(with: self.data!, options: [])) as? [[String: Any]]) ?? [[String: Any]]()
    }
}


//MARK: GenericResponse

public protocol IGenericResponse:IResponse{
    
    //转换类型
    associatedtype ResultType
    
    var result:ResponseResult<ResultType>?{get}
    
}

public class GenericResponse<T>:Response&IGenericResponse{
       
    public typealias ResultType = T
    public var result: ResponseResult<T>?
    
    public  init(data: Data?, urlRequest: URLRequest?, httpUrlResponse: HTTPURLResponse?,error:Error?,result: ResponseResult<T>?) {
        super.init(data: data, urlRequest: urlRequest, httpUrlResponse: httpUrlResponse, error: error)
        self.result = result
   }
    
    public override var error: Error? {
        
        set{}
        get {
            switch result {
                case .failure(let error):
                   return error
               default:
                   return nil
            }
        }
    }
    
    public required init(data: Data?, urlRequest: URLRequest?, httpUrlResponse: HTTPURLResponse?, error: Error?) {
        fatalError("init(data:urlRequest:httpUrlResponse:error:) has not been implemented")
    }
}

