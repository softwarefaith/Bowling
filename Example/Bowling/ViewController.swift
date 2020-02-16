//
//  ViewController.swift
//  Bowling
//
//  Created by softwarefaith@126.com on 07/08/2019.
//  Copyright (c) 2019 softwarefaith@126.com. All rights reserved.
// https://github.com/alibaba/HandyJSON
//

import UIKit

import HandyJSON



struct Model:HandyJSON {
    init() {
       
    }
    
    var name:String!
    var jumpvc:UIViewController.Type!
    init(name:String,vc:UIViewController.Type) {
        self.name = name;
        self.jumpvc=vc
    }
}

class Test{
    
  
//    func onSuccess<T:HandyJSON>(type:T.Type) ->(_ finish:@escaping (T)->(),_ success:@escaping (T)->(),_ fail:@escaping (T)->())->Void{
//        return {_,_,_ in
//
//        }
//    }
    func start(){
        
        
    }
}


protocol ICar {
    
    associatedtype T
    
    func test(jsonString:String)->T?
}

extension ICar where T:HandyJSON{
    func test(jsonString:String)->T?{
        let t = T.deserialize(from: jsonString)
        print(t!)
        return nil
    }
}

extension ICar where T == String{
    func test(jsonString:String)->T?{
        print("String")
        return nil
    }
}

extension ICar where T == Any{
    func test(jsonString:String)->T?{
        print("String")
        return nil
    }
}



extension ICar where T:Sequence,T.Element:HandyJSON {
    func test(jsonString:String)->T? {
    
     let t = [T.Element].deserialize(from: jsonString)
      print(t!)
        return nil
    }
}
class Cat: HandyJSON {
    var name: String?
    var id: String?
    
    required init() {}
}

extension Info:ICar {
  
    
   
    
//    func test() -> [Cat]? {
//        return nil
//    }
    
   

    typealias T = Cat
}






class ViewController: UIViewController {

    var tableView:UITableView!
    var dataList:Array = Array<Model>()
    
    let seriQueue = DispatchQueue(label: "BowlingBatchRequest")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bowling"
        
        
        let customModel = Model(name: "custom", vc: customViewtroller.self)
        self.dataList.append(customModel)
        
//        let chainModel = Model(name: "chain", vc: ChainViewtroller.self)
//        self.dataList.append(chainModel)
//
//        let batchModel = Model(name: "batch", vc: BatchViewtroller.self)
//        self.dataList.append(batchModel)
        
        let downloadModel = Model(name: "download", vc: DownloadViewController.self)
        self.dataList.append(downloadModel)
        
        tableView = UITableView(frame: self.view.bounds, style:.plain)
        tableView.delegate = self;
        tableView.dataSource = self;
        self.view.addSubview(tableView)
        
       
        
       print("====")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ModelCell")
        }
        let model = dataList[indexPath.row]
        cell?.textLabel?.text = model.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
       
        let vc = model.jumpvc.init()
        vc.title = model.name
       self.navigationController!.pushViewController(vc, animated: true)
       
    }
}
