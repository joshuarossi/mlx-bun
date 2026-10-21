import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 391 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 391, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro391 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro391 0
host_chunk_read_tail_eager PTail.micro391 1
host_chunk_read_tail_eager PTail.micro391 2
host_chunk_read_tail_eager PTail.micro391 3
host_chunk_read_tail_eager PTail.micro391 4
host_chunk_read_tail_eager PTail.micro391 5
host_chunk_read_tail_eager PTail.micro391 6
host_chunk_read_tail_eager PTail.micro391 7
host_chunk_read_tail_eager PTail.micro391 8
host_chunk_read_tail_eager PTail.micro391 9
tail_compose PTail.micro391 PTail.micro391.run :=
  PTail.micro391.tac0 PTail.micro391.tac1 PTail.micro391.tac2 PTail.micro391.tac3 PTail.micro391.tac4 PTail.micro391.tac5 PTail.micro391.tac6 PTail.micro391.tac7
  PTail.micro391.tac8 PTail.micro391.tac9
tail_chunk_from P 391 := PTail.micro391.run

end Host.Load.Run.Full
