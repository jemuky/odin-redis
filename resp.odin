package redis

import "core:fmt"
import "core:math/big"
import "core:strings"

Resp :: union {
	[]byte,
	Maybe(RErr),
	string,
	bool,
	int,
	f64,
	[]Resp,
	map[string]Resp,
	Maybe(big.Int),
}

// 按Redis协议解析[]byte
RespParseBytes :: proc(data: []byte) -> (Resp, Error) {
	r := ReaderNew(data)
	defer ReaderFree(r)
	return r->ParseRecv()
}

// 按Redis协议解析string
RespParseStr :: proc(data: string) -> (Resp, Error) {
	return RespParseBytes(transmute([]byte)data)
}

// 按Redis协议解析数据
RespParse :: proc {
	RespParseBytes,
	RespParseStr,
}

// 将Resp转为格式化好得string字符串
RespToStr :: proc(r: ^Resp) -> string {
	switch &v in r {
	case []byte:
		return string(v)
	case Maybe(RErr):
		switch &vv in v {
		case RErr:
			return RErrToStr(&vv)
		case nil:
			return ""
		}
	case string:
		return v
	case bool, int, f64:
		return fmt.tprint("{}", v)
	case Maybe(big.Int):
		vv := v.(big.Int)
		return big.int_to_string(&vv, allocator = context.temp_allocator) or_else ""
	case []Resp:
		sb: strings.Builder
		if _, err := strings.builder_init(&sb); err != nil {
			return ""
		}
		defer strings.builder_destroy(&sb)

		strings.write_string(&sb, "[")
		for &vv, i in v {
			strings.write_string(&sb, RespToStr(&vv))
			if i < len(v) - 1 {
				strings.write_string(&sb, ", ")
			}
		}
		strings.write_string(&sb, "]")
		return strings.to_string(sb)
	case map[string]Resp:
		sb: strings.Builder
		if _, err := strings.builder_init(&sb); err != nil {
			return ""
		}
		defer strings.builder_destroy(&sb)

		strings.write_string(&sb, "{")
		for k, &vv in v {
			strings.write_string(&sb, k)
			strings.write_string(&sb, ":")
			strings.write_string(&sb, RespToStr(&vv))
			strings.write_string(&sb, ", ")
		}
		strings.write_string(&sb, "}")
		return strings.to_string(sb)
	}
	return ""
}

// 释放Resp对象
RespFree :: proc(r: ^Resp) {
	if r == nil do return

	#partial switch &v in r {
	case []byte:
		delete(v)
	case Maybe(RErr):
	case map[string]Resp:
		delete(v)
	case []Resp:
		for &vv in v {
			RespFree(&vv)
		}
		delete(v)
	case Maybe(big.Int):
		if v != nil {
			#partial switch &i in v {
			case big.Int:
				big.int_destroy(&i)
			}
		}
	case:
	}
}
