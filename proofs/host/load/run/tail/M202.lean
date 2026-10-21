import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 202 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 202, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro202 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro202 0
host_chunk_read_tail_eager PTail.micro202 1
host_chunk_read_tail_eager PTail.micro202 2
host_chunk_read_tail_eager PTail.micro202 3
host_chunk_read_tail_eager PTail.micro202 4
host_chunk_read_tail_eager PTail.micro202 5
host_chunk_read_tail_eager PTail.micro202 6
host_chunk_read_tail_eager PTail.micro202 7
host_chunk_read_tail_eager PTail.micro202 8
host_chunk_read_tail_eager PTail.micro202 9
tail_compose PTail.micro202 PTail.micro202.run :=
  PTail.micro202.tac0 PTail.micro202.tac1 PTail.micro202.tac2 PTail.micro202.tac3 PTail.micro202.tac4 PTail.micro202.tac5 PTail.micro202.tac6 PTail.micro202.tac7
  PTail.micro202.tac8 PTail.micro202.tac9
tail_chunk_from P 202 := PTail.micro202.run

end Host.Load.Run.Full
