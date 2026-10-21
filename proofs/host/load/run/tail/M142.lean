import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 142 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 142, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro142 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro142 0
host_chunk_read_tail_eager PTail.micro142 1
host_chunk_read_tail_eager PTail.micro142 2
host_chunk_read_tail_eager PTail.micro142 3
host_chunk_read_tail_eager PTail.micro142 4
host_chunk_read_tail_eager PTail.micro142 5
host_chunk_read_tail_eager PTail.micro142 6
host_chunk_read_tail_eager PTail.micro142 7
host_chunk_read_tail_eager PTail.micro142 8
host_chunk_read_tail_eager PTail.micro142 9
tail_compose PTail.micro142 PTail.micro142.run :=
  PTail.micro142.tac0 PTail.micro142.tac1 PTail.micro142.tac2 PTail.micro142.tac3 PTail.micro142.tac4 PTail.micro142.tac5 PTail.micro142.tac6 PTail.micro142.tac7
  PTail.micro142.tac8 PTail.micro142.tac9
tail_chunk_from P 142 := PTail.micro142.run

end Host.Load.Run.Full
