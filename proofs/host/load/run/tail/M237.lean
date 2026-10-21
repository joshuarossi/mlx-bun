import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 237 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 237, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro237 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro237 0
host_chunk_read_tail_eager PTail.micro237 1
host_chunk_read_tail_eager PTail.micro237 2
host_chunk_read_tail_eager PTail.micro237 3
host_chunk_read_tail_eager PTail.micro237 4
host_chunk_read_tail_eager PTail.micro237 5
host_chunk_read_tail_eager PTail.micro237 6
host_chunk_read_tail_eager PTail.micro237 7
host_chunk_read_tail_eager PTail.micro237 8
host_chunk_read_tail_eager PTail.micro237 9
tail_compose PTail.micro237 PTail.micro237.run :=
  PTail.micro237.tac0 PTail.micro237.tac1 PTail.micro237.tac2 PTail.micro237.tac3 PTail.micro237.tac4 PTail.micro237.tac5 PTail.micro237.tac6 PTail.micro237.tac7
  PTail.micro237.tac8 PTail.micro237.tac9
tail_chunk_from P 237 := PTail.micro237.run

end Host.Load.Run.Full
