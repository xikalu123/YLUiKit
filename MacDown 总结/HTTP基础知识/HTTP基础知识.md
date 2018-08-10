##HTTP基础知识

###简介

1. HTTP全称为HyperText Transfer Protocol.超文本传输协议.
2. 基于文本的网络协议,目前位于OSI体系结构中的应用层.
3. OSI应用层的7层体系如下(TCP/IP的五层协议将应用层,表示层,会话层合并为应用层,变为5层):![image](./OSI7.png)
4. HTTPS是HTTP协议的安全版本,HTTP协议的数据传输是明文,不安全的.HTTPS使用了SSL/TLS协议进行了加密处理.(RSA加密算法)
5. 不关心传输的细节,主要用来规定客户端和服务端**数据传输格式**.
6. 最初是用来向客户端传输HTML页面的内容.

##HTTP的Request内容分析

先来一张结构图:![image](./HTTPRequest.png)上面主要分为三部分:
**request line**, **header**和**body**.中间的CRLF为换行符.我们以一个实际的http request的请求为例。[baidu我是例子](https://www.baidu.com/s?ie=utf-8&mod=1&isbd=1&isid=006B8C20C5B75727&ie=utf-8&f=8&rsv_bp=0&rsv_idx=1&tn=baidu&wd=iOS)
后续的分析以此请求为基础。

### Request Line

Request Line的结构为：

```
Request-Line   = Method SP Request-URI SP HTTP-Version CRLF
```

 * Method 是我们常见的请求方法，一般为**POST**和**GET**。
 * SP是一个分隔符，一个字节的大小，值为0x20，对应ASCII码中的空格。
 * Request-URI是我们比较熟悉的，情况下抓包可能分为两种。
	1. [schema]:[host]/[path]?[query]  完整的absoluteURI，包含schema和Host。
	2. /[path]?[query]  abs_path，并没有包含Schema和Host，Host移交到Header中。
* 所以上述的Request-Line的文本展示为：  
```
GET /his?wd=&from=pc_web&rf=3&(参数多省略) HTTP/1.1
```

### Header

本质上是一些文本键值对，典型的例子如下：![image](./HTTPHeader.jpg)

* 每个键值对的形式为：key : 空格 Value CRLF.
* 例如上面缺失的Host 就存储在header里面。所有的键值对组合起来构成了完整的header。
* 最后一个键值对后面再跟一个CRLF，等于最后两个CRLF标识header结束。
* 允许开发者添加自己的key，自定义key一般以X开头。比如X-APP-VERSION记录版本号。

### Body

Body里面包含实际的请求数据。 
 
* GET:不存在Body体，Header的最后两个CRLF标志结束。一般请求参数通过Request-URI传递，也就是URI的query string部分。同样是键值对的形式。
* POST:body体一般不为空，body总共有三种形式上传，后面会说。其中部分请求参数可以放在query string中，也可以放在body体中。

##HTTP的Response内容分析

与request的结构类似，将Request Line换成了Status Line。如图：![image](./HTTPResponse.jpg)

###Status Line