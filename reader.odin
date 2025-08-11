package redis

import "core:bufio"
import "core:bytes"

Reader :: struct {
	br:        bytes.Reader,
	rd:        bufio.Reader,
	// 方法
	ParseRecv: proc(_: ^Reader) -> (rspData: Resp, rspErr: Error),
	ReadLine:  proc(r: ^Reader) -> (brsp: []byte, e: Error),
	Discard:   proc(r: ^Reader, line: []byte) -> Error,
}

ReaderNew :: proc(buf: []byte) -> ^Reader {
	r := new(Reader)

	bs := bytes.reader_init(&r.br, buf)
	bufio.reader_init(&r.rd, bs)

	r.ParseRecv = readerParseRecv
	r.ReadLine = readerReadLine
	r.Discard = readerDiscard
	return r
}

ReaderFree :: proc(r: ^Reader) {
	bufio.reader_destroy(&r.rd)
	free(r)
}
