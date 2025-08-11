package redis

import "core:fmt"
import "core:log"
import "core:testing"

@(test)
TestUsage :: proc(t: ^testing.T) {
	cli, errCli := CmdableNew()
	if errCli != nil {
		panic(fmt.tprintf("connect failed, err={}", errCli))
	}
	defer CmdableFree(cli)
	cli->anything("get 123")
	rsp, err := cli->ping()
	if err != nil {
		log.errorf("call redis failed, err={}", err)
		return
	}
	log.infof("recv rsp={}", rsp)

	pl := cli->tx_pipeline()
	pl->add_cmd("get 123")
	pl->exec(cli)
}
