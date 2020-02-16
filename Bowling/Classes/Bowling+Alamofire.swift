//
//  Bowling+Alamofire.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/7/8.
//

import Foundation
import Alamofire

/*
    Bowling Module Bridge to Alamofire
 */

public typealias SessionManager = Alamofire.SessionManager
public typealias URLRequestConvertible = Alamofire.URLRequestConvertible

public typealias AFRequest = Alamofire.Request
public typealias DownloadRequest = Alamofire.DownloadRequest
public typealias UploadRequest = Alamofire.UploadRequest
public typealias DataRequest = Alamofire.DataRequest
public typealias DataResponse = Alamofire.DataResponse
public typealias SessionDelegate = Alamofire.SessionDelegate
public typealias MultipartFormDataEncodingResult = SessionManager.MultipartFormDataEncodingResult
public typealias AFError = Alamofire.AFError

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias Parameters = Alamofire.Parameters

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding
public typealias PropertyListEncoding = Alamofire.PropertyListEncoding


public typealias Result = Alamofire.Result

public typealias DownloadOptions = Alamofire.DownloadRequest.DownloadOptions
public typealias MultipartFormData = Alamofire.MultipartFormData

public typealias ServerTrustPolicyManager = Alamofire.ServerTrustPolicyManager
public typealias ServerTrustPolicy = Alamofire.ServerTrustPolicy

public typealias NetworkReachabilityManager = Alamofire.NetworkReachabilityManager
public typealias Listener = Alamofire.NetworkReachabilityManager.Listener
