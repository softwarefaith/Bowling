//
//  NetwokingRequest.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/12.
//

import Foundation

public extension IRequest {
    func buildNetTask<T>(type:T.Type)-> NetTask<T> {
        return NetTask<T>(request: self)
    }
}
