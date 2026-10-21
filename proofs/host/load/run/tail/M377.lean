import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 377 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 377, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro377 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro377 0
host_chunk_read_tail_eager PTail.micro377 1
host_chunk_read_tail_eager PTail.micro377 2
host_chunk_read_tail_eager PTail.micro377 3
host_chunk_read_tail_eager PTail.micro377 4
host_chunk_read_tail_eager PTail.micro377 5
host_chunk_read_tail_eager PTail.micro377 6
host_chunk_read_tail_eager PTail.micro377 7
host_chunk_read_tail_eager PTail.micro377 8
host_chunk_read_tail_eager PTail.micro377 9
tail_compose PTail.micro377 PTail.micro377.run :=
  PTail.micro377.tac0 PTail.micro377.tac1 PTail.micro377.tac2 PTail.micro377.tac3 PTail.micro377.tac4 PTail.micro377.tac5 PTail.micro377.tac6 PTail.micro377.tac7
  PTail.micro377.tac8 PTail.micro377.tac9
tail_chunk_from P 377 := PTail.micro377.run

end Host.Load.Run.Full
