import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 370 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 370, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro370 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro370 0
host_chunk_read_tail_eager PTail.micro370 1
host_chunk_read_tail_eager PTail.micro370 2
host_chunk_read_tail_eager PTail.micro370 3
host_chunk_read_tail_eager PTail.micro370 4
host_chunk_read_tail_eager PTail.micro370 5
host_chunk_read_tail_eager PTail.micro370 6
host_chunk_read_tail_eager PTail.micro370 7
host_chunk_read_tail_eager PTail.micro370 8
host_chunk_read_tail_eager PTail.micro370 9
tail_compose PTail.micro370 PTail.micro370.run :=
  PTail.micro370.tac0 PTail.micro370.tac1 PTail.micro370.tac2 PTail.micro370.tac3 PTail.micro370.tac4 PTail.micro370.tac5 PTail.micro370.tac6 PTail.micro370.tac7
  PTail.micro370.tac8 PTail.micro370.tac9
tail_chunk_from P 370 := PTail.micro370.run

end Host.Load.Run.Full
