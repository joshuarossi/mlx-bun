import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 190 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 190, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro190 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro190 0
host_chunk_read_tail_eager PTail.micro190 1
host_chunk_read_tail_eager PTail.micro190 2
host_chunk_read_tail_eager PTail.micro190 3
host_chunk_read_tail_eager PTail.micro190 4
host_chunk_read_tail_eager PTail.micro190 5
host_chunk_read_tail_eager PTail.micro190 6
host_chunk_read_tail_eager PTail.micro190 7
host_chunk_read_tail_eager PTail.micro190 8
host_chunk_read_tail_eager PTail.micro190 9
tail_compose PTail.micro190 PTail.micro190.run :=
  PTail.micro190.tac0 PTail.micro190.tac1 PTail.micro190.tac2 PTail.micro190.tac3 PTail.micro190.tac4 PTail.micro190.tac5 PTail.micro190.tac6 PTail.micro190.tac7
  PTail.micro190.tac8 PTail.micro190.tac9
tail_chunk_from P 190 := PTail.micro190.run

end Host.Load.Run.Full
