import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 236 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 236, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro236 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro236 0
host_chunk_read_tail_eager PTail.micro236 1
host_chunk_read_tail_eager PTail.micro236 2
host_chunk_read_tail_eager PTail.micro236 3
host_chunk_read_tail_eager PTail.micro236 4
host_chunk_read_tail_eager PTail.micro236 5
host_chunk_read_tail_eager PTail.micro236 6
host_chunk_read_tail_eager PTail.micro236 7
host_chunk_read_tail_eager PTail.micro236 8
host_chunk_read_tail_eager PTail.micro236 9
tail_compose PTail.micro236 PTail.micro236.run :=
  PTail.micro236.tac0 PTail.micro236.tac1 PTail.micro236.tac2 PTail.micro236.tac3 PTail.micro236.tac4 PTail.micro236.tac5 PTail.micro236.tac6 PTail.micro236.tac7
  PTail.micro236.tac8 PTail.micro236.tac9
tail_chunk_from P 236 := PTail.micro236.run

end Host.Load.Run.Full
