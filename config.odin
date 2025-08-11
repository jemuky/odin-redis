package redis

Addr :: struct {
	ip:   string `fmt:"s"`,
	port: int `fmt:"d"`,
}

AddrNew :: proc(ip: string = "127.0.0.1", port: int = 6379) -> ^Addr {
	addr := new(Addr)
	addr.ip = ip
	addr.port = port
	return addr
}

AddrFree :: proc(addr: ^Addr) {
	free(addr)
}
