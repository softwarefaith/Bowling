var express = require('express');
var app = express();
var routes = express.Router();

//设置跨域访问
app.all('*', function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "X-Requested-With");
    res.header("Access-Control-Allow-Methods", "PUT,POST,GET,DELETE,OPTIONS");
    res.header("X-Powered-By", ' 3.2.1');
    res.header("Content-Type", "application/json;charset=utf-8");
    next();
});



var questions = [
    {
        data: 213,
        num: 444,
        age: 12
    },
    {
        data: 456,
        num: 678,
        age: 13
    }];

    var bodyParser = require('body-parser');
    app.use(express.static('public'));
    app.use(bodyParser.json()); // for parsing application/json
    app.use(bodyParser.urlencoded({
         extended: true
    })); 
//写个接口123
// app.get('/123', function (req, res) {
//     console.log(req.body);
//     res.status(200),
//         res.json(questions);
//     // console.log(num++);
// });

app.get("/get", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {}
    tempParams.headers = req.headers
    tempParams.params = req.params
    tempParams.query = req.query
    tempParams.body = req.body

    res.send(JSON.stringify(tempParams))
});

app.post("/post", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {}
    tempParams.headers = req.headers
    tempParams.params = req.params
    tempParams.query = req.query
    tempParams.body = req.body

    res.send(JSON.stringify(tempParams))
});
//
app.post("/postStruct0", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {"status":0,"data":{"name":"postStruct","age":20},"message":""}
    

    res.send(JSON.stringify(tempParams))
});

app.post("/postStruct1", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {"status":1,"data":null,"message":"业务错误"}
    

    res.send(JSON.stringify(tempParams))
});

app.post("/postChain0", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {"status":0,"data":{"name":"postChain0","age":20},"message":""}
    

    res.send(JSON.stringify(tempParams))
});
app.post("/postChain1", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {"status":0,"data":{"name":"postChain1","age":20},"message":""}
    

    res.send(JSON.stringify(tempParams))
});

app.post("/postChain2", function (req, res) {
    console.log(1,req.params);
    console.log(2,req.query);
    console.log(3,req.body);
    console.log(4, req.headers);

    res.append("Access-Control-Allow-Origin", "*");
    let tempParams = {"status":0,"data":{"name":"postChain2","age":20},"message":""}
    

    res.send(JSON.stringify(tempParams))
})

//配置服务端口
var server = app.listen(3000, function () {

    var host = server.address().address;

    var port = server.address().port;

    console.log('Example app listening at http://%s:%s', host, port);
})

// console.log(process.execPath);
// // / 输出当前目录
// console.log('当前目录: ' + process.cwd());

// // 输出当前版本
// console.log('当前版本: ' + process.version);

// // 输出内存使用情况
// // console.log(process.memoryUsage());
// console.log('当前shell的环境变量',process.env);
// console.log('执行脚本的各个参数'+process.argv);