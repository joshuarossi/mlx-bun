import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 155 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 155, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro155 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro155 0
host_chunk_read_tail_eager PTail.micro155 1
host_chunk_read_tail_eager PTail.micro155 2
host_chunk_read_tail_eager PTail.micro155 3
host_chunk_read_tail_eager PTail.micro155 4
host_chunk_read_tail_eager PTail.micro155 5
host_chunk_read_tail_eager PTail.micro155 6
host_chunk_read_tail_eager PTail.micro155 7
host_chunk_read_tail_eager PTail.micro155 8
host_chunk_read_tail_eager PTail.micro155 9
tail_compose PTail.micro155 PTail.micro155.run :=
  PTail.micro155.tac0 PTail.micro155.tac1 PTail.micro155.tac2 PTail.micro155.tac3 PTail.micro155.tac4 PTail.micro155.tac5 PTail.micro155.tac6 PTail.micro155.tac7
  PTail.micro155.tac8 PTail.micro155.tac9
tail_chunk_from P 155 := PTail.micro155.run

end Host.Load.Run.Full
