import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 397 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 397, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro397 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro397 0
host_chunk_read_tail_eager PTail.micro397 1
host_chunk_read_tail_eager PTail.micro397 2
host_chunk_read_tail_eager PTail.micro397 3
host_chunk_read_tail_eager PTail.micro397 4
host_chunk_read_tail_eager PTail.micro397 5
host_chunk_read_tail_eager PTail.micro397 6
host_chunk_read_tail_eager PTail.micro397 7
host_chunk_read_tail_eager PTail.micro397 8
host_chunk_read_tail_eager PTail.micro397 9
tail_compose PTail.micro397 PTail.micro397.run :=
  PTail.micro397.tac0 PTail.micro397.tac1 PTail.micro397.tac2 PTail.micro397.tac3 PTail.micro397.tac4 PTail.micro397.tac5 PTail.micro397.tac6 PTail.micro397.tac7
  PTail.micro397.tac8 PTail.micro397.tac9
tail_chunk_from P 397 := PTail.micro397.run

end Host.Load.Run.Full
