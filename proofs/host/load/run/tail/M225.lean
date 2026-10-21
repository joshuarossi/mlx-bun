import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 225 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 225, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro225 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro225 0
host_chunk_read_tail_eager PTail.micro225 1
host_chunk_read_tail_eager PTail.micro225 2
host_chunk_read_tail_eager PTail.micro225 3
host_chunk_read_tail_eager PTail.micro225 4
host_chunk_read_tail_eager PTail.micro225 5
host_chunk_read_tail_eager PTail.micro225 6
host_chunk_read_tail_eager PTail.micro225 7
host_chunk_read_tail_eager PTail.micro225 8
host_chunk_read_tail_eager PTail.micro225 9
tail_compose PTail.micro225 PTail.micro225.run :=
  PTail.micro225.tac0 PTail.micro225.tac1 PTail.micro225.tac2 PTail.micro225.tac3 PTail.micro225.tac4 PTail.micro225.tac5 PTail.micro225.tac6 PTail.micro225.tac7
  PTail.micro225.tac8 PTail.micro225.tac9
tail_chunk_from P 225 := PTail.micro225.run

end Host.Load.Run.Full
