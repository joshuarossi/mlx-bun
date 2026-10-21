import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 348 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 348, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro348 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro348 0
host_chunk_read_tail_eager PTail.micro348 1
host_chunk_read_tail_eager PTail.micro348 2
host_chunk_read_tail_eager PTail.micro348 3
host_chunk_read_tail_eager PTail.micro348 4
host_chunk_read_tail_eager PTail.micro348 5
host_chunk_read_tail_eager PTail.micro348 6
host_chunk_read_tail_eager PTail.micro348 7
host_chunk_read_tail_eager PTail.micro348 8
host_chunk_read_tail_eager PTail.micro348 9
tail_compose PTail.micro348 PTail.micro348.run :=
  PTail.micro348.tac0 PTail.micro348.tac1 PTail.micro348.tac2 PTail.micro348.tac3 PTail.micro348.tac4 PTail.micro348.tac5 PTail.micro348.tac6 PTail.micro348.tac7
  PTail.micro348.tac8 PTail.micro348.tac9
tail_chunk_from P 348 := PTail.micro348.run

end Host.Load.Run.Full
