import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 401 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 401, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro401 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro401 0
host_chunk_read_tail_eager PTail.micro401 1
host_chunk_read_tail_eager PTail.micro401 2
host_chunk_read_tail_eager PTail.micro401 3
host_chunk_read_tail_eager PTail.micro401 4
host_chunk_read_tail_eager PTail.micro401 5
host_chunk_read_tail_eager PTail.micro401 6
host_chunk_read_tail_eager PTail.micro401 7
host_chunk_read_tail_eager PTail.micro401 8
host_chunk_read_tail_eager PTail.micro401 9
tail_compose PTail.micro401 PTail.micro401.run :=
  PTail.micro401.tac0 PTail.micro401.tac1 PTail.micro401.tac2 PTail.micro401.tac3 PTail.micro401.tac4 PTail.micro401.tac5 PTail.micro401.tac6 PTail.micro401.tac7
  PTail.micro401.tac8 PTail.micro401.tac9
tail_chunk_from P 401 := PTail.micro401.run

end Host.Load.Run.Full
