import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 178 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 178, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro178 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro178 0
host_chunk_read_tail_eager PTail.micro178 1
host_chunk_read_tail_eager PTail.micro178 2
host_chunk_read_tail_eager PTail.micro178 3
host_chunk_read_tail_eager PTail.micro178 4
host_chunk_read_tail_eager PTail.micro178 5
host_chunk_read_tail_eager PTail.micro178 6
host_chunk_read_tail_eager PTail.micro178 7
host_chunk_read_tail_eager PTail.micro178 8
host_chunk_read_tail_eager PTail.micro178 9
tail_compose PTail.micro178 PTail.micro178.run :=
  PTail.micro178.tac0 PTail.micro178.tac1 PTail.micro178.tac2 PTail.micro178.tac3 PTail.micro178.tac4 PTail.micro178.tac5 PTail.micro178.tac6 PTail.micro178.tac7
  PTail.micro178.tac8 PTail.micro178.tac9
tail_chunk_from P 178 := PTail.micro178.run

end Host.Load.Run.Full
