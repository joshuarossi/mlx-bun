import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 176 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 176, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro176 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro176 0
host_chunk_read_tail_eager PTail.micro176 1
host_chunk_read_tail_eager PTail.micro176 2
host_chunk_read_tail_eager PTail.micro176 3
host_chunk_read_tail_eager PTail.micro176 4
host_chunk_read_tail_eager PTail.micro176 5
host_chunk_read_tail_eager PTail.micro176 6
host_chunk_read_tail_eager PTail.micro176 7
host_chunk_read_tail_eager PTail.micro176 8
host_chunk_read_tail_eager PTail.micro176 9
tail_compose PTail.micro176 PTail.micro176.run :=
  PTail.micro176.tac0 PTail.micro176.tac1 PTail.micro176.tac2 PTail.micro176.tac3 PTail.micro176.tac4 PTail.micro176.tac5 PTail.micro176.tac6 PTail.micro176.tac7
  PTail.micro176.tac8 PTail.micro176.tac9
tail_chunk_from P 176 := PTail.micro176.run

end Host.Load.Run.Full
