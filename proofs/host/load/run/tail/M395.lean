import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 395 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 395, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro395 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro395 0
host_chunk_read_tail_eager PTail.micro395 1
host_chunk_read_tail_eager PTail.micro395 2
host_chunk_read_tail_eager PTail.micro395 3
host_chunk_read_tail_eager PTail.micro395 4
host_chunk_read_tail_eager PTail.micro395 5
host_chunk_read_tail_eager PTail.micro395 6
host_chunk_read_tail_eager PTail.micro395 7
host_chunk_read_tail_eager PTail.micro395 8
host_chunk_read_tail_eager PTail.micro395 9
tail_compose PTail.micro395 PTail.micro395.run :=
  PTail.micro395.tac0 PTail.micro395.tac1 PTail.micro395.tac2 PTail.micro395.tac3 PTail.micro395.tac4 PTail.micro395.tac5 PTail.micro395.tac6 PTail.micro395.tac7
  PTail.micro395.tac8 PTail.micro395.tac9
tail_chunk_from P 395 := PTail.micro395.run

end Host.Load.Run.Full
