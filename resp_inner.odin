#+private

package redis

import "core:bufio"
import "core:bytes"
import "core:log"
import "core:math"
import "core:math/big"
import "core:slice"
import "core:strconv"
import "core:strings"

// 处理redis收到的消息
// deal with the message that receives from redis
// 使用聚合类型RResp，因为any可能会触发 `Assertion Failure: is_type_string(original_type) ` 问题
reader_parse_recv :: proc(r: ^Reader) -> (rspData: Resp, rspErr: Error) {
	line := r->read_line() or_return

	// log.infof("line={:s}", line)

	switch line[0] {
	case RespStatus:
		// string
		// 简单字符串, 整数
		return strings.clone_from_bytes(line[1:], allocator = context.temp_allocator)
	case RespInt:
		// int
		n, ok := strconv.parse_int(string(line[1:]))
		if !ok do return nil, RErrParseNumber
		return n, nil
	case RespFloat:
		// f64
		return parse_float_reply(line)
	case RespBool:
		// bool
		return parse_bool_reply(line), nil
	case RespBigInt:
		// Maybe(big.Int)，需要自己销毁
		return parse_bigint_reply(line)
	case RespVerbatim:
		// string
		return parse_verb_reply(r, line)
	case RespError:
		return nil, parse_err_reply(line)
	case RespNil:
		return nil, RErrNil
	case RespBlobError:
		blobErr := parse_string_reply(r, line) or_return
		return nil, RErr_from_str(blobErr)
	case RespString:
		// 批量字符串
		return parse_string_reply(r, line)
	// case RespAttr:
	// attr
	// return parseStringReply(data)
	case RespArray, RespSet, RespPush:
		// 数组
		return parse_array_reply(r, line)
	case RespMap:
		// map
		return parse_map_reply(r, line)
	case:
		log.debugf("err msg format, data=%s", line)
	}

	return nil, RErr_attach(&RErrParseData.(RErr), line)
}

parse_err_reply :: proc(data: []u8) -> Maybe(RErr) {
	e, err := strings.clone_from(data[1:], allocator = context.temp_allocator)
	if err != nil {
		return RErr_from_error(err)
	}
	return RErr_from_str(e)
}

parse_string_reply :: proc(r: ^Reader, line: []byte) -> (s: string, e: Error) {
	n := reply_len(line) or_return
	b := make([]byte, n + 2)
	defer delete(b)

	bufio.reader_read(&r.rd, b) or_return

	return strings.clone_from_bytes(b[:n], allocator = context.temp_allocator)
}

parse_float_reply :: proc(line: []byte) -> (f64, Maybe(RErr)) {
	switch transmute(string)(bytes.trim_right_space(line[1:])) {
	case "inf":
		return math.inf_f64(1), nil
	case "-inf":
		return math.inf_f64(-1), nil
	case "nan", "-nan":
		return math.nan_f64(), nil
	case:
		n, ok := strconv.parse_f64(transmute(string)line)
		if !ok do return 0, RErrParseNumber
		return n, nil
	}
}

parse_bool_reply :: proc(line: []byte) -> bool {
	switch line[1] {
	case 't':
		return true
	case 'f':
		return false
	case:
		return false
	}
}

// 转为BigInt，需要自己destroy
// convert to BigInt, you have to destroy by yourself
parse_bigint_reply :: proc(line: []byte) -> (Maybe(big.Int), Error) {
	n := big.Int{}
	if err := big.int_atoi(&n, string(bytes.trim_right_space(line[1:]))); err != nil {
		return nil, err
	}
	return n, nil
}

parse_verb_reply :: proc(r: ^Reader, line: []byte) -> (rsp: string, err: Error) {
	s := parse_string_reply(r, line) or_return
	if len(s) < 4 || s[3] != ':' {
		return "", RErrParseVerbatim
	}
	return s[4:], nil
}

parse_array_reply :: proc(r: ^Reader, line: []byte) -> (rsp: []Resp, e: Error) {
	n := reply_len(line) or_return

	// log.infof("arrlen={}", n)

	rsp = make([]Resp, n)
	for i in 0 ..< n {
		v, errRecv := r->parse_recv()
		if errRecv != nil {
			// log.errorf("arr errRecv={}", errRecv)

			errR, ok := errRecv.(Maybe(RErr))
			if !ok do return nil, errRecv

			if RErr_eq(errR, RErrNil) {
				rsp[i] = nil
				continue
			}
			rsp[i] = errR
			continue
		}

		// log.infof("arr v={}", v)
		rsp[i] = v
	}

	return rsp, nil
}

