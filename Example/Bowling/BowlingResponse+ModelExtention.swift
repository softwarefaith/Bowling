//
//  BowlingResponse+ModelExtention.swift
//  Bowling_Example
//
//  Created by 蔡杰 on 2019/7/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Bowling
import HandyJSON

public struct LogicValue<Type> {

    var error:NSError?
    var value:Type?
    
    init(error:NSError?,value:Type?) {
        self.error = error
        self.value = value
    }
    
    var isSuccess:Bool{
        if let _ = error {
            return false
        }
        return true
    }
}
