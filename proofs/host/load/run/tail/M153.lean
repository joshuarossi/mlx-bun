import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 153 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 153, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro153 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro153 0
host_chunk_read_tail_eager PTail.micro153 1
host_chunk_read_tail_eager PTail.micro153 2
host_chunk_read_tail_eager PTail.micro153 3
host_chunk_read_tail_eager PTail.micro153 4
host_chunk_read_tail_eager PTail.micro153 5
host_chunk_read_tail_eager PTail.micro153 6
host_chunk_read_tail_eager PTail.micro153 7
host_chunk_read_tail_eager PTail.micro153 8
host_chunk_read_tail_eager PTail.micro153 9
tail_compose PTail.micro153 PTail.micro153.run :=
  PTail.micro153.tac0 PTail.micro153.tac1 PTail.micro153.tac2 PTail.micro153.tac3 PTail.micro153.tac4 PTail.micro153.tac5 PTail.micro153.tac6 PTail.micro153.tac7
  PTail.micro153.tac8 PTail.micro153.tac9
tail_chunk_from P 153 := PTail.micro153.run

end Host.Load.Run.Full
