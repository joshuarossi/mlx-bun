import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 226 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 226, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro226 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro226 0
host_chunk_read_tail_eager PTail.micro226 1
host_chunk_read_tail_eager PTail.micro226 2
host_chunk_read_tail_eager PTail.micro226 3
host_chunk_read_tail_eager PTail.micro226 4
host_chunk_read_tail_eager PTail.micro226 5
host_chunk_read_tail_eager PTail.micro226 6
host_chunk_read_tail_eager PTail.micro226 7
host_chunk_read_tail_eager PTail.micro226 8
host_chunk_read_tail_eager PTail.micro226 9
tail_compose PTail.micro226 PTail.micro226.run :=
  PTail.micro226.tac0 PTail.micro226.tac1 PTail.micro226.tac2 PTail.micro226.tac3 PTail.micro226.tac4 PTail.micro226.tac5 PTail.micro226.tac6 PTail.micro226.tac7
  PTail.micro226.tac8 PTail.micro226.tac9
tail_chunk_from P 226 := PTail.micro226.run

end Host.Load.Run.Full
