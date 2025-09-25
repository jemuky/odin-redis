package redis

import "core:bufio"
import "core:bytes"

Reader :: struct {
	br:         bytes.Reader,
	rd:         bufio.Reader,
	// 方法
	parse_recv: proc(_: ^Reader) -> (rspData: Resp, rspErr: Error),
	read_line:  proc(r: ^Reader) -> (brsp: []byte, e: Error),
	discard:    proc(r: ^Reader, line: []byte) -> Error,
}

Reader_new :: proc(buf: []byte) -> ^Reader {
	r := new(Reader)

	bs := bytes.reader_init(&r.br, buf)
	bufio.reader_init(&r.rd, bs)

	r.parse_recv = reader_parse_recv
	r.read_line = reader_read_line
	r.discard = reader_discard
	return r
}

Reade_free :: proc(r: ^Reader) {
	bufio.reader_destroy(&r.rd)
	free(r)
}
