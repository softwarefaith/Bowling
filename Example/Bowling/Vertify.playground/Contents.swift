import UIKit



let str1 = "http://www.baidu.com/qwe/2343?key=1"

let str2 = "http.asdbaidu.com"


let str3 = "http://www.baidu.com"


let url1 = URL(string: str1)
url1?.relativePath
url1?.path
url1?.relativeString
url1?.baseURL



public protocol ITest {
    
    var name:String { get}
    
}

public extension ITest {
    var name:String {
        return "ITest"
    }
}






