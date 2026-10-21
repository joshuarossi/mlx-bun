import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 381 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 381, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro381 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro381 0
host_chunk_read_tail_eager PTail.micro381 1
host_chunk_read_tail_eager PTail.micro381 2
host_chunk_read_tail_eager PTail.micro381 3
host_chunk_read_tail_eager PTail.micro381 4
host_chunk_read_tail_eager PTail.micro381 5
host_chunk_read_tail_eager PTail.micro381 6
host_chunk_read_tail_eager PTail.micro381 7
host_chunk_read_tail_eager PTail.micro381 8
host_chunk_read_tail_eager PTail.micro381 9
tail_compose PTail.micro381 PTail.micro381.run :=
  PTail.micro381.tac0 PTail.micro381.tac1 PTail.micro381.tac2 PTail.micro381.tac3 PTail.micro381.tac4 PTail.micro381.tac5 PTail.micro381.tac6 PTail.micro381.tac7
  PTail.micro381.tac8 PTail.micro381.tac9
tail_chunk_from P 381 := PTail.micro381.run

end Host.Load.Run.Full
