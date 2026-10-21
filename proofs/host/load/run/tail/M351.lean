import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 351 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 351, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro351 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro351 0
host_chunk_read_tail_eager PTail.micro351 1
host_chunk_read_tail_eager PTail.micro351 2
host_chunk_read_tail_eager PTail.micro351 3
host_chunk_read_tail_eager PTail.micro351 4
host_chunk_read_tail_eager PTail.micro351 5
host_chunk_read_tail_eager PTail.micro351 6
host_chunk_read_tail_eager PTail.micro351 7
host_chunk_read_tail_eager PTail.micro351 8
host_chunk_read_tail_eager PTail.micro351 9
tail_compose PTail.micro351 PTail.micro351.run :=
  PTail.micro351.tac0 PTail.micro351.tac1 PTail.micro351.tac2 PTail.micro351.tac3 PTail.micro351.tac4 PTail.micro351.tac5 PTail.micro351.tac6 PTail.micro351.tac7
  PTail.micro351.tac8 PTail.micro351.tac9
tail_chunk_from P 351 := PTail.micro351.run

end Host.Load.Run.Full
