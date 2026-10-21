import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 240 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 240, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro240 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro240 0
host_chunk_read_tail_eager PTail.micro240 1
host_chunk_read_tail_eager PTail.micro240 2
host_chunk_read_tail_eager PTail.micro240 3
host_chunk_read_tail_eager PTail.micro240 4
host_chunk_read_tail_eager PTail.micro240 5
host_chunk_read_tail_eager PTail.micro240 6
host_chunk_read_tail_eager PTail.micro240 7
host_chunk_read_tail_eager PTail.micro240 8
host_chunk_read_tail_eager PTail.micro240 9
tail_compose PTail.micro240 PTail.micro240.run :=
  PTail.micro240.tac0 PTail.micro240.tac1 PTail.micro240.tac2 PTail.micro240.tac3 PTail.micro240.tac4 PTail.micro240.tac5 PTail.micro240.tac6 PTail.micro240.tac7
  PTail.micro240.tac8 PTail.micro240.tac9
tail_chunk_from P 240 := PTail.micro240.run

end Host.Load.Run.Full
