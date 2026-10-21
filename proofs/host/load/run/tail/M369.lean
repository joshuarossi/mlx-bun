import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 369 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 369, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro369 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro369 0
host_chunk_read_tail_eager PTail.micro369 1
host_chunk_read_tail_eager PTail.micro369 2
host_chunk_read_tail_eager PTail.micro369 3
host_chunk_read_tail_eager PTail.micro369 4
host_chunk_read_tail_eager PTail.micro369 5
host_chunk_read_tail_eager PTail.micro369 6
host_chunk_read_tail_eager PTail.micro369 7
host_chunk_read_tail_eager PTail.micro369 8
host_chunk_read_tail_eager PTail.micro369 9
tail_compose PTail.micro369 PTail.micro369.run :=
  PTail.micro369.tac0 PTail.micro369.tac1 PTail.micro369.tac2 PTail.micro369.tac3 PTail.micro369.tac4 PTail.micro369.tac5 PTail.micro369.tac6 PTail.micro369.tac7
  PTail.micro369.tac8 PTail.micro369.tac9
tail_chunk_from P 369 := PTail.micro369.run

end Host.Load.Run.Full
