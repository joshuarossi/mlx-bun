import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 71 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 71, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro71 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro71 0
host_chunk_read_tail_eager PTail.micro71 1
host_chunk_read_tail_eager PTail.micro71 2
host_chunk_read_tail_eager PTail.micro71 3
host_chunk_read_tail_eager PTail.micro71 4
host_chunk_read_tail_eager PTail.micro71 5
host_chunk_read_tail_eager PTail.micro71 6
host_chunk_read_tail_eager PTail.micro71 7
host_chunk_read_tail_eager PTail.micro71 8
host_chunk_read_tail_eager PTail.micro71 9
tail_compose PTail.micro71 PTail.micro71.run :=
  PTail.micro71.tac0 PTail.micro71.tac1 PTail.micro71.tac2 PTail.micro71.tac3 PTail.micro71.tac4 PTail.micro71.tac5 PTail.micro71.tac6 PTail.micro71.tac7
  PTail.micro71.tac8 PTail.micro71.tac9
tail_chunk_from P 71 := PTail.micro71.run

end Host.Load.Run.Full
