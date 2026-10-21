import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 366 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 366, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro366 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro366 0
host_chunk_read_tail_eager PTail.micro366 1
host_chunk_read_tail_eager PTail.micro366 2
host_chunk_read_tail_eager PTail.micro366 3
host_chunk_read_tail_eager PTail.micro366 4
host_chunk_read_tail_eager PTail.micro366 5
host_chunk_read_tail_eager PTail.micro366 6
host_chunk_read_tail_eager PTail.micro366 7
host_chunk_read_tail_eager PTail.micro366 8
host_chunk_read_tail_eager PTail.micro366 9
tail_compose PTail.micro366 PTail.micro366.run :=
  PTail.micro366.tac0 PTail.micro366.tac1 PTail.micro366.tac2 PTail.micro366.tac3 PTail.micro366.tac4 PTail.micro366.tac5 PTail.micro366.tac6 PTail.micro366.tac7
  PTail.micro366.tac8 PTail.micro366.tac9
tail_chunk_from P 366 := PTail.micro366.run

end Host.Load.Run.Full
