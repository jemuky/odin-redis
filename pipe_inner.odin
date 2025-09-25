#+private

package redis

txpipeline_add_cmd_str :: proc(pl: ^TxPipeliner, cmd: string) {
	txpipeline_add_cmd_u8_arr(pl, transmute([]u8)cmd)
}

txpipeline_add_cmd_u8_arr :: proc(pl: ^TxPipeliner, cmd: []u8) {
	append(&pl.buf, ..cmd)
	append(&pl.buf, ..[]u8{'\r', '\n'})
}


txpipeline_add_cmd :: proc {
	txpipeline_add_cmd_str,
	txpipeline_add_cmd_u8_arr,
}

TxPipeline_new :: proc() -> ^TxPipeliner {
	pl := new(TxPipeliner)

	pl.buf = make([dynamic]u8)
	pl.add_cmd = txpipeline_add_cmd
	pl.add_cmd_u8 = txpipeline_add_cmd
	pl.exec = txpipeline_exec
	return pl
}

TxPipeline_free :: proc(pl: ^TxPipeliner) {
	delete(pl.buf)
	free(pl)
}

txpipeline_exec :: proc(pl: ^TxPipeliner, cmd: ^Cmdable) -> (rsp: Resp, e: Error) {
	cmd->multi() or_return
	cmd->anything_u8(pl.buf[:]) or_return
	data := cmd->exec() or_return
	return Resp_parse(data)
}
