import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 165 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 165, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro165 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro165 0
host_chunk_read_tail_eager PTail.micro165 1
host_chunk_read_tail_eager PTail.micro165 2
host_chunk_read_tail_eager PTail.micro165 3
host_chunk_read_tail_eager PTail.micro165 4
host_chunk_read_tail_eager PTail.micro165 5
host_chunk_read_tail_eager PTail.micro165 6
host_chunk_read_tail_eager PTail.micro165 7
host_chunk_read_tail_eager PTail.micro165 8
host_chunk_read_tail_eager PTail.micro165 9
tail_compose PTail.micro165 PTail.micro165.run :=
  PTail.micro165.tac0 PTail.micro165.tac1 PTail.micro165.tac2 PTail.micro165.tac3 PTail.micro165.tac4 PTail.micro165.tac5 PTail.micro165.tac6 PTail.micro165.tac7
  PTail.micro165.tac8 PTail.micro165.tac9
tail_chunk_from P 165 := PTail.micro165.run

end Host.Load.Run.Full
