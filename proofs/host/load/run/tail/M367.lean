import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 367 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 367, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro367 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro367 0
host_chunk_read_tail_eager PTail.micro367 1
host_chunk_read_tail_eager PTail.micro367 2
host_chunk_read_tail_eager PTail.micro367 3
host_chunk_read_tail_eager PTail.micro367 4
host_chunk_read_tail_eager PTail.micro367 5
host_chunk_read_tail_eager PTail.micro367 6
host_chunk_read_tail_eager PTail.micro367 7
host_chunk_read_tail_eager PTail.micro367 8
host_chunk_read_tail_eager PTail.micro367 9
tail_compose PTail.micro367 PTail.micro367.run :=
  PTail.micro367.tac0 PTail.micro367.tac1 PTail.micro367.tac2 PTail.micro367.tac3 PTail.micro367.tac4 PTail.micro367.tac5 PTail.micro367.tac6 PTail.micro367.tac7
  PTail.micro367.tac8 PTail.micro367.tac9
tail_chunk_from P 367 := PTail.micro367.run

end Host.Load.Run.Full
