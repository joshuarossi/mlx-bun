import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 379 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 379, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro379 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro379 0
host_chunk_read_tail_eager PTail.micro379 1
host_chunk_read_tail_eager PTail.micro379 2
host_chunk_read_tail_eager PTail.micro379 3
host_chunk_read_tail_eager PTail.micro379 4
host_chunk_read_tail_eager PTail.micro379 5
host_chunk_read_tail_eager PTail.micro379 6
host_chunk_read_tail_eager PTail.micro379 7
host_chunk_read_tail_eager PTail.micro379 8
host_chunk_read_tail_eager PTail.micro379 9
tail_compose PTail.micro379 PTail.micro379.run :=
  PTail.micro379.tac0 PTail.micro379.tac1 PTail.micro379.tac2 PTail.micro379.tac3 PTail.micro379.tac4 PTail.micro379.tac5 PTail.micro379.tac6 PTail.micro379.tac7
  PTail.micro379.tac8 PTail.micro379.tac9
tail_chunk_from P 379 := PTail.micro379.run

end Host.Load.Run.Full
