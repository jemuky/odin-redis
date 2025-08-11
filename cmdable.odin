package redis

import "core:fmt"
import "core:strings"
import "core:time"

// odinfmt: disable
Cmdable :: struct {
	c:              ^Client,
	pl:             ^TxPipeliner,
	// ping
	ping:           proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	// 执行任意命令
	anything:       proc(cmd: ^Cmdable, data: string) -> (rsp: []byte, e: Error),
	anything_u8:    proc(cmd: ^Cmdable, data: []u8) -> (rsp: []byte, e: Error),
	// txpipeline
	multi:          proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	exec:           proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	tx_pipeline:    proc(cmd: ^Cmdable) -> ^TxPipeliner,

	// common
	del:            proc(cmd: ^Cmdable, keys: ..string) -> (rsp: []byte, e: Error),
	unlink:         proc(cmd: ^Cmdable, keys: ..string) -> (rsp: []byte, e: Error),
	exists:         proc(cmd: ^Cmdable, keys: ..string) -> (rsp: []byte, e: Error),
	expire:         proc(
		cmd: ^Cmdable,
		key: string,
		expiration: time.Duration,
		flag: string = "", // NX/XX/GT/LT
	) -> (
		rsp: []byte,
		e: Error,
	),
	expireAt:       proc(
		cmd: ^Cmdable,
		key: string,
		tm: time.Time,
		flag: string = "", // NX/XX/GT/LT
	) -> (
		rsp: []byte,
		e: Error,
	),
	expireTime:     proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	ttl:            proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	pttl:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	pexpire:        proc(
		cmd: ^Cmdable,
		key: string,
		expiration: time.Duration,
		flag: string = "", // NX/XX/GT/LT
	) -> (
		rsp: []byte,
		e: Error,
	),
	pexpireAt:      proc(
		cmd: ^Cmdable,
		key: string,
		tm: time.Time,
		flag: string = "", // NX/XX/GT/LT
	) -> (
		rsp: []byte,
		e: Error,
	),
	pexpireTime:    proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	persist:        proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	dump:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	keys:           proc(cmd: ^Cmdable, pattern: string) -> (rsp: []byte, e: Error),
	randomKey:      proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	rename:         proc(cmd: ^Cmdable, key, newkey: string) -> (rsp: []byte, e: Error),
	renamenx:       proc(cmd: ^Cmdable, key, newkey: string) -> (rsp: []byte, e: Error),
	type:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	// scan
	scan:           proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	sscan:          proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	hscan:          proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	zscan:          proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	// kv
	append:         proc(cmd: ^Cmdable, key, value: string) -> (rsp: []byte, e: Error),
	get:            proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	getset:         proc(cmd: ^Cmdable, key, value: string) -> (rsp: []byte, e: Error),
	getrange:       proc(cmd: ^Cmdable, key: string, start, end: i64) -> (rsp: []byte, e: Error),
	setrange:       proc(
		cmd: ^Cmdable,
		key: string,
		offset: i64,
		value: string,
	) -> (
		rsp: []byte,
		e: Error,
	),
	set:            proc(
		cmd: ^Cmdable,
		key, value: string,
		args: ..string,
	) -> (
		rsp: []byte,
		e: Error,
	),
	incr:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	incrby:         proc(cmd: ^Cmdable, key: string, num: i64) -> (rsp: []byte, e: Error),
	incrbyfloat:    proc(cmd: ^Cmdable, key: string, num: f64) -> (rsp: []byte, e: Error),
	decr:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	decrby:         proc(cmd: ^Cmdable, key: string, num: i64) -> (rsp: []byte, e: Error),
	mget:           proc(cmd: ^Cmdable, keys: ..string) -> (rsp: []byte, e: Error),
	mset:           proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	msetnx:         proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	// bitmap
	getbit:         proc(cmd: ^Cmdable, key: string, offset: i64) -> (rsp: []byte, e: Error),
	setbit:         proc(
		cmd: ^Cmdable,
		key: string,
		offset: i64,
		value: int,
	) -> (
		rsp: []byte,
		e: Error,
	),
	bitcount:       proc(
		cmd: ^Cmdable,
		key: string,
		start, end: i64,
		flag := "",
	) -> (
		rsp: []byte,
		e: Error,
	),
	bitpos:         proc(
		cmd: ^Cmdable,
		key: string,
		bit, start, end: i64,
		flag := "",
	) -> (
		rsp: []byte,
		e: Error,
	),
	bitop:          proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error),
	bitfield:       proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error),
	// hash
	hdel:           proc(cmd: ^Cmdable, key: string, fields: ..string) -> (rsp: []byte, e: Error),
	hmget:          proc(cmd: ^Cmdable, key: string, fields: ..string) -> (rsp: []byte, e: Error),
	hset:           proc(cmd: ^Cmdable, key: string, values: ..string) -> (rsp: []byte, e: Error),
	hmset:          proc(cmd: ^Cmdable, key: string, values: ..string) -> (rsp: []byte, e: Error),
	hsetnx:         proc(cmd: ^Cmdable, key, field: string, value: any) -> (rsp: []byte, e: Error),
	hexists:        proc(cmd: ^Cmdable, key, field: string) -> (rsp: []byte, e: Error),
	hget:           proc(cmd: ^Cmdable, key, field: string) -> (rsp: []byte, e: Error),
	hgetall:        proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	hvals:          proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	hkeys:          proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	hlen:           proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	hrandfield:     proc(
		cmd: ^Cmdable,
		key: string,
		count := 1,
		withValues: bool = false,
	) -> (
		rsp: []byte,
		e: Error,
	),
	hincrby:        proc(
		cmd: ^Cmdable,
		key, field: string,
		increment: i64,
	) -> (
		rsp: []byte,
		e: Error,
	),
	hincrbyfloat:   proc(
		cmd: ^Cmdable,
		key, field: string,
		increment: f64,
	) -> (
		rsp: []byte,
		e: Error,
	),
	// zset
	zadd:           proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error),
	zrange:         proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error),
	zcard:          proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	zmscore:        proc(cmd: ^Cmdable, key: string, members: ..string) -> (rsp: []byte, e: Error),
	zrem:           proc(cmd: ^Cmdable, key: string, members: ..string) -> (rsp: []byte, e: Error),
	zscore:         proc(cmd: ^Cmdable, key: string, member: string) -> (rsp: []byte, e: Error),
	zrank:          proc(cmd: ^Cmdable, key: string, member: string) -> (rsp: []byte, e: Error),
	zcount:         proc(cmd: ^Cmdable, key, min, max: string) -> (rsp: []byte, e: Error),
	zincrby:        proc(
		cmd: ^Cmdable,
		key: string,
		increment: f64,
		member: string,
	) -> (
		rsp: []byte,
		e: Error,
	),
	// set
	// other
	migrate:        proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	move:           proc(cmd: ^Cmdable, key: string, db: int) -> (rsp: []byte, e: Error),
	quit:           proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	echo:           proc(cmd: ^Cmdable, msg: []u8) -> (rsp: []byte, e: Error),
	command:        proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	commandList:    proc(
		cmd: ^Cmdable,
		module: Maybe(string) = nil,
		aclcat: Maybe(string) = nil,
		pattern: Maybe(string) = nil,
	) -> (
		rsp: []byte,
		e: Error,
	),
	// see "client help"
	client:         proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	// see "config help"
	config:         proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error),
	dbsize:         proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	flushall:       proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	flushallAsync:  proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	flushDB:        proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	flushDBAsync:   proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	info:           proc(cmd: ^Cmdable, sections: ..string) -> (rsp: []byte, e: Error),
	lastsave:       proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	save:           proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	shutdown:       proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	shutdownSave:   proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	shutdownNoSave: proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	slaveOf:        proc(cmd: ^Cmdable, host, port: string) -> (rsp: []byte, e: Error),
	slowlogGet:     proc(cmd: ^Cmdable, num: i64) -> (rsp: []byte, e: Error),
	time:           proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	debugObject:    proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error),
	readOnly:       proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	readWrite:      proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error),
	memoryUsage:    proc(
		cmd: ^Cmdable,
		key: string,
		sample: Maybe(int) = nil,
	) -> (
		rsp: []byte,
		e: Error,
	),
}
// odinfmt: enable

