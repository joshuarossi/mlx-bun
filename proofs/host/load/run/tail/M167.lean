import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 167 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 167, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro167 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro167 0
host_chunk_read_tail_eager PTail.micro167 1
host_chunk_read_tail_eager PTail.micro167 2
host_chunk_read_tail_eager PTail.micro167 3
host_chunk_read_tail_eager PTail.micro167 4
host_chunk_read_tail_eager PTail.micro167 5
host_chunk_read_tail_eager PTail.micro167 6
host_chunk_read_tail_eager PTail.micro167 7
host_chunk_read_tail_eager PTail.micro167 8
host_chunk_read_tail_eager PTail.micro167 9
tail_compose PTail.micro167 PTail.micro167.run :=
  PTail.micro167.tac0 PTail.micro167.tac1 PTail.micro167.tac2 PTail.micro167.tac3 PTail.micro167.tac4 PTail.micro167.tac5 PTail.micro167.tac6 PTail.micro167.tac7
  PTail.micro167.tac8 PTail.micro167.tac9
tail_chunk_from P 167 := PTail.micro167.run

end Host.Load.Run.Full
