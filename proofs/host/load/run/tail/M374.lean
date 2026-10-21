import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 374 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 374, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro374 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro374 0
host_chunk_read_tail_eager PTail.micro374 1
host_chunk_read_tail_eager PTail.micro374 2
host_chunk_read_tail_eager PTail.micro374 3
host_chunk_read_tail_eager PTail.micro374 4
host_chunk_read_tail_eager PTail.micro374 5
host_chunk_read_tail_eager PTail.micro374 6
host_chunk_read_tail_eager PTail.micro374 7
host_chunk_read_tail_eager PTail.micro374 8
host_chunk_read_tail_eager PTail.micro374 9
tail_compose PTail.micro374 PTail.micro374.run :=
  PTail.micro374.tac0 PTail.micro374.tac1 PTail.micro374.tac2 PTail.micro374.tac3 PTail.micro374.tac4 PTail.micro374.tac5 PTail.micro374.tac6 PTail.micro374.tac7
  PTail.micro374.tac8 PTail.micro374.tac9
tail_chunk_from P 374 := PTail.micro374.run

end Host.Load.Run.Full
