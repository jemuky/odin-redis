package redis

import "core:fmt"
import "core:log"
import "core:net"
import "core:time"

// 创建一个tcp socket
// create a tcp socket
createSocket :: proc(addr: Addr) -> (soc: net.TCP_Socket, e: Error) {
	localAddr := net.parse_address(addr.ip)
	if localAddr == nil {
		// log.errorf("Failed to parse IP address")
		return 0, .ErrIp
	}
	return net.dial_tcp(localAddr, addr.port)
}

// duration转为redis所需秒
formatSec :: proc(dur: time.Duration) -> i64 {
	if dur > 0 && dur < time.Second do return 1
	return i64(dur / time.Second)
}

// duration转为redis所需毫秒
formatMs :: proc(dur: time.Duration) -> i64 {
	if dur > 0 && dur < time.Millisecond do return 1
	return i64(dur / time.Millisecond)
}

// 合并两个slice
concatSlice :: proc(a, b: []$T) -> []T {
	newSlice := make([]T, len(a) + len(b), allocator = context.temp_allocator)

	i := 0
	for v in a {
		newSlice[i] = v
		i += 1
	}
	for v in b {
		newSlice[i] = v
		i += 1
	}
	return newSlice
}
