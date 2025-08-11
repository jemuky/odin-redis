package redis

import "core:bufio"
import "core:bytes"
import "core:log"
import "core:net"
import "core:time"

Connect :: struct {
	soc:       net.TCP_Socket, // 连接socket
	last_used: time.Time, // 上次使用时间
	nonblock:  bool, // 是否使用非阻塞io
}

ConnectNew :: proc(soc: net.TCP_Socket) -> ^Connect {
	conn := new(Connect)
	conn.soc = soc
	conn.last_used = time.now()
	return conn
}

ConnectFree :: proc(conn: ^Connect) {
	net.close(conn.soc)
	free(conn)
}

ConnectNonblock :: proc(conn: ^Connect) {
	net.set_blocking(conn.soc, false)
	conn.nonblock = true
}

ConnectBlock :: proc(conn: ^Connect) {
	net.set_blocking(conn.soc, true)
	conn.nonblock = false
}

ConnectSendData :: proc(conn: ^Connect, sendData: []u8) -> (nSend: int, e: Error) {
	// 发送数据
	// log.debugf("sendData=%s", sendData)
	buf: bytes.Buffer
	bytes.buffer_init(&buf, sendData)
	defer bytes.buffer_destroy(&buf)

	bytes.buffer_write(&buf, []u8{'\r', '\n'})
	return net.send_tcp(conn.soc, bytes.buffer_to_bytes(&buf))
}

// 使用buffer接收数据
// use buffer to receive data
ConnectBRecvData :: proc(conn: ^Connect, bufRecv: []u8) -> (rspData: []u8, e: Error) {
	nRecv := net.recv_tcp(conn.soc, bufRecv) or_return
	return bufRecv[:nRecv], nil
}

// 使用临时分配器创建buffer接收数据
// use temp_allocator to create buffer to receive data
ConnectTRecvData :: proc(conn: ^Connect, len: int = 1024) -> (rspData: []u8, e: Error) {
	bufRecv := make([]byte, len, allocator = context.temp_allocator)
	nRecv := net.recv_tcp(conn.soc, bufRecv) or_return
	return bufRecv[:nRecv], nil
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
ConnectExecU8Arr :: proc(client: ^Client, sendData: []u8, bufRecv: []u8) -> (rsp: []u8, e: Error) {
	// 发送数据
	nSend := ConnectSendData(client.conn, sendData) or_return

	// 接收数据
	return ConnectBRecvData(client.conn, bufRecv)
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
ConnectExecU8Str :: proc(
	client: ^Client,
	sendData: string,
	bufRecv: []u8,
) -> (
	rsp: []u8,
	e: Error,
) {
	return ConnectExecU8Arr(client, transmute([]u8)sendData, bufRecv)
}

// 使用temp_allocator, 并将其中的有效数据返回
ConnectTExecU8Arr :: proc(conn: ^Connect, sendData: []u8) -> (rsp: []u8, e: Error) {
	// 发送数据
	nSend := ConnectSendData(conn, sendData) or_return
	// 接收数据
	return ConnectTRecvData(conn)
}

// 使用temp_allocator, 并将其中的有效数据返回
ConnectTExecU8Str :: proc(conn: ^Connect, sendData: string) -> (rsp: []u8, e: Error) {
	return ConnectTExecU8Arr(conn, transmute([]u8)sendData)
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
ConnectExec :: proc {
	ConnectExecU8Arr,
	ConnectExecU8Str,
}

// 使用temp_allocator, 并将其中的有效数据返回
ConnectTExec :: proc {
	ConnectTExecU8Arr,
	ConnectTExecU8Str,
}
