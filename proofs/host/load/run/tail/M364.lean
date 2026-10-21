import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 364 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 364, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro364 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro364 0
host_chunk_read_tail_eager PTail.micro364 1
host_chunk_read_tail_eager PTail.micro364 2
host_chunk_read_tail_eager PTail.micro364 3
host_chunk_read_tail_eager PTail.micro364 4
host_chunk_read_tail_eager PTail.micro364 5
host_chunk_read_tail_eager PTail.micro364 6
host_chunk_read_tail_eager PTail.micro364 7
host_chunk_read_tail_eager PTail.micro364 8
host_chunk_read_tail_eager PTail.micro364 9
tail_compose PTail.micro364 PTail.micro364.run :=
  PTail.micro364.tac0 PTail.micro364.tac1 PTail.micro364.tac2 PTail.micro364.tac3 PTail.micro364.tac4 PTail.micro364.tac5 PTail.micro364.tac6 PTail.micro364.tac7
  PTail.micro364.tac8 PTail.micro364.tac9
tail_chunk_from P 364 := PTail.micro364.run

end Host.Load.Run.Full
