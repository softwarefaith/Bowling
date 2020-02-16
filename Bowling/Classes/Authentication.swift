//
//  Authentication.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/14.
//

import Foundation


public protocol IHTTPS {
    
    
    var policies:[String:ServerTrustPolicy]?{get}
    
}
