[![MIT licensed][11]][12] [![GoDoc][1]][2]

[1]: https://godoc.org/github.com/davyxu/cellmesh_demo?status.svg
[2]: https://godoc.org/github.com/davyxu/cellmesh_demo
[11]: https://img.shields.io/badge/license-MIT-blue.svg
[12]: LICENSE

# cellmesh demo
基于cellmesh框架的游戏服务器demo

# cellmesh服务器框架
   
   本Demo使用的cellmesh框架请参考
   
   https://github.com/davyxu/cellmesh

# 运行Demo

    使用go module管理源码依赖， 所以确保go版本在1.12以上

    请确认cellmesh_demo的工程结构为
    
    任意文件夹\github.com\davyxu\cellmesh_demo
    
## 准备服务发现
    服务发现系统用于记录已经运行的服务的基本信息,如: IP、内网端口、外网端口等。

    服务器发现同时也是一个高性能的KV数据库，可以用于保存配置，实现配置的自动分发。
```    
    # 在cellmesh_demo根目录启动服务器发现 以下shell会自动编译和运行服务发现服务
    go run github.com/davyxu/cellmesh/discovery/memsd -datafile=persist.json
```


## 更新协议及上传路由规则

执行下面指令更新路由规则到服务发现
```
    cd proto
    sh ./MakeProto.sh
```

## 启动demo服务

按照下面shell分别启动login, agent, game, hub 服务
```
    # 在cellmesh_demo根目录启动以下服务

    go run github.com/davyxu/cellmesh_demo/svc/hub

    go run github.com/davyxu/cellmesh_demo/svc/login
    
    go run github.com/davyxu/cellmesh_demo/svc/agent
    
    go run github.com/davyxu/cellmesh_demo/svc/game
```

确认服务器启动完成后，启动模拟客户端
```
    go run github.com/davyxu/cellmesh_demo/svc/client
```

启动client后,可在命令行中输入文字作为聊天内容发送

# 概念

## Service（服务）

一个Service为一套连接器或侦听器，挂接消息处理的派发器Dispatcher

- 侦听端口自动分配

  Service默认启动时以地址:0启动，网络底层自动分配端口，由cellmesh将服务信息报告到服务发现

  其他Service发现新的服务进入网络时，根据需要自动连接服务


## Agent（网关）

frontend(前端)

与客户端连接的前端通信的侦听器

- 使用心跳+底层断开通知确认User断开

- 客户端断开时通知后台服务器(ClientClosedACK消息)

backend(后端)

与后台服务器通信的侦听器

- 后台认证

  后台服务通过BindBackendACK消息,将后台连接与客户端绑定,客户端固定将对应消息发送到绑定的后台服务器.

- 后台断线重连

  后台服务断开重连时，自动维护连接，保证客户端正常收发后台消息

routerule(路由规则)

在proto文件中,消息的RouteRule属性描述如何路由消息到指定的后台服务器

- 阻断(不填写RouteRule)

   消息被路由阻断,无法发送到后台服务器

- 通透(RouteRule=pass)

  消息始终被路由到后台服务器

- 后台认证(RouteRule=auth)

  消息需要后台认证后才可被路由


## Connection Management（连接维护）

从服务发现的服务信息，创建到不同服务间的长连接。同时在这些连接断开时维护连接

逻辑中根据策略从已有连接及信息选择出连接与目标通信，例如：选择负载最低的一台游戏服务器

# 目录结构
```
demo
   basefx
     项目专有框架封装，不跨项目共享
   cfg
     开发阶段的快速配置
   proto
     协议文件，协议生成代码。
   svc
     login
       登录，用户的固定接入入口，通过login拿到agent地址，让用户连接到agent（做了一个负载均衡的简易策略，获取人数最少的agent）。
     agent
       代理，可以启动多个，agent后面有挂载的服务，如game。
     hub
       中心服务，各服务的状态，通过发布和订阅的形式，由hub做中转共享，如在线人数等。
     game
       业务逻辑服务，处理通过agent转发过来的协议。
tool   
   routegen
      路由配置生成器。生成的配置可由agent动态读取并更新路由规则。
util
   所有框架通用的工具代码。
```

# demo工程架构
![arch](doc/architecture.png)

- login

    登录服, 短连接获取服务器列表及平台验证, 通过JWT生成token交由客户端

- game

    养成服, 网关后负责养成逻辑,使用客户端上传的JWT token验证客户端身份

- agent

    网关, 负责与客户端保持长连接,通过心跳处理客户端连接生命期, 客户端消息转发

- hub

    中转, 处理服务器人数负载, 使用模式为订阅分发模式,处理跨服通知

- client

    模拟客户端, 模拟客户端逻辑


# 开发进度
- [x] 基于Consul的服务发现及Watch机制
- [x] 网关基本逻辑
- [x] 带服务发现的连接器,侦听器
- [x] 网关会话绑定
- [x] 服务发现Consul的KV封装
- [x] 网关路由规则生成,上传和下载
- [x] 系统消息响应入口
- [x] 网关广播
- [x] 网关心跳处理
- [x] 频道订阅发布hub
- [x] 服务在线人数更新及连接选择
- [x] 支持WebSocket网关及登录协议
- [ ] 登录服务器，JWT验证
- [ ] 玩家数据读取
- [ ] 游戏服务器，成长逻辑，花钱升级等级
- [ ] 社交服务器，聊天逻辑
- [ ] 机器人

# 参考及使用建议
由于本框架尚在开发中,demo在不断完善添加新功能. 因此响应的接口和设计会经常性发生变化.


# Tips
## 为什么使用memsd的服务发现替换consul？
早期版本的cellmesh使用consul作为服务发现，cellmesh使用主动汇报服务信息的方式保证consul中能及时更新服务信息。
但实际使用中发现有如下问题：
1. 偶尔出现高CPU占用，Windows休眠恢复后也会造成严重的高CPU现象。
2. consul的API并没有本地cache，需要高速查询时，并没有很好的性能。
3. 多服更新时没有原子更新，容易形成严重的不同步现象。
4. 依赖重，代码量巨大，使用vendor而不是go module方式管理代码，编译慢。
基于以上考虑，决定兼容服务发现接口，同时编写对游戏服务友好的发现系统：memsd。



友情提示：
    demo工程仅是随框架附带的实例代码，建议将demo为蓝本建立自己的工程蓝本。


# 备注

感觉不错请star, 谢谢!

开源讨论群: 527430600 验证请发cellmesh demo

知乎: http://www.zhihu.com/people/sunicdavy

提交bug及特性: https://github.com/davyxu/cellmesh/issues
