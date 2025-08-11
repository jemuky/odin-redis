package redis

import "core:fmt"
import "core:strings"
import "core:time"

cmdableCommandList :: proc(
	cmd: ^Cmdable,
	module, aclcat, pattern: Maybe(string),
) -> (
	rsp: []u8,
	e: Error,
) {
	builder := strings.builder_make() or_return
	defer strings.builder_destroy(&builder)

	strings.write_string(&builder, "COMMAND LIST ")
	if module != nil do strings.write_string(&builder, fmt.tprintf("MODULE %s ", module))
	if aclcat != nil do strings.write_string(&builder, fmt.tprintf("ACLCAT %s ", aclcat))
	if pattern != nil do strings.write_string(&builder, fmt.tprintf("PATTERN %s ", pattern))

	return ConnectTExec(cmd.c.conn, strings.to_string(builder))
}

// 开始命令后面多参
cmdableSCmdMArgs :: proc(cmd: ^Cmdable, command: string, args: ..string) -> (rsp: []u8, e: Error) {
	builder := strings.builder_make() or_return
	defer strings.builder_destroy(&builder)

	strings.write_string(&builder, command)
	strings.write_string(&builder, " ")
	for arg in args {
		strings.write_string(&builder, arg)
		strings.write_string(&builder, " ")
	}
	return ConnectTExec(cmd.c.conn, strings.to_string(builder))
}

cmdableMemoryUsage :: proc(
	cmd: ^Cmdable,
	key: string,
	sample: Maybe(int),
) -> (
	rsp: []u8,
	e: Error,
) {
	buf: string =
		sample == nil ? fmt.tprintf("MEMORY USAGE %s", key) : fmt.tprintf("MEMORY USAGE %s SAMPLES %d", key, sample)
	return ConnectTExec(cmd.c.conn, buf)
}

cmdableExpire :: proc(
	cmd: ^Cmdable,
	key: string,
	expiration: time.Duration,
	flag: string,
) -> (
	rsp: []u8,
	e: Error,
) {
	command := fmt.tprintf("EXPIRE %s %d %s", key, formatSec(expiration), flag)
	return ConnectTExec(cmd.c.conn, command)
}

cmdablePExpire :: proc(
	cmd: ^Cmdable,
	key: string,
	expiration: time.Duration,
	flag: string,
) -> (
	rsp: []u8,
	e: Error,
) {
	command := fmt.tprintf("PEXPIRE %s %d %s", key, formatMs(expiration), flag)
	return ConnectTExec(cmd.c.conn, command)
}

cmdableExpireAt :: proc(
	cmd: ^Cmdable,
	key: string,
	tm: time.Time,
	flag: string,
) -> (
	rsp: []u8,
	e: Error,
) {
	command := fmt.tprintf("EXPIREAT %s %d %s", key, time.to_unix_seconds(tm), flag)
	return ConnectTExec(cmd.c.conn, command)
}

cmdablePExpireAt :: proc(
	cmd: ^Cmdable,
	key: string,
	tm: time.Time,
	flag: string,
) -> (
	rsp: []u8,
	e: Error,
) {
	command := fmt.tprintf("PEXPIREAT %s %d %s", key, time.to_unix_nanoseconds(tm) / 1e6, flag)
	return ConnectTExec(cmd.c.conn, command)
}
