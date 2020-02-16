//
//  ResponsePasrser.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/12.
//

import Foundation

/*
   网络请求返回数据解析协议：
   目前支持： JSONResponseParser
            StringResponseParser
            ProtobufResponseParser
 
 
     全局配置在  struct Configuration，
     也可以单个 request[responseParser] 配置
   
   注意点： contentType 内部未使用
 */

//MARK: IResponsePasrser
public protocol IResponsePasrser {
    
    /// HTTP request. header: Accept ---
    var contentType: String? {get}
        
    /// - Throws: `Error`
    func parse(data: Data) throws -> Any
}

//MARK: JSONResponseParser
public class JSONResponseParser: IResponsePasrser {
    public let readingOptions: JSONSerialization.ReadingOptions

   
    public init(readingOptions: JSONSerialization.ReadingOptions) {
        self.readingOptions = readingOptions
    }

    public var contentType: String? {
        return "application/json"
    }

    /// 解析d data ->  json obj
    /// - Parameter data: Data --  if Data nil 则  return  nil
    public func parse(data: Data) throws -> Any {
        
        return try JSONSerialization.jsonObject(with: data, options: readingOptions)
    }
}

//MARK: StringResponseParser
public class StringResponseParser: IResponsePasrser {
    public enum Error: Swift.Error {
        case invalidData(Data)
    }

    /// The string encoding
    public let encoding: String.Encoding

    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return nil
    }

    /// Return `String` that converted from `Data`.
    public func parse(data: Data) throws -> Any {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.invalidData(data)
        }

        return string
    }
}

//MARK: ProtobufResponseParser
public class ProtobufResponseParser: IResponsePasrser {
  
   
    public init() {}
    
    public var contentType: String? {
        return "application/protobuf"
    }
    
    public func parse(data: Data) throws -> Any {
        return data
    }
}
