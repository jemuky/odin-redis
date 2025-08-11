#+private

package redis

txpipelineAddCmdStr :: proc(pl: ^TxPipeliner, cmd: string) {
	txpipelineAddCmdU8Arr(pl, transmute([]u8)cmd)
}

txpipelineAddCmdU8Arr :: proc(pl: ^TxPipeliner, cmd: []u8) {
	append(&pl.buf, ..cmd)
	append(&pl.buf, ..[]u8{'\r', '\n'})
}


txpipelineAddCmd :: proc {
	txpipelineAddCmdStr,
	txpipelineAddCmdU8Arr,
}

TxPipeline :: proc() -> ^TxPipeliner {
	pl := new(TxPipeliner)

	pl.buf = make([dynamic]u8)
	pl.add_cmd = txpipelineAddCmd
	pl.add_cmd_u8 = txpipelineAddCmd
	pl.exec = txpipelineExec
	return pl
}
TxPipelineFree :: proc(pl: ^TxPipeliner) {
	delete(pl.buf)
	free(pl)
}

txpipelineExec :: proc(pl: ^TxPipeliner, cmd: ^Cmdable) -> (rsp: Resp, e: Error) {
	cmd->multi() or_return
	cmd->anything_u8(pl.buf[:]) or_return
	data := cmd->exec() or_return
	return RespParse(data)
}
