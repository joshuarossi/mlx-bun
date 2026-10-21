import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 243 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 243, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro243 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro243 0
host_chunk_read_tail_eager PTail.micro243 1
host_chunk_read_tail_eager PTail.micro243 2
host_chunk_read_tail_eager PTail.micro243 3
host_chunk_read_tail_eager PTail.micro243 4
host_chunk_read_tail_eager PTail.micro243 5
host_chunk_read_tail_eager PTail.micro243 6
host_chunk_read_tail_eager PTail.micro243 7
host_chunk_read_tail_eager PTail.micro243 8
host_chunk_read_tail_eager PTail.micro243 9
tail_compose PTail.micro243 PTail.micro243.run :=
  PTail.micro243.tac0 PTail.micro243.tac1 PTail.micro243.tac2 PTail.micro243.tac3 PTail.micro243.tac4 PTail.micro243.tac5 PTail.micro243.tac6 PTail.micro243.tac7
  PTail.micro243.tac8 PTail.micro243.tac9
tail_chunk_from P 243 := PTail.micro243.run

end Host.Load.Run.Full
