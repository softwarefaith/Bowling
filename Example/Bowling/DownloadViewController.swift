//
//  DownloadViewController.swift
//  _Example
//
//  Created by 蔡杰 on 2019/8/14.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Alamofire
import  Bowling

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height




class DownloadViewController: BaseViewController {
    
    var downloadUrls = [
        "http://api.gfs100.cn/upload/20180201/201802011423168057.mp4",
        "http://api.gfs100.cn/upload/20180131/201801311435101664.mp4",
                        "http://api.gfs100.cn/upload/20180131/201801311059389211.mp4",
                        "http://api.gfs100.cn/upload/20171219/201712190944143459.mp4"]
    
    let tableView: UITableView = {
        let tabv = UITableView(frame: CGRect.zero, style: .plain)
        tabv.rowHeight = 80
        return tabv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-60)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DownloadProgressCell.self, forCellReuseIdentifier: "DownloadProgressCell")
        self.view.addSubview(tableView)
        
        
        defaultDownloadManager.download(url: "http://api.gfs100.cn/upload/20171219/201712190944143459.mp4")?.downloadProgress({ (process) in
            
        }).downloadState({ (state) in
            
        }).downloadResponse({ (defaultDownloadResponse) in
            
        })
        
    }

}

extension DownloadViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return downloadUrls.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Identifier = "DownloadProgressCell\(indexPath.row)"
        if  let cell  = tableView.dequeueReusableCell(withIdentifier: Identifier) as? DownloadProgressCell {
            cell.downloadurl = downloadUrls[indexPath.row]
            return   cell
        }else{
            tableView.register(DownloadProgressCell.self, forCellReuseIdentifier: Identifier)
            let cell  = tableView.dequeueReusableCell(withIdentifier: Identifier) as! DownloadProgressCell
            cell.downloadurl = downloadUrls[indexPath.row]
            return   cell
        }
    }
    
    
    
    
}

class DownloadProgressCell: UITableViewCell {
    
    
    var downloadurl: String?{
        didSet {
            self.fileNameLab.text = (downloadurl! as NSString).lastPathComponent
            let info = DownloadManager.default.downloadTaskForURL(url: downloadurl)
            parseDownloadInfo(info: info)
        }
    }
    
    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.tintColor = UIColor.black
        view.progress = 0
        return view
        
    }()
    
    let fileNameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black
        return lab
    }()
    
    let downloadBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        btn.setTitle("下载", for: .normal)
        return btn
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        fileNameLab.frame = CGRect(x: 10, y: (80-50)/2, width: ScreenWidth-100, height: 30)
        progressView.frame = CGRect(x: 10, y: 60, width: ScreenWidth-100, height: 10)
        downloadBtn.frame = CGRect(x: ScreenWidth-70, y: (80-50)/2, width: 50, height: 50)
        downloadBtn.backgroundColor = .red
        downloadBtn.addTarget(self, action: #selector(DownloadProgressCell.didDownloadBtn), for: .touchUpInside)
        self.addSubview(fileNameLab)
        self.addSubview(progressView)
        self.addSubview(downloadBtn)
    }
   @objc func didDownloadBtn()  {
    let info = DownloadManager.default.downloadTaskForURL(url: self.downloadurl)
        if info?.state == .Download {
            defaultDownloadManager.suspend(url: self.downloadurl)
        }else if  info?.state == .Cancel || info?.state ==  .None  {
            defaultDownloadManager.download(url: self.downloadurl)
        }else if  info?.state ==  .Wait  {
            defaultDownloadManager.download(url: self.downloadurl)
        } else if info?.state == .Completed{
            
            
        }
    }
    func parseDownloadInfo(info: DownloadTask?) {
        
        info?.downloadProgress({ (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            self.progressView.progress = (completed/total)
        })
        info?.downloadState{ [weak self] state in
            self?.parseDownloadState(state: state)
        }
        self.parseDownloadState(state: info?.state)
    }
    func parseDownloadState(state: DownloadState?)  {
        if state ==  .Download {
            self.downloadBtn.setImage(UIImage(named: "pause"), for: .normal)
        }else if  state ==  .Cancel || state ==  .None  {
            self.downloadBtn.setImage(UIImage(named: "download"), for: .normal)
        }else if  state ==  .Wait  {
            self.downloadBtn.setImage(UIImage(named: "clock"), for: .normal)
        }else if  state ==  .Completed  {
            self.downloadBtn.setImage(UIImage(named: "check"), for: .normal)
        }
    }
}
