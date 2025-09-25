# odin-redis
redis odin 客户端  
参考 [go-redis](https://github.com/redis/go-redis.git) 解析RESP协议

# 依赖于
- redis服务端

# procedure命名规则
- 希望对外暴露的与struct有关的使用 `类名(CamelCase)_snake_case`  
- 不希望对外暴露(非private)的与struct有关的使用 `类名(lower)_snake_case`  
- 不与struct有关的使用 `snake_case` 
- struct内method使用 `snake_case` 
- 本地变量使用 `camelCase`  

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
	redisCli, err = redis.Cmdable_new()
	if err != nil {
		panic(fmt.tprintf("redis client create failed, err=%v", err))
	}
}

@(fini, private)
fini :: proc() {
	log.destroy_console_logger(logger)
	redis.Cmdable_free(redisCli)
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
	rspAny, _ := redisCli->anything("auth 123")
	log.infof("recv before unmarshal rsp={}", rsp)
	rspNew, _ := Resp_parse(rspAny)
	log.infof("recv after unmarshal rsp={}", Resp_to_str(&rspNew))

    // TxPipeline
    pl := redisCli->tx_pipeline()
	pl->add_cmd("set skey test")
	pl->add_cmd("type skey")
	pl->add_cmd("get sskey")
	pl->add_cmd("exists sskey")
	rspExec, _ := pl->exec(redisCli)
}
```
