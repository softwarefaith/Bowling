//
//  BowlingDownload.swift
//  Bowling
//
//  Created by 蔡杰 on 2019/8/14.
//

import Foundation
import Alamofire



public  class BowlingDownloadManager {
    
   public static let `default` = BowlingDownloadManager()
    /// 下载任务管理
    fileprivate var downloadTasks = [BowlingDownloadTask]()
    
     var complete: ((_ task: BowlingDownloadTask?) -> Void)?
    
    lazy var manager:SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        //最大并发数  10
        configuration.httpMaximumConnectionsPerHost = 10
        return SessionManager(configuration: configuration)
    }()
    
    fileprivate init(){
        NotificationCenter.default.addObserver(self, selector: #selector(taskComplete(notification:)),name: Notification.Name.DownloadTsk.DidComplete, object: nil)
    }
    
   @objc func taskComplete(notification: Notification)  {
        if let info = notification.userInfo, let url = info["downloadUrl"] as? String {
            let task = downloadTaskForURL(url: url)
            task?.state = .Completed
            
            self.complete?(task)
            
            resumeFirstWillResume()
        }
    }
    
}

//MARK: 下载
public extension BowlingDownloadManager {
    
    /// 下载
    @discardableResult
    func download(url: String?) -> BowlingDownloadTask?{
        let task = self.downloadTaskForURL(url: url)
        task?.download()
        return task
    }
    
    /// 下载:不自动下载，需要自己调用 BowlingDownloadTask download() 方法
    @discardableResult
    func downloadTaskForURL(url: String?) -> BowlingDownloadTask? {
        //过滤,避免重复下载
        if let task = self.downloadTasks.filter({ (downloadTask) -> Bool in
            downloadTask.downloadUrl == url
        }).first {
            return task
        }else{
            let downloadTask = BowlingDownloadTask(manager: manager, destinationPath: nil, url: url)
            self.downloadTasks.append(downloadTask)
            return downloadTask
        }
    }
    
}
//MARK: -- suspend | remove | resume
public extension BowlingDownloadManager {
    
   /// 挂起
    func suspend(url: String?) {
        let task = self.downloadTaskForURL(url: url)
        task?.cancel()
    }
   /// 删除
    func remove(url: String) {
        self.removeTaskForURL(url: url)
    }
    
    /// 挂起所有
    func suspendAll() {
        self.downloadTasks = self.downloadTasks.map({ (task) -> BowlingDownloadTask in
            if  task.state == .Cancel || task.state == .Completed {}
            else{
                task.cancel()
            }
            return task
        })
    }
    /// 恢复所有
    func resumeAll(){
        self.downloadTasks = self.downloadTasks.map({ (task) -> BowlingDownloadTask in
            if  task.state == .Download || task.state == .Completed {}
            else{
                task.download()
            }
            return task
        })
    }
    
    /// 删除所有
     func removeAll(urls: Array<String>) {
        urls.forEach { (url) in
            remove(url: url)
        }
    }
    ///下载第一个等待的
    func resumeFirstWillResume() {
        let willTask = self.downloadTasks.first(where: { (downloadTask) -> Bool in
            downloadTask.state == .Wait
        })
        willTask?.download()
    }

}
//MARK: -- 任务状态变更
public extension BowlingDownloadManager {
    ///将所有未下载完成的任务改变为等待下载
    func changeWaitState(completeClose: @escaping (_ task: BowlingDownloadTask?) -> Void) {
        self.complete = completeClose
        //自动下载第一个
        var isDownloadFirst = false
        self.downloadTasks = self.downloadTasks.map({ (downloadTsk) -> BowlingDownloadTask in
            if isDownloadFirst == false {
                if downloadTsk.state == .Download {
                    isDownloadFirst = true
                    return downloadTsk
                }
            }
            if downloadTsk.state == .Completed {}
            else{
                downloadTsk.suspend()
            }
            return downloadTsk
        })
        if isDownloadFirst == false {
            resumeFirstWillResume()
        }
    }
    ///将所有未下载完成的任务改变为正在下载
    func changeDownloadState() {
        self.downloadTasks = self.downloadTasks.map({ (downloadTask) -> BowlingDownloadTask in
            if  downloadTask.state == .Download || downloadTask.state == .Completed{}
            else{
                downloadTask.download()
            }
            return downloadTask
        })
    }
    
    
}

//MARK: -- private
private extension BowlingDownloadManager {
    func removeTaskForURL(url: String)  {
        if let task = self.downloadTasks.filter({ (downloadTask) -> Bool in
            downloadTask.downloadUrl == url
        }).first {
            task.remove()
            if let index = self.downloadTasks.firstIndex( where: { $0.downloadUrl == url}){
                self.downloadTasks.remove(at: index)
            }
        }
    }
}

