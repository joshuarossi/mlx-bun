import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 244 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 244, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro244 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro244 0
host_chunk_read_tail_eager PTail.micro244 1
host_chunk_read_tail_eager PTail.micro244 2
host_chunk_read_tail_eager PTail.micro244 3
host_chunk_read_tail_eager PTail.micro244 4
host_chunk_read_tail_eager PTail.micro244 5
host_chunk_read_tail_eager PTail.micro244 6
host_chunk_read_tail_eager PTail.micro244 7
host_chunk_read_tail_eager PTail.micro244 8
host_chunk_read_tail_eager PTail.micro244 9
tail_compose PTail.micro244 PTail.micro244.run :=
  PTail.micro244.tac0 PTail.micro244.tac1 PTail.micro244.tac2 PTail.micro244.tac3 PTail.micro244.tac4 PTail.micro244.tac5 PTail.micro244.tac6 PTail.micro244.tac7
  PTail.micro244.tac8 PTail.micro244.tac9
tail_chunk_from P 244 := PTail.micro244.run

end Host.Load.Run.Full
