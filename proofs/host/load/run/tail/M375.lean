import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 375 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 375, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro375 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro375 0
host_chunk_read_tail_eager PTail.micro375 1
host_chunk_read_tail_eager PTail.micro375 2
host_chunk_read_tail_eager PTail.micro375 3
host_chunk_read_tail_eager PTail.micro375 4
host_chunk_read_tail_eager PTail.micro375 5
host_chunk_read_tail_eager PTail.micro375 6
host_chunk_read_tail_eager PTail.micro375 7
host_chunk_read_tail_eager PTail.micro375 8
host_chunk_read_tail_eager PTail.micro375 9
tail_compose PTail.micro375 PTail.micro375.run :=
  PTail.micro375.tac0 PTail.micro375.tac1 PTail.micro375.tac2 PTail.micro375.tac3 PTail.micro375.tac4 PTail.micro375.tac5 PTail.micro375.tac6 PTail.micro375.tac7
  PTail.micro375.tac8 PTail.micro375.tac9
tail_chunk_from P 375 := PTail.micro375.run

end Host.Load.Run.Full