//MARK:-----------BowlingDownloadTask
/// 下载状态管理
public enum BowlingDownloadState: Int {
    case None = 0        /// 闲置状态
    case Download       /// 开始下载
    case Suspened      /// 暂停下载
    case Cancel        /// 取消下载
    case Wait          /// 等待下载
    case Completed     /// 完成下载
}

public typealias BowlingDownloadStateBlock = (_ state: BowlingDownloadState)-> Void

public typealias BowlingDownloadProgressBlock = (_ progress: Progress)-> Void
public typealias BowlingDownloadResponseBlock = (_ response: DefaultDownloadResponse)-> Void

public  class BowlingDownloadTask {
    
    public  let downloadUrl:String?
    
    ///文件下载路径
    public  let destinationPath:String?
    
    var manager:SessionManager?
    ///下载请求
    private var downloadRequest:DownloadRequest?
    
    ///取消下载时的数据
    var cancelledData: Data?
    
    /// 状态变更
    var stateBlock: BowlingDownloadStateBlock?
    /// 网络下载进度
    var progressBlock:  BowlingDownloadProgressBlock?
    /// 网络结果回调
    var responsBlock:  BowlingDownloadResponseBlock?
    
    /// 下载状态
    public var state: BowlingDownloadState = .None {
        willSet{
            let newState = newValue
            DispatchQueue.main.async {self.stateBlock?(newState)}
        }
        didSet{}
    }
    
    /// 下载进度
    private var progress: Progress? {
        willSet{
            if let progressBlock = self.progressBlock,let newProgress = newValue {
                DispatchQueue.main.async {progressBlock(newProgress)}
            }
        }
        didSet{}
    }
    /// 回调结果
    private var respons: DefaultDownloadResponse? {
        willSet{
            //回调
            if let responsBlock = self.responsBlock,let newProgress = newValue {
                DispatchQueue.main.async {responsBlock(newProgress)}
            }
        }
        didSet{}
    }
    
    init(manager: SessionManager?, destinationPath: String?, url: String? ){
        self.manager = manager
        self.destinationPath = destinationPath
        self.downloadUrl = url
    }
    

    public func download(){
        
        if let resumeData = cancelledData {
            
            let destination = createDestination(destinationPath: destinationPath)
            
            downloadRequest = manager?.download(resumingWith: resumeData, to: destination).downloadProgress(closure: { (process:Progress) in
                //下载进度
                self.progress = process
            }).response(completionHandler: { (defaultResponse) in
                 self.respons = defaultResponse
            })
        } else {
            
            let destination = createDestination(destinationPath: destinationPath)
            if let url = downloadUrl {
                downloadRequest = manager?.download(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, to: destination).response(completionHandler: { [weak self] (defresponse) in
                    // 获取resumeData
                    self?.cancelledData = defresponse.resumeData
                }).downloadProgress(closure: { (progress) in
                    //下载进度
                    self.progress = progress
                }).response(completionHandler: { (defaultResponse) in
                   self.respons = defaultResponse
                })
            }
            
        }
        state = .Download
    }
    
}

public extension BowlingDownloadTask {
    
     func cancel(){
        downloadRequest?.cancel()
        state = .Cancel
    }
    
     func suspend(){
        downloadRequest?.suspend()
        state = .Suspened
    }
    
     func remove(){
        downloadRequest?.cancel()
        state = .None
    }
    
    @discardableResult
    func downloadProgress(_ progress: BowlingDownloadProgressBlock?) -> Self  {
        progressBlock = progress
        return self
    }
    @discardableResult
    func downloadState(_ state: BowlingDownloadStateBlock?) -> Self  {
        stateBlock = state
        return self
    }
    @discardableResult
    func downloadResponse(_ response: BowlingDownloadResponseBlock?) -> Self {
        responsBlock = response
        return self
    }
    
}

extension BowlingDownloadTask {
    
    
    /// 创建文件下载完成的储存位置
    ///
    /// destinationPath = nil 时会在Documents下创建BowlingDownloadTaskFolder文件夹
    ///
    func createDestination(destinationPath: String?) -> DownloadRequest.DownloadFileDestination {
         //下载成功时 会调用此函数
        
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = destinationPath == nil ? documentsURL.appendingPathComponent("BowlingDownloadTaskFolder", isDirectory: true).appendingPathComponent(response.suggestedFilename!) : URL(fileURLWithPath: destinationPath!)
           
            NotificationCenter.default.post(name: Notification.Name.DownloadTsk.DidComplete, object: self, userInfo: ["downloadUrl":self.downloadUrl!]) //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return destination
    }
    
}