CmdableFree :: proc(c: ^Cmdable) {
	TxPipelineFree(c.pl)
	ClientDestroy(c.c)
	free(c)
}

CmdableNew :: proc(ip: string = "127.0.0.1", port: int = 6379) -> (cmdable: ^Cmdable, err: Error) {
	client := ClientCreate(ip, port) or_return

	com := new(Cmdable)
	com.c = client
	com.pl = TxPipeline()
	
	//odinfmt: disable
	com.tx_pipeline = proc(cmd: ^Cmdable) -> ^TxPipeliner {return cmd.pl}
	com.ping = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "PING")}
	com.multi = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "MULTI")}
	com.exec = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "EXEC")}
	com.anything = proc(cmd: ^Cmdable, data: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, data)}
	com.anything_u8 = proc(cmd: ^Cmdable, data: []u8) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, data)}
	com.del = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "DEL", ..args)}
	com.unlink = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "UNLINK", ..args)}
	com.exists = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "EXISTS", ..args)}
	com.expire = cmdableExpire
	com.expireAt = cmdableExpireAt
	com.expireTime = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("EXPIRETIME %s", key))}
	com.ttl = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("TTL %s", key))}
	com.pttl = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("PTTL %s", key))}
	com.pexpire = cmdablePExpire
	com.pexpireAt = cmdablePExpireAt
	com.pexpireTime = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("PEXPIRETIME %s", key))}
	com.persist = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("PERSIST %s", key))}
	com.dump = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("DUMP %s", key))}
	com.keys = proc(cmd: ^Cmdable, pattern: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("KEYS %s", pattern))}
	com.randomKey = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "RANDOMKEY")}
	com.rename = proc(cmd: ^Cmdable, key, newkey: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("RENAME %s %s", key, newkey))}
	com.renamenx = proc(cmd: ^Cmdable, key, newkey: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("RENAMENX %s %s", key, newkey))}
	com.type = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("TYPE %s", key))}

	// scan
	com.scan = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "SCAN", ..args)}
	com.sscan = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "SSCAN", ..args)}
	com.hscan = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "HSCAN", ..args)}
	com.zscan = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "ZSCAN", ..args)}

	// kv
	com.append = proc(cmd: ^Cmdable, key, value: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("APPEND %s %s", key, value))}
	com.get = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("GET %s", key))}
	com.getset = proc(cmd: ^Cmdable, key: string, value: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("GETSET %s %s", key, value))}
	com.getrange = proc(cmd: ^Cmdable, key: string, start, end: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("GETRANGE %s %d %d", key, start, end))}
	com.setrange = proc(cmd: ^Cmdable, key: string, offset: i64, value: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("SETRANGE %s %d %s", key, offset, value))}
	com.set = proc(cmd: ^Cmdable, key, value: string, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("SET %s %s", key, value), ..args)}
	com.incr = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("INCR %s", key))}
	com.incrby = proc(cmd: ^Cmdable, key: string, num: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("INCRBY %s %d", key, num))}
	com.incrbyfloat = proc(cmd: ^Cmdable, key: string, num: f64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("INCRBYFLOAT %s %d", key, num))}
	com.decr = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("DECR %s", key))}
	com.decrby = proc(cmd: ^Cmdable, key: string, num: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("DECRBY %s %d", key, num))}
	com.mget = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "MGET", ..args)}
	com.mset = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "MSET", ..args)}
	com.msetnx = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "MSETNX", ..args)}
	
	// bitmap
	com.getbit = proc(cmd: ^Cmdable, key: string, offset: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("GETBIT %s %d", key, offset))}
	com.setbit = proc(cmd: ^Cmdable, key: string, offset: i64, value: int) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("SETBIT %s %d %d", key, offset, value))}
	com.bitcount = proc(cmd: ^Cmdable, key: string, start, end: i64, flag := "") -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("BITCOUNT %s %d %d %s", key, start, end, flag))}
	com.bitpos = proc(cmd: ^Cmdable, key: string, bit, start, end: i64, flag := "") -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("BITPOS %s %d %d %d %s", key, bit, start, end, flag))}
	com.bitop = proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "BITOP", ..args)}
	com.bitfield = proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "BITFIELD", ..args)}
	
	// hash
	com.hdel = proc(cmd: ^Cmdable, key: string, fields: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("HDEL %s", key), ..fields)}
	com.hmget = proc(cmd: ^Cmdable, key: string, fields: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("HMGET %s", key), ..fields)}
	com.hset = proc(cmd: ^Cmdable, key: string, values: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("HSET %s", key), ..values)}
	com.hmset = proc(cmd: ^Cmdable, key: string, values: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("HMSET %s", key), ..values)}

	com.hget = proc(cmd: ^Cmdable, key, field: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HGET %s %s", key, field))}
	com.hexists = proc(cmd: ^Cmdable, key, field: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HEXISTS %s %s", key, field))}
	com.hgetall = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HGETALL %s", key))}
	com.hvals = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HVALS %s", key))}
	com.hkeys = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HKEYS %s", key))}
	com.hlen = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HLEN %s", key))}
	com.hsetnx = proc(cmd: ^Cmdable, key, field: string, value: any) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HSETNX %s %s %v", key, field, value))}
	com.hincrby = proc(cmd: ^Cmdable, key, field: string, increment: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HINCRBY %s %s %d", key, field, increment))}
	com.hincrbyfloat = proc(cmd: ^Cmdable, key, field: string, increment: f64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HINCRBYFLOAT %s %s %d", key, field, increment))}
	com.hrandfield = proc(cmd: ^Cmdable, key: string, count := 1, withValues: bool = false) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("HRANDFIELD %s %d %s", key, count, withValues?"WITHVALUES":""))}

	// zset
	com.zadd = proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("ZADD %s", key), ..args)}
	com.zrange = proc(cmd: ^Cmdable, key: string, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("ZRANGE %s", key), ..args)}
	com.zmscore = proc(cmd: ^Cmdable, key: string, members: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("ZMSCORE %s", key), ..members)}
	com.zrem = proc(cmd: ^Cmdable, key: string, members: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, fmt.tprintf("ZREM %s", key), ..members)}
	com.zscore = proc(cmd: ^Cmdable, key: string, member: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ZSCORE %s %s", key, member))}
	com.zrank = proc(cmd: ^Cmdable, key: string, member: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ZRANK %s %s", key, member))}
	com.zcard = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ZCARD %s", key))}
	com.zcount = proc(cmd: ^Cmdable, key, min, max: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ZCOUNT %s %d %d", key, min, max))}
	com.zincrby = proc(cmd: ^Cmdable, key: string, increment: f64, member: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ZINCRBY %s %d %s", key, increment, member))}

	// other
	com.migrate = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "MIGRATE", ..args)}
	com.move = proc(cmd: ^Cmdable, key: string, db: int) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("MOVE %s %d", key, db))}
	com.quit = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "QUIT")}
	com.echo = proc(cmd: ^Cmdable, msg:[]u8) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("ECHO %v", msg))}
	com.command = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "COMMAND")}
	com.commandList = cmdableCommandList
	com.client = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "CLIENT", ..args)}
	com.config = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "CONFIG", ..args)}
	com.dbsize = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "DBSIZE")}
	com.flushall = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "FLUSHALL")}
	com.flushallAsync = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "FLUSHALL ASYNC")}
	com.flushDB = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "FLUSHDB")}
	com.flushDBAsync = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "FLUSHDB ASYNC")}
	com.info = proc(cmd: ^Cmdable, args: ..string) -> (rsp: []byte, e: Error) {return cmdableSCmdMArgs(cmd, "INFO", ..args)}
	com.lastsave = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "LASTSAVE")}
	com.save = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "SAVE")}
	com.shutdown = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "SHUTDOWN")}
	com.shutdownSave = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "SHUTDOWN SAVE")}
	com.shutdownNoSave = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "SHUTDOWN NOSAVE")}
	com.slaveOf = proc(cmd: ^Cmdable, host, port:string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("SLAVEOF %s %s", host, port))}
	com.slowlogGet = proc(cmd: ^Cmdable, num: i64) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("SLOWLOG GET %d", num))}
	com.time = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "TIME")}
	com.debugObject = proc(cmd: ^Cmdable, key: string) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, fmt.tprintf("DEBUG OBJECT %s", key))}
	com.readOnly = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "READONLY")}
	com.readWrite = proc(cmd: ^Cmdable) -> (rsp: []byte, e: Error) {return ConnectTExec(cmd.c.conn, "READWRITE")}
	com.memoryUsage = cmdableMemoryUsage
	//odinfmt: enable
	return com, nil
}
