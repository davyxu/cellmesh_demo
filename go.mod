module github.com/davyxu/cellmesh_demo

go 1.12

require (
	github.com/davyxu/cellmesh v0.1.1-0.20190613090701-1f9f8151ec47
	github.com/davyxu/cellnet v0.0.0-20190612112848-4f8cb890a9f8
	github.com/davyxu/golog v0.1.0
	github.com/davyxu/protoplus v0.1.0
	github.com/gogo/protobuf v1.2.1
	github.com/gorilla/websocket v1.4.0
)

// 本地修改cellmesh时使用
// replace github.com/davyxu/cellmesh => ../cellmesh
