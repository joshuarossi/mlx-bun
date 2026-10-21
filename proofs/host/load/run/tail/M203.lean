import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 203 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 203, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro203 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro203 0
host_chunk_read_tail_eager PTail.micro203 1
host_chunk_read_tail_eager PTail.micro203 2
host_chunk_read_tail_eager PTail.micro203 3
host_chunk_read_tail_eager PTail.micro203 4
host_chunk_read_tail_eager PTail.micro203 5
host_chunk_read_tail_eager PTail.micro203 6
host_chunk_read_tail_eager PTail.micro203 7
host_chunk_read_tail_eager PTail.micro203 8
host_chunk_read_tail_eager PTail.micro203 9
tail_compose PTail.micro203 PTail.micro203.run :=
  PTail.micro203.tac0 PTail.micro203.tac1 PTail.micro203.tac2 PTail.micro203.tac3 PTail.micro203.tac4 PTail.micro203.tac5 PTail.micro203.tac6 PTail.micro203.tac7
  PTail.micro203.tac8 PTail.micro203.tac9
tail_chunk_from P 203 := PTail.micro203.run

end Host.Load.Run.Full
