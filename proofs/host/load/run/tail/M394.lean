import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 394 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 394, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro394 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro394 0
host_chunk_read_tail_eager PTail.micro394 1
host_chunk_read_tail_eager PTail.micro394 2
host_chunk_read_tail_eager PTail.micro394 3
host_chunk_read_tail_eager PTail.micro394 4
host_chunk_read_tail_eager PTail.micro394 5
host_chunk_read_tail_eager PTail.micro394 6
host_chunk_read_tail_eager PTail.micro394 7
host_chunk_read_tail_eager PTail.micro394 8
host_chunk_read_tail_eager PTail.micro394 9
tail_compose PTail.micro394 PTail.micro394.run :=
  PTail.micro394.tac0 PTail.micro394.tac1 PTail.micro394.tac2 PTail.micro394.tac3 PTail.micro394.tac4 PTail.micro394.tac5 PTail.micro394.tac6 PTail.micro394.tac7
  PTail.micro394.tac8 PTail.micro394.tac9
tail_chunk_from P 394 := PTail.micro394.run

end Host.Load.Run.Full
