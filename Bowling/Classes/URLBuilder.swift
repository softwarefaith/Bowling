//
//  URLBuilder.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/10/11.
//

import Foundation

// 主要构建 url
// buidl.child("123").child("details").buildUrlString  -> 
// path -> /123/details
class URLBuilder {

    public enum Behavior {
        case appendingPathComponent
        case relativeToBaseURL
        case custom((_ baseURL: String, _ path: String) -> URL)
    }

    public let baseURLString: String
    
    public var path: String = ""

    public let behavior: Behavior

    public init(baseURL: String, behavior: Behavior = .appendingPathComponent) {
        self.baseURLString = baseURL
        self.behavior = behavior
    }
    
    @discardableResult
    public func child(_ subpath:String) -> URLBuilder {
        path = (path as NSString).appendingPathComponent(subpath)
        return self
    }
    
    public func buildURL()->URL {
        let url: URL?
        switch behavior {
            case .appendingPathComponent: url = URL(string: baseURLString)?.appendingPathComponent(path)
            case .relativeToBaseURL: url = URL(string: path, relativeTo: URL(string: baseURLString))
            case .custom(let closure): url = closure(baseURLString, path)
        }
        return url!
    }
    
    public func buildURLString() -> String {
       return self.buildURL().relativeString
    }

    open func url(forPath path: String) -> URL {
        let url: URL?
        switch behavior {
            case .appendingPathComponent: url = URL(string: baseURLString)?.appendingPathComponent(path)
            case .relativeToBaseURL: url = URL(string: path, relativeTo: URL(string: baseURLString))
            case .custom(let closure): url = closure(baseURLString, path)
        }
        return url ?? NSURL() as URL
    }
}