reader_read_line :: proc(r: ^Reader) -> (brsp: []byte, e: Error) {
	line := read_line(r) or_return

	switch line[0] {
	case RespError:
		return nil, parse_err_reply(line)
	case RespNil:
		return nil, RErrNil
	case RespBlobError:
		errBlob, errR := parse_string_reply(r, line)
		if errR == nil {
			errR = RErr_from_str(errBlob)
		}
		return nil, errR
	case RespAttr:
		r->discard(line) or_return
		return r->read_line()
	}

	// isnil
	if is_nil_reply(line) do return nil, RErrNil
	return line, nil
}

reader_discard :: proc(r: ^Reader, line: []byte) -> Error {
	if len(line) == 0 do return RErrInvalidLine
	switch line[0] {
	case RespStatus, RespError, RespInt, RespNil, RespFloat, RespBool, RespBigInt:
		return nil
	}

	n, errLen := reply_len(line)
	if errLen != nil && !RErr_eq(RErrNil, errLen) do return errLen

	switch line[0] {
	case RespBlobError, RespString, RespVerbatim:
		bufio.reader_discard(&r.rd, n + 2) or_return
		return nil
	case RespArray, RespSet, RespPush:
		for i in 0 ..< n {
			discard_next(r) or_return
		}
		return nil
	case RespMap, RespAttr:
		for i in 0 ..< n * 2 {
			discard_next(r) or_return
		}
		return nil
	}
	return RErr_attach(&RErrParseData.(RErr), line)
}

discard_next :: proc(r: ^Reader) -> Error {
	return r->discard(read_line(r) or_return)
}

// 如果:
//   - 有待处理读取错误
//   - 行不以 \r\n 结束
// 返回error
read_line :: proc(r: ^Reader) -> (brsp: []byte, e: Error) {
	b, errRS := bufio.reader_read_slice(&r.rd, '\n')
	if errRS != nil {
		// log.errorf("err={:v}", errRS)
		if errRS != .Buffer_Full do return nil, errRS

		full := make([dynamic]byte, len(b))
		copy(full[:], b)
		b = bufio.reader_read_bytes(&r.rd, '\n') or_return

		append(&full, ..b)
		b = slice.clone(full[:])
	}
	if len(b) <= 2 || b[len(b) - 1] != '\n' || b[len(b) - 2] != '\r' {
		return nil, RErr_attach(&RErrInvalidReply.(RErr), b)
	}
	return b[:len(b) - 2], nil
}

parse_map_reply :: proc(r: ^Reader, line: []byte) -> (rsp: map[string]Resp, e: Error) {
	n := reply_len(line) or_return

	rsp = make(map[string]Resp, n)
	for i in 0 ..< n {
		item := r->parse_recv() or_return
		k := Resp_to_str(&item)
		v, errV := r->parse_recv()
		if errV != nil {
			errR, ok := errV.(Maybe(RErr))
			if !ok do return nil, errV

			if RErr_eq(errR, RErrNil) {rsp[k] = nil;continue}

			rsp[k] = errR
			continue
		}
		rsp[k] = v
	}
	return rsp, nil
}

// odinfmt:disable
is_nil_reply ::proc(line:[]byte) ->bool{
    return len(line) == 3 && (line[0]==RespString || line[0] == RespArray) && 
        line[1] == '-' && line[2] == '1'
}
// odinfmt:enable

reply_len :: proc(line: []byte) -> (int, Maybe(RErr)) {
	n, ok := strconv.parse_int(string(line[1:]))
	if !ok do return 0, RErrParseNumber

	if n < -1 do return 0, RErrInvalidReply
	switch line[0] {
	case RespString, RespVerbatim, RespBlobError, RespArray, RespSet, RespPush, RespMap, RespAttr:
		if n == -1 do return 0, RErrNil
	}

	// log.infof("len={}", n)
	return n, nil
}

// RESP数据前缀
RespStatus :: '+' // +<string>\r\n
RespError :: '-' // -<string>\r\n
RespString :: '$' // $<length>\r\n<bytes>\r\n
RespInt :: ':' // :<number>\r\n
RespNil :: '_' // _\r\n
RespFloat :: ',' // ,<floating-point-number>\r\n (golang float)
RespBool :: '#' // true: #t\r\n false: #f\r\n
RespBlobError :: '!' // !<length>\r\n<bytes>\r\n
RespVerbatim :: '=' // =<length>\r\nFORMAT:<bytes>\r\n
RespBigInt :: '(' // (<big number>\r\n
RespArray :: '*' // *<len>\r\n... (same as resp2)
RespMap :: '%' // %<len>\r\n(key)\r\n(value)\r\n... (golang map)
RespSet :: '~' // ~<len>\r\n... (same as Array)
RespAttr :: '|' // |<len>\r\n(key)\r\n(value)\r\n... + command reply
RespPush :: '>' // ><len>\r\n... (same as Array)
