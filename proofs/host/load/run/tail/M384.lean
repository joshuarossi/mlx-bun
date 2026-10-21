import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 384 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 384, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro384 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro384 0
host_chunk_read_tail_eager PTail.micro384 1
host_chunk_read_tail_eager PTail.micro384 2
host_chunk_read_tail_eager PTail.micro384 3
host_chunk_read_tail_eager PTail.micro384 4
host_chunk_read_tail_eager PTail.micro384 5
host_chunk_read_tail_eager PTail.micro384 6
host_chunk_read_tail_eager PTail.micro384 7
host_chunk_read_tail_eager PTail.micro384 8
host_chunk_read_tail_eager PTail.micro384 9
tail_compose PTail.micro384 PTail.micro384.run :=
  PTail.micro384.tac0 PTail.micro384.tac1 PTail.micro384.tac2 PTail.micro384.tac3 PTail.micro384.tac4 PTail.micro384.tac5 PTail.micro384.tac6 PTail.micro384.tac7
  PTail.micro384.tac8 PTail.micro384.tac9
tail_chunk_from P 384 := PTail.micro384.run

end Host.Load.Run.Full
