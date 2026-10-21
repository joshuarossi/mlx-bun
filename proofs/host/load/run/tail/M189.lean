import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 189 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 189, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro189 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro189 0
host_chunk_read_tail_eager PTail.micro189 1
host_chunk_read_tail_eager PTail.micro189 2
host_chunk_read_tail_eager PTail.micro189 3
host_chunk_read_tail_eager PTail.micro189 4
host_chunk_read_tail_eager PTail.micro189 5
host_chunk_read_tail_eager PTail.micro189 6
host_chunk_read_tail_eager PTail.micro189 7
host_chunk_read_tail_eager PTail.micro189 8
host_chunk_read_tail_eager PTail.micro189 9
tail_compose PTail.micro189 PTail.micro189.run :=
  PTail.micro189.tac0 PTail.micro189.tac1 PTail.micro189.tac2 PTail.micro189.tac3 PTail.micro189.tac4 PTail.micro189.tac5 PTail.micro189.tac6 PTail.micro189.tac7
  PTail.micro189.tac8 PTail.micro189.tac9
tail_chunk_from P 189 := PTail.micro189.run

end Host.Load.Run.Full
