//
//  Alamofile+Extention.swift
//  Bowling_Example
//
//  Created by 蔡杰 on 2019/7/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

extension AFError{
    enum HandyJsonError:Error {
        case parseModelError(String)
    }
}

extension DataRequest {
    
    @discardableResult
    public func responseHandyJsonModel<T: HandyJSON>(type:T.Type, queue:DispatchQueue?=nil,
                            completionHandler:@escaping (DataResponse<T>)->Void)->Self{
        
        return response(
            queue: queue,
            responseSerializer: DataRequest.handyJsonModelResponseSerializer(type: type),
                completionHandler: completionHandler
        )
        
    }
    
    public static func handyJsonModelResponseSerializer<T: HandyJSON>(type: T.Type) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseHandyJsonModel(type: type, response: response, data: data, error: error)
        }
    }
    
}

extension AFRequest {
    public static func serializeResponseHandyJsonModel<T: HandyJSON>(
        type: T.Type,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Result<T>
    {
        guard error == nil else { return .failure(error!) }
        
        guard let validData = data, validData.count > 0 else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
            
          
        }
        
        guard let jsonString = String(data: validData, encoding: .utf8) else {
            return .failure(AFError.responseSerializationFailed(reason: .stringSerializationFailed(encoding: .utf8)))
        }
        
        guard let modelT = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            let error = AFError.HandyJsonError.parseModelError("Parse Model error")
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
        
        return .success(modelT)
    }
}
