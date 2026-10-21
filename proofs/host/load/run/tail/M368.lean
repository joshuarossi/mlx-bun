import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 368 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 368, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro368 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro368 0
host_chunk_read_tail_eager PTail.micro368 1
host_chunk_read_tail_eager PTail.micro368 2
host_chunk_read_tail_eager PTail.micro368 3
host_chunk_read_tail_eager PTail.micro368 4
host_chunk_read_tail_eager PTail.micro368 5
host_chunk_read_tail_eager PTail.micro368 6
host_chunk_read_tail_eager PTail.micro368 7
host_chunk_read_tail_eager PTail.micro368 8
host_chunk_read_tail_eager PTail.micro368 9
tail_compose PTail.micro368 PTail.micro368.run :=
  PTail.micro368.tac0 PTail.micro368.tac1 PTail.micro368.tac2 PTail.micro368.tac3 PTail.micro368.tac4 PTail.micro368.tac5 PTail.micro368.tac6 PTail.micro368.tac7
  PTail.micro368.tac8 PTail.micro368.tac9
tail_chunk_from P 368 := PTail.micro368.run

end Host.Load.Run.Full
