//
//  PostViewcontroller.swift
//  Bowling_Example
//
//  Created by 蔡杰 on 2019/7/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Bowling
import HandyJSON


struct TestPost:IRequest{
    
    var path: String = "login"
    var baseURL: String = "http://172.28.84.3:3000"
    var method: HTTPMethod = .post
    var bodyParameters: Parameters? = ["name":"ccjj","age":30]
    
    

}

class PostViewcontroller: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        testPostHandJsonArray()
//        testPostErrorStatus()
    }
    
 
    
}

