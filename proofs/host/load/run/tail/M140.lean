import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 140 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 140, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro140 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro140 0
host_chunk_read_tail_eager PTail.micro140 1
host_chunk_read_tail_eager PTail.micro140 2
host_chunk_read_tail_eager PTail.micro140 3
host_chunk_read_tail_eager PTail.micro140 4
host_chunk_read_tail_eager PTail.micro140 5
host_chunk_read_tail_eager PTail.micro140 6
host_chunk_read_tail_eager PTail.micro140 7
host_chunk_read_tail_eager PTail.micro140 8
host_chunk_read_tail_eager PTail.micro140 9
tail_compose PTail.micro140 PTail.micro140.run :=
  PTail.micro140.tac0 PTail.micro140.tac1 PTail.micro140.tac2 PTail.micro140.tac3 PTail.micro140.tac4 PTail.micro140.tac5 PTail.micro140.tac6 PTail.micro140.tac7
  PTail.micro140.tac8 PTail.micro140.tac9
tail_chunk_from P 140 := PTail.micro140.run

end Host.Load.Run.Full
