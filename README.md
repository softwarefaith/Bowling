
## 1. 简介
  **Bowling** 是一款基于 [**Alamofire**](https://github.com/Alamofire/Alamofire) 库封装的 **Swift** 版本的网络库,设计过程中借鉴了 [**Moya**](https://github.com/Moya/Moya) 库的部分设计思想, 同时保留 **Alamofire** 库的对外 API 接口,另外我们结合业务内嵌 [**HandyJSON**](https://github.com/alibaba/HandyJSON) 库将 JSON 转化为相应的业务对象  
  
  

### 1.1. 特性

* **灵活**的多服务配置 ( baseURL, Header, ParameterEncoding...)
* 全局配置所有请求的**公共信息** ( serverHost, HTTPHeaderMap... )
* **保留** Alamofire 的对外 API
* 内置**插件** Plugin
* 利用 HanyJSON 将 JSON 转为 Model
* 自定义 网络数据解析
* 支持文件下载

-------

## 2. 快速引入

### 2.1. 系统要求
* iOS 8.0+
* Xcode 10.3+
* Swift 5.0+
* [Alamofire 【~> 4.9.0】](https://github.com/Alamofire/Alamofire) 
* [HandyJSON 【~> 5.0.0】](https://github.com/alibaba/HandyJSON)

### 2.2. 手动安装
下载工程，找到工程内 Bowling 子文件夹的代码以及 Alamofire 库的代码和 HandyJSON 库代码，并将这些源文件添加（拖放）到你的工程中。

### 2.3. CocoaPods
在你工程的 `Podfile` 文件中添加如下一行，并执行 `pod install` 或 `pod update`。

```
pod  待更新
```
注意： `Bowling` 会自动依赖 `Alamofire & HandyJSON` ，所以你工程里的 `Podfile` 文件无需再添加 `Alamofire & HandyJSON`。


-------

## 3. 使用方式

### 3.1 HTTP 请求

#### 3.1.1 头文件的导入
* 如果是通过 `CocoaPods` 安装，则在使用地方
```
import Bowling
```
* 如果是手动下载源码安装，则无需导入直接使用
* 工程全局访问安装：

1. 创建 `工程名-Bridging-Header.h` 文件
2. 通过 `#import<Bowling/Bowling-Swift.h>`引入
  

#### 3.1.2. 全局网络配置

在日常开发中，不同的请求存在一些公共配置信息，比如:域名，请求头，网络日志打印等，为此我们设计了 **Configuration** 单例类，通过修改**Configuration.default** 对象统一配置管理，组件内部**自动组装**，比如

``` Swift
let globalConfig = Configuration.default
globalConfig.serverHost = "server address"
globalConfig.addHTTPHeaders = ["general-header": "general header value"]
globalConfig.dynamicFetchHTTPHeader= {
      ["dynamic-header": 
      "dynamic header value"]
      }
#if DEBUG
globalConfig.openLog = ture
#endif
```
**具体全局网络请求的公共信息**，具体包括如下:
* **serverHost**: 公共服务端地址
* **timeoutInterval**:请求响应时间
* **HTTPHeaderMap**:公共静态请求头, 添加方式 `addHTTPHeader` | `addHTTPHeaders`
* **dynamicFetchHTTPHeader**：公共动态请求头，实时获取最新值,比如：定位经纬度坐标
* **plugins**：公共插件
* **openLog**：用于表示是否在控制台输出请求和响应的信息，默认为 NO



#### 3.2. 网络请求

##### 3.2.1. 自定义请求

全程自定义网络配置，通过实现 **IRequest** 协议，请求实体支持 **struct | enum | class** 三种类型，其中自定义网络实体 协议**至少实现如下三个函数**

``` Swift
var method: HTTPMethod {get} //默认为 get
var path: String {get}
var bodyParameters: Parameters?{get}
```
比如：
定义 requestEntity 遵守  IRequest 协议

``` Swift
class requestEntity {}

extension requestEntity:IRequest           
   //至少实现
   var path: String { return "path"}
   var bodyParameters: Parameters {return ["key":"value"]}
   //method 默认为 .get
   var method: HTTPMethod {return .post}
}
```
通过以下方式发起网络请求：

``` Swift
NetTask<Any>(request: post).onSuccess{ (entity) in   
    //正确实体           
}.onFailure { (error) in
    //错误回调
 }.onCompletion { (response) in
    //网络完成时回调                         
}.start() //start 最终发起网络
```

`IRequest` 协议请求配置，详情见工程 **Request.swift** 文件 

##### 3.2.2. 注意点

1. path 路径开头**不要添加 /**,内部已经拼接,
   比如 
   
``` Swift
path = "post"  
path = "post/post"
```


#### 3.3. 响应

##### 3.3.1. 回调函数


1.多样式回调

网络任务,支持 onSuccess | onFinished | onFailed 链式三种回调，最后调用 start() 函数发送请求


``` Swift
NetTask<Any>(request: post).onSuccess{ (entity) in   
    //正确实体           
}.onFailure { (error) in
    //错误回调
 }.onCompletion { (response) in
    //网络完成时回调                         
}.start() //start 最终发起网络
```

2.对 HandyJSON 支持

通过 `NetTask<T>` 泛型指定需要转换模型类型 ，发起网络任务

``` Swift
class Info: HandyJSON{}

NetTask<Info>(request: post).onSuccess{ (entity) in

     let info = entity.value   
               
}.onCompletion { (response) in

    if  case .success(let entity) = response.result {
        let info = entity.value
    }   
       
}.start()
```
正确结果可以通过以上两种方式难道模型结果

**注意点：**

 `NetTask<T>` 支持类型 **Data** | **String** | **Any(取决于responseParser解析器)** | **T:HandyJson** | **[T：HandJSon]**

3.特殊结构化数据
比如：服务器返回结构化 JSON 格式如下

```
{
    status:0
    data:{} | []
    msg:"错误信息"
}
```

自定义如下类：

``` Swift
enum LogiError:Error {
    case bussinses(Int,String)
}

struct DefaultVerify:IVerify{
    func validate(_ data: Any?) throws -> Bool{
       //校验 status 成功 还是失败【失败可以抛出自定义错误】
       guard let map = data as? [String:Any], let status = map["status"] as? Int else{
            return false
        }
       if status != 0{
            let msg = (map["message"] as? String) ?? ""
            throw LogicError.bussinses(status, msg)
         }
        return true
}

func keyPath() -> String? {
        return "data"
    }
}
```
 DefaultVerify 可以在全局中配置，或者在NetTask 中配置

**注意点**：
1. HandyJSON 解析时，**designatedPath** 设置为 在 KeyPath中配置， 即为 服务器返回 JSON 格式 中 **data**


 
##### 3.3.1. <span id="model">数据模型</span>

数据返回模型为 **GenericResponse<T>**

具体返回类型由 NetTask 指定具体类型

1.成功失败判断： 通过枚举 result 来判断
`public var result: ResponseResult<T>?`
2.成功： case success(ResponseEntity<T>) 
    具体模型在 ResponseEntity 的 value 字段中获取
3.失败： case failure(Error)
4.扩展函数：通过返回原始 Data 数据，转换为 String or JSON

``` Swift
toString()->String
toJsonArray()-> [[String: Any]]
toJsonObject()->[String: Any]
```


#### 3.4. 插件

通过实现 **IPlugin** 协议来拦截请求，具体协议函数如下：

``` Swift
 //表示是否要把当前请求拦截下来
    func willSend<T>(request: IRequest,task:NetTask<T>) -> Bool
    
    func didReceive<T>(request: IRequest,response:GenericResponse<T>)
    
    func afterCompletion<T>(request: IRequest,response:GenericResponse<T>)
```
其中，三个函数提供了默认实现( **willSend 默认返回 true**)，实现类无需全部实现


另外，实现类可以通过 globalConfig 中来配置，也可以配置单个请求的 `plugins` 属性

**注意点**：didReceive | afterCompletion 返回 GenericResponse<T> 泛型结果,获取数据可以**通过原始数据转换**


-------


### 4. 下载

#### 4.1. 任务创建
你可以通过 `defaultDownloadManager.download(downloadUrl)` 构建下载任务 **DownloadTask**，内部自动下载，比如：

```
defaultDownloadManager.download(url: "http://api.gfs100.cn/upload/20171219/201712190944143459.mp4")?
```

或者可以调用 **downloadTaskForURL(downloadUrl)** 构建任务，两者不同的是 需要自己调用 Task.download( )方法

#### 4.2. 任务回调

``` Swift
defaultDownloadManager.download(url: downloadUrl)?
.downloadProgress({ (process) in
   // 下载进度         
}).downloadState({ (state) in
   // 下载状态变更       
}).downloadResponse({ (defaultDownloadResponse) in
    // 结果返回
})
```

#### 4.3. 其他操作

下载任务支持如下操作：

* 取消 `cancel`
* 挂起 `suspend`
* 恢复 `resume`



