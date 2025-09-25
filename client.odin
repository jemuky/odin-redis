package redis

import "core:bytes"
import "core:log"
import "core:mem"
import "core:net"
import "core:time"
import "core:unicode/utf8"

Client :: struct {
	conn: ^Connect,
	addr: Addr,
}

// example:
// clientCreate(&{pool_size = 1, addr = {"127.0.0.1", 6379}})
Client_create :: proc(ip: string = "127.0.0.1", port: int = 6379) -> (c: ^Client, e: Error) {
	soc := create_socket({ip, port}) or_return

	cli := new(Client)
	cli.conn = Connect_new(soc)
	cli.addr = Addr{ip, port}
	return cli, nil
}

// 销毁client实例
Client_destroy :: proc(client: ^Client) {
	Connect_free(client.conn)
	free(client)
}
