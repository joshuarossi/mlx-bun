import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 349 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 349, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro349 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro349 0
host_chunk_read_tail_eager PTail.micro349 1
host_chunk_read_tail_eager PTail.micro349 2
host_chunk_read_tail_eager PTail.micro349 3
host_chunk_read_tail_eager PTail.micro349 4
host_chunk_read_tail_eager PTail.micro349 5
host_chunk_read_tail_eager PTail.micro349 6
host_chunk_read_tail_eager PTail.micro349 7
host_chunk_read_tail_eager PTail.micro349 8
host_chunk_read_tail_eager PTail.micro349 9
tail_compose PTail.micro349 PTail.micro349.run :=
  PTail.micro349.tac0 PTail.micro349.tac1 PTail.micro349.tac2 PTail.micro349.tac3 PTail.micro349.tac4 PTail.micro349.tac5 PTail.micro349.tac6 PTail.micro349.tac7
  PTail.micro349.tac8 PTail.micro349.tac9
tail_chunk_from P 349 := PTail.micro349.run

end Host.Load.Run.Full
