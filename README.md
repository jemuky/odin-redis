# odin-redis
redis odin 客户端

# 依赖于
- redis服务端

# 使用

```odin
import redis "odin-redis"
import "core:fmt"
import "core:log"

redisCli: ^redis.Cmdable
logger: log.Logger

@(init, private)
init :: proc() {
	win.SetConsoleOutputCP(.UTF8)

	logger = log.create_console_logger()
	err: redis.Error
    // 创建客户端，可以传配置 {ip,port}，默认{"127.0.0.1", 6379}
	redisCli, err = redis.CmdableNew()
	if err != nil {
		panic(fmt.tprintf("redis client create failed, err=%v", err))
	}
}

@(fini, private)
fini :: proc() {
	log.destroy_console_logger(logger)
	redis.CmdableFree(redisCli)
}

main :: proc() {
	// 监听内存泄漏
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
			}
		}
		mem.tracking_allocator_destroy(&track)
	}
	// 使用logger
	context.logger = logger
    // 此库已定义的命令都可使用
    redisCli->ping()
    // 未定义命令可这样使用
	redisCli->anything("auth 123")

    // TxPipeline
    pl := redisCli->tx_pipeline()
	pl->add_cmd("set skey test")
	pl->add_cmd("type skey")
	pl->add_cmd("get sskey")
	pl->add_cmd("exists sskey")
	rspExec, errExec := pl->exec(redisCli)
}
```
