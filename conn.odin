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

Connect_new :: proc(soc: net.TCP_Socket) -> ^Connect {
	conn := new(Connect)
	conn.soc = soc
	conn.last_used = time.now()
	return conn
}

Connect_free :: proc(conn: ^Connect) {
	net.close(conn.soc)
	free(conn)
}

Connect_nonblock :: proc(conn: ^Connect) {
	net.set_blocking(conn.soc, false)
	conn.nonblock = true
}

Connect_block :: proc(conn: ^Connect) {
	net.set_blocking(conn.soc, true)
	conn.nonblock = false
}

Connect_send_data :: proc(conn: ^Connect, sendData: []u8) -> (nSend: int, e: Error) {
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
Connect_brecv_data :: proc(conn: ^Connect, bufRecv: []u8) -> (rspData: []u8, e: Error) {
	nRecv := net.recv_tcp(conn.soc, bufRecv) or_return
	return bufRecv[:nRecv], nil
}

// 使用临时分配器创建buffer接收数据
// use temp_allocator to create buffer to receive data
Connect_trecv_data :: proc(conn: ^Connect, len: int = 1024) -> (rspData: []u8, e: Error) {
	bufRecv := make([]byte, len, allocator = context.temp_allocator)
	nRecv := net.recv_tcp(conn.soc, bufRecv) or_return
	return bufRecv[:nRecv], nil
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
Connect_exec_u8_arr :: proc(
	client: ^Client,
	sendData: []u8,
	bufRecv: []u8,
) -> (
	rsp: []u8,
	e: Error,
) {
	// 发送数据
	nSend := Connect_send_data(client.conn, sendData) or_return

	// 接收数据
	return Connect_brecv_data(client.conn, bufRecv)
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
Connect_exec_str :: proc(
	client: ^Client,
	sendData: string,
	bufRecv: []u8,
) -> (
	rsp: []u8,
	e: Error,
) {
	return Connect_exec_u8_arr(client, transmute([]u8)sendData, bufRecv)
}

// 使用temp_allocator, 并将其中的有效数据返回
Connect_texec_u8_arr :: proc(conn: ^Connect, sendData: []u8) -> (rsp: []u8, e: Error) {
	// 发送数据
	nSend := Connect_send_data(conn, sendData) or_return
	// 接收数据
	return Connect_trecv_data(conn)
}

// 使用temp_allocator, 并将其中的有效数据返回
Connect_texec_str :: proc(conn: ^Connect, sendData: string) -> (rsp: []u8, e: Error) {
	return Connect_texec_u8_arr(conn, transmute([]u8)sendData)
}

// 使用bufRecv接收数据, 并将其中的有效数据返回
// 需要自己释放传入的bufRecv
Connect_exec :: proc {
	Connect_exec_u8_arr,
	Connect_exec_str,
}

// 使用temp_allocator, 并将其中的有效数据返回
Connect_texec :: proc {
	Connect_texec_u8_arr,
	Connect_texec_str,
}
