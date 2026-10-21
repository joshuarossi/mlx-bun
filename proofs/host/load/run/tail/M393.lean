import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 393 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 393, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro393 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro393 0
host_chunk_read_tail_eager PTail.micro393 1
host_chunk_read_tail_eager PTail.micro393 2
host_chunk_read_tail_eager PTail.micro393 3
host_chunk_read_tail_eager PTail.micro393 4
host_chunk_read_tail_eager PTail.micro393 5
host_chunk_read_tail_eager PTail.micro393 6
host_chunk_read_tail_eager PTail.micro393 7
host_chunk_read_tail_eager PTail.micro393 8
host_chunk_read_tail_eager PTail.micro393 9
tail_compose PTail.micro393 PTail.micro393.run :=
  PTail.micro393.tac0 PTail.micro393.tac1 PTail.micro393.tac2 PTail.micro393.tac3 PTail.micro393.tac4 PTail.micro393.tac5 PTail.micro393.tac6 PTail.micro393.tac7
  PTail.micro393.tac8 PTail.micro393.tac9
tail_chunk_from P 393 := PTail.micro393.run

end Host.Load.Run.Full
