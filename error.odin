package redis

import "core:fmt"
import "core:io"
import "core:math/big"
import "core:mem"
import "core:net"
import "core:slice"
import "core:strings"

// 与其他错误的联合
Error :: union #shared_nil {
	ClientError,
	Maybe(RErr),
	net.Network_Error,
	net.TCP_Send_Error,
	net.TCP_Recv_Error,
	mem.Allocator_Error,
	big.Error,
	io.Error,
}

// 客户端错误
ClientError :: enum {
	ErrIp, // 错误的ip
}

// redis 错误
RErr :: struct {
	code: i32,
	msg:  string,
}

// 将RErr转为字符串格式以供打印
RErr_to_str :: proc(err: ^RErr) -> string {
	return fmt.tprintf("{{code: {}, msg: {:s}}}", err.code, err.msg)
}

// 从string生成新的RErr
RErr_from_str :: proc(msg: string) -> Maybe(RErr) {
	return RErr{-1, msg}
}

// 从Error生成新的RErr
RErr_from_error :: proc(err: Error) -> Maybe(RErr) {
	return RErr{-1, fmt.tprintf("{}", err)}
}

// 比较两个RErr是否相同
RErr_eq_other :: proc(self, other: ^RErr) -> bool {
	return self.code == other.code && self.msg == other.msg
}

// 比较两个Maybe(RErr)是否相同
RErr_eq_Maybe :: proc(a, b: Maybe(RErr)) -> bool {
	ae, oka := a.(RErr)
	be, okb := b.(RErr)
	return oka && okb && ae.code == be.code && ae.msg == be.msg
}

// 比较两个RErr是否相同
RErr_eq :: proc {
	RErr_eq_other,
	RErr_eq_Maybe,
}

// 从原RErr附加额外错误信息新建RErr
RErr_attach :: proc(err: ^RErr, data: any) -> Maybe(RErr) {
	return RErr{err.code, fmt.tprintf("%s: %q", err.msg, data)}
}

RErrNil: Maybe(RErr) = RErr{-1, "redis: nil"}
RErrDataLen: Maybe(RErr) = RErr{-2, "redis: error data len"}
RErrInvalidReply: Maybe(RErr) = RErr{-3, "redis: invalid reply"}
RErrInvalidLine: Maybe(RErr) = RErr{-4, "redis: invalid line"}
RErrParseData: Maybe(RErr) = RErr{-11, "redis: error converting data"}
RErrParseNumber: Maybe(RErr) = RErr{-12, "redis: error converting number"}
RErrParseVerbatim: Maybe(RErr) = RErr{-13, "redis: can't convert verbatim string"}
