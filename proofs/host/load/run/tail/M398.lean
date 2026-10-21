import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 398 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 398, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro398 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro398 0
host_chunk_read_tail_eager PTail.micro398 1
host_chunk_read_tail_eager PTail.micro398 2
host_chunk_read_tail_eager PTail.micro398 3
host_chunk_read_tail_eager PTail.micro398 4
host_chunk_read_tail_eager PTail.micro398 5
host_chunk_read_tail_eager PTail.micro398 6
host_chunk_read_tail_eager PTail.micro398 7
host_chunk_read_tail_eager PTail.micro398 8
host_chunk_read_tail_eager PTail.micro398 9
tail_compose PTail.micro398 PTail.micro398.run :=
  PTail.micro398.tac0 PTail.micro398.tac1 PTail.micro398.tac2 PTail.micro398.tac3 PTail.micro398.tac4 PTail.micro398.tac5 PTail.micro398.tac6 PTail.micro398.tac7
  PTail.micro398.tac8 PTail.micro398.tac9
tail_chunk_from P 398 := PTail.micro398.run

end Host.Load.Run.Full
