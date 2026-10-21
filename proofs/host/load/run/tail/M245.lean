import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 245 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 245, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro245 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro245 0
host_chunk_read_tail_eager PTail.micro245 1
host_chunk_read_tail_eager PTail.micro245 2
host_chunk_read_tail_eager PTail.micro245 3
host_chunk_read_tail_eager PTail.micro245 4
host_chunk_read_tail_eager PTail.micro245 5
host_chunk_read_tail_eager PTail.micro245 6
host_chunk_read_tail_eager PTail.micro245 7
host_chunk_read_tail_eager PTail.micro245 8
host_chunk_read_tail_eager PTail.micro245 9
tail_compose PTail.micro245 PTail.micro245.run :=
  PTail.micro245.tac0 PTail.micro245.tac1 PTail.micro245.tac2 PTail.micro245.tac3 PTail.micro245.tac4 PTail.micro245.tac5 PTail.micro245.tac6 PTail.micro245.tac7
  PTail.micro245.tac8 PTail.micro245.tac9
tail_chunk_from P 245 := PTail.micro245.run

end Host.Load.Run.Full
