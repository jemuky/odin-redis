package redis

import "core:fmt"
import "core:log"
import "core:testing"

@(test)
TestUsage :: proc(t: ^testing.T) {
	cli, errCli := Cmdable_new()
	if errCli != nil {
		panic(fmt.tprintf("connect failed, err={}", errCli))
	}
	defer Cmdable_free(cli)
	cli->anything("get 123")
	rsp, err := cli->ping()
	if err != nil {
		log.errorf("call redis failed, err={}", err)
		return
	}
	log.infof("recv before unmarshal rsp={}", rsp)
	rspNew, _ := Resp_parse(rsp)
	log.infof("recv after unmarshal rsp={}", Resp_to_str(&rspNew))

	pl := cli->tx_pipeline()
	pl->add_cmd("get 123")
	pl->exec(cli)
}
