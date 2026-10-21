import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 246 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 246, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro246 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro246 0
host_chunk_read_tail_eager PTail.micro246 1
host_chunk_read_tail_eager PTail.micro246 2
host_chunk_read_tail_eager PTail.micro246 3
host_chunk_read_tail_eager PTail.micro246 4
host_chunk_read_tail_eager PTail.micro246 5
host_chunk_read_tail_eager PTail.micro246 6
host_chunk_read_tail_eager PTail.micro246 7
host_chunk_read_tail_eager PTail.micro246 8
host_chunk_read_tail_eager PTail.micro246 9
tail_compose PTail.micro246 PTail.micro246.run :=
  PTail.micro246.tac0 PTail.micro246.tac1 PTail.micro246.tac2 PTail.micro246.tac3 PTail.micro246.tac4 PTail.micro246.tac5 PTail.micro246.tac6 PTail.micro246.tac7
  PTail.micro246.tac8 PTail.micro246.tac9
tail_chunk_from P 246 := PTail.micro246.run

end Host.Load.Run.Full
