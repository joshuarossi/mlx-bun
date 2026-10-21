import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 372 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 372, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro372 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro372 0
host_chunk_read_tail_eager PTail.micro372 1
host_chunk_read_tail_eager PTail.micro372 2
host_chunk_read_tail_eager PTail.micro372 3
host_chunk_read_tail_eager PTail.micro372 4
host_chunk_read_tail_eager PTail.micro372 5
host_chunk_read_tail_eager PTail.micro372 6
host_chunk_read_tail_eager PTail.micro372 7
host_chunk_read_tail_eager PTail.micro372 8
host_chunk_read_tail_eager PTail.micro372 9
tail_compose PTail.micro372 PTail.micro372.run :=
  PTail.micro372.tac0 PTail.micro372.tac1 PTail.micro372.tac2 PTail.micro372.tac3 PTail.micro372.tac4 PTail.micro372.tac5 PTail.micro372.tac6 PTail.micro372.tac7
  PTail.micro372.tac8 PTail.micro372.tac9
tail_chunk_from P 372 := PTail.micro372.run

end Host.Load.Run.Full
