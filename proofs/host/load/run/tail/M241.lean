import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 241 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 241, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro241 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro241 0
host_chunk_read_tail_eager PTail.micro241 1
host_chunk_read_tail_eager PTail.micro241 2
host_chunk_read_tail_eager PTail.micro241 3
host_chunk_read_tail_eager PTail.micro241 4
host_chunk_read_tail_eager PTail.micro241 5
host_chunk_read_tail_eager PTail.micro241 6
host_chunk_read_tail_eager PTail.micro241 7
host_chunk_read_tail_eager PTail.micro241 8
host_chunk_read_tail_eager PTail.micro241 9
tail_compose PTail.micro241 PTail.micro241.run :=
  PTail.micro241.tac0 PTail.micro241.tac1 PTail.micro241.tac2 PTail.micro241.tac3 PTail.micro241.tac4 PTail.micro241.tac5 PTail.micro241.tac6 PTail.micro241.tac7
  PTail.micro241.tac8 PTail.micro241.tac9
tail_chunk_from P 241 := PTail.micro241.run

end Host.Load.Run.Full
