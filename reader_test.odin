package redis

import "core:fmt"
import "core:testing"

@(test)
TestParseArrayReply :: proc(t: ^testing.T) {
	data: string = "*1\r\n$1\r\na"

	reader := ReaderNew(transmute([]byte)(data))
	rsp, err := reader->ParseRecv()
	defer RespFree(&rsp)
	fmt.printfln("rsp=%v, err=%v", rsp, err)
}
