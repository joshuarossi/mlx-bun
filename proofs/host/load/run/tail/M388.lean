import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 388 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 388, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro388 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro388 0
host_chunk_read_tail_eager PTail.micro388 1
host_chunk_read_tail_eager PTail.micro388 2
host_chunk_read_tail_eager PTail.micro388 3
host_chunk_read_tail_eager PTail.micro388 4
host_chunk_read_tail_eager PTail.micro388 5
host_chunk_read_tail_eager PTail.micro388 6
host_chunk_read_tail_eager PTail.micro388 7
host_chunk_read_tail_eager PTail.micro388 8
host_chunk_read_tail_eager PTail.micro388 9
tail_compose PTail.micro388 PTail.micro388.run :=
  PTail.micro388.tac0 PTail.micro388.tac1 PTail.micro388.tac2 PTail.micro388.tac3 PTail.micro388.tac4 PTail.micro388.tac5 PTail.micro388.tac6 PTail.micro388.tac7
  PTail.micro388.tac8 PTail.micro388.tac9
tail_chunk_from P 388 := PTail.micro388.run

end Host.Load.Run.Full
