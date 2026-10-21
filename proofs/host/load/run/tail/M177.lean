import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 177 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 177, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro177 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro177 0
host_chunk_read_tail_eager PTail.micro177 1
host_chunk_read_tail_eager PTail.micro177 2
host_chunk_read_tail_eager PTail.micro177 3
host_chunk_read_tail_eager PTail.micro177 4
host_chunk_read_tail_eager PTail.micro177 5
host_chunk_read_tail_eager PTail.micro177 6
host_chunk_read_tail_eager PTail.micro177 7
host_chunk_read_tail_eager PTail.micro177 8
host_chunk_read_tail_eager PTail.micro177 9
tail_compose PTail.micro177 PTail.micro177.run :=
  PTail.micro177.tac0 PTail.micro177.tac1 PTail.micro177.tac2 PTail.micro177.tac3 PTail.micro177.tac4 PTail.micro177.tac5 PTail.micro177.tac6 PTail.micro177.tac7
  PTail.micro177.tac8 PTail.micro177.tac9
tail_chunk_from P 177 := PTail.micro177.run

end Host.Load.Run.Full
