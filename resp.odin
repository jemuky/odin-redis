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
Resp_parse_bytes :: proc(data: []byte) -> (Resp, Error) {
	r := Reader_new(data)
	defer Reade_free(r)
	return r->parse_recv()
}

// 按Redis协议解析string
Resp_parse_str :: proc(data: string) -> (Resp, Error) {
	return Resp_parse_bytes(transmute([]byte)data)
}

// 按Redis协议解析数据
Resp_parse :: proc {
	Resp_parse_bytes,
	Resp_parse_str,
}

// 将Resp转为格式化好的string字符串
Resp_to_str :: proc(r: ^Resp) -> string {
	switch &v in r {
	case []byte:
		return fmt.tprintf("\"{}\"", string(v))
	case Maybe(RErr):
		switch &vv in v {
		case RErr:
			return RErr_to_str(&vv)
		case nil:
			return ""
		}
	case string:
		return fmt.tprintf("\"{}\"", v)
	case bool, int, f64:
		return fmt.tprintf("{}", v)
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
			strings.write_string(&sb, Resp_to_str(&vv))
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
			strings.write_string(&sb, Resp_to_str(&vv))
			strings.write_string(&sb, ", ")
		}
		strings.write_string(&sb, "}")
		return strings.to_string(sb)
	}
	return ""
}

// 释放Resp对象
Resp_free :: proc(r: ^Resp) {
	if r == nil do return

	#partial switch &v in r {
	case []byte:
		delete(v)
	case Maybe(RErr):
	case map[string]Resp:
		delete(v)
	case []Resp:
		for &vv in v {
			Resp_free(&vv)
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
