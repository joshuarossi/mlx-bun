import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 77 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 77, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro77 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro77 0
host_chunk_read_tail_eager PTail.micro77 1
host_chunk_read_tail_eager PTail.micro77 2
host_chunk_read_tail_eager PTail.micro77 3
host_chunk_read_tail_eager PTail.micro77 4
host_chunk_read_tail_eager PTail.micro77 5
host_chunk_read_tail_eager PTail.micro77 6
host_chunk_read_tail_eager PTail.micro77 7
host_chunk_read_tail_eager PTail.micro77 8
host_chunk_read_tail_eager PTail.micro77 9
tail_compose PTail.micro77 PTail.micro77.run :=
  PTail.micro77.tac0 PTail.micro77.tac1 PTail.micro77.tac2 PTail.micro77.tac3 PTail.micro77.tac4 PTail.micro77.tac5 PTail.micro77.tac6 PTail.micro77.tac7
  PTail.micro77.tac8 PTail.micro77.tac9
tail_chunk_from P 77 := PTail.micro77.run

end Host.Load.Run.Full
