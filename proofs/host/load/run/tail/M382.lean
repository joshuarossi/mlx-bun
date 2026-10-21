import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 382 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 382, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro382 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro382 0
host_chunk_read_tail_eager PTail.micro382 1
host_chunk_read_tail_eager PTail.micro382 2
host_chunk_read_tail_eager PTail.micro382 3
host_chunk_read_tail_eager PTail.micro382 4
host_chunk_read_tail_eager PTail.micro382 5
host_chunk_read_tail_eager PTail.micro382 6
host_chunk_read_tail_eager PTail.micro382 7
host_chunk_read_tail_eager PTail.micro382 8
host_chunk_read_tail_eager PTail.micro382 9
tail_compose PTail.micro382 PTail.micro382.run :=
  PTail.micro382.tac0 PTail.micro382.tac1 PTail.micro382.tac2 PTail.micro382.tac3 PTail.micro382.tac4 PTail.micro382.tac5 PTail.micro382.tac6 PTail.micro382.tac7
  PTail.micro382.tac8 PTail.micro382.tac9
tail_chunk_from P 382 := PTail.micro382.run

end Host.Load.Run.Full
