import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 75 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 75, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro75 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro75 0
host_chunk_read_tail_eager PTail.micro75 1
host_chunk_read_tail_eager PTail.micro75 2
host_chunk_read_tail_eager PTail.micro75 3
host_chunk_read_tail_eager PTail.micro75 4
host_chunk_read_tail_eager PTail.micro75 5
host_chunk_read_tail_eager PTail.micro75 6
host_chunk_read_tail_eager PTail.micro75 7
host_chunk_read_tail_eager PTail.micro75 8
host_chunk_read_tail_eager PTail.micro75 9
tail_compose PTail.micro75 PTail.micro75.run :=
  PTail.micro75.tac0 PTail.micro75.tac1 PTail.micro75.tac2 PTail.micro75.tac3 PTail.micro75.tac4 PTail.micro75.tac5 PTail.micro75.tac6 PTail.micro75.tac7
  PTail.micro75.tac8 PTail.micro75.tac9
tail_chunk_from P 75 := PTail.micro75.run

end Host.Load.Run.Full
