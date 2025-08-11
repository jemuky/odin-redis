package redis

import "core:log"
import "core:net"
import "core:time"

TxPipeliner :: struct {
	buf:        [dynamic]u8,
	// function
	add_cmd:    proc(_: ^TxPipeliner, _: string),
	add_cmd_u8: proc(_: ^TxPipeliner, _: []byte),
	exec:       proc(_: ^TxPipeliner, _: ^Cmdable) -> (Resp, Error),
}
