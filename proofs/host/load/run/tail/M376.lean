import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 376 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 376, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro376 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro376 0
host_chunk_read_tail_eager PTail.micro376 1
host_chunk_read_tail_eager PTail.micro376 2
host_chunk_read_tail_eager PTail.micro376 3
host_chunk_read_tail_eager PTail.micro376 4
host_chunk_read_tail_eager PTail.micro376 5
host_chunk_read_tail_eager PTail.micro376 6
host_chunk_read_tail_eager PTail.micro376 7
host_chunk_read_tail_eager PTail.micro376 8
host_chunk_read_tail_eager PTail.micro376 9
tail_compose PTail.micro376 PTail.micro376.run :=
  PTail.micro376.tac0 PTail.micro376.tac1 PTail.micro376.tac2 PTail.micro376.tac3 PTail.micro376.tac4 PTail.micro376.tac5 PTail.micro376.tac6 PTail.micro376.tac7
  PTail.micro376.tac8 PTail.micro376.tac9
tail_chunk_from P 376 := PTail.micro376.run

end Host.Load.Run.Full
