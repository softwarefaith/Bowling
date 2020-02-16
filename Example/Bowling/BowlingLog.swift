//
//  BowlingLog.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/8/5.
//

import Foundation


// MARK: - log日志
func BowlingLog<T>( _ message: T, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
    print("----------Log Begin-----")
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
     print("----------Log end-----")
    #endif
}
