//
//  Cache.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/14.
//

import Foundation

public enum CachingLevel {
       case memory
       case memoryAndDisk
       case none
}


public protocol ICache: class {
    var cacheSeconds: Int { get }
    var cacheVersion: UInt64 { get }
}

public extension ICache {
    var cacheVersion: UInt64 { return 0 }
}


public protocol ICacheProvider {
    
}

