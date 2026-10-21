import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 166 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 166, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro166 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro166 0
host_chunk_read_tail_eager PTail.micro166 1
host_chunk_read_tail_eager PTail.micro166 2
host_chunk_read_tail_eager PTail.micro166 3
host_chunk_read_tail_eager PTail.micro166 4
host_chunk_read_tail_eager PTail.micro166 5
host_chunk_read_tail_eager PTail.micro166 6
host_chunk_read_tail_eager PTail.micro166 7
host_chunk_read_tail_eager PTail.micro166 8
host_chunk_read_tail_eager PTail.micro166 9
tail_compose PTail.micro166 PTail.micro166.run :=
  PTail.micro166.tac0 PTail.micro166.tac1 PTail.micro166.tac2 PTail.micro166.tac3 PTail.micro166.tac4 PTail.micro166.tac5 PTail.micro166.tac6 PTail.micro166.tac7
  PTail.micro166.tac8 PTail.micro166.tac9
tail_chunk_from P 166 := PTail.micro166.run

end Host.Load.Run.Full
