module github.com/davyxu/cellmesh_demo

go 1.12

require (
	github.com/davyxu/cellmesh v0.1.1-0.20190628065349-a255c0e4e086
	github.com/davyxu/cellnet v0.0.0-20190628065413-a644d2409b6d
	github.com/davyxu/golog v0.1.0
	github.com/davyxu/protoplus v0.1.0
	github.com/gogo/protobuf v1.2.1
	github.com/gorilla/websocket v1.4.0
)

// 本地修改cellmesh时使用
// replace github.com/davyxu/cellmesh => ../cellmesh
