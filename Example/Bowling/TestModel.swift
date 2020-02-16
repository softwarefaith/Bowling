//
//  TestModel.swift
//  Bowling_Example
//
//  Created by 蔡杰 on 2019/7/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON
class BaseModel:HandyJSON  {
    var status:Int!
    var message:String?
    required init() {}
    
}

protocol A {

}
protocol B {
    
}
class InfoModel: BaseModel{
      var data:Info?
      required init() {
    
    }
}

class Info: HandyJSON {
    var name:String?
    var age:Int?
    required init() {}
}



