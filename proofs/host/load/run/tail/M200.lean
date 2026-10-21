import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 200 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 200, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro200 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro200 0
host_chunk_read_tail_eager PTail.micro200 1
host_chunk_read_tail_eager PTail.micro200 2
host_chunk_read_tail_eager PTail.micro200 3
host_chunk_read_tail_eager PTail.micro200 4
host_chunk_read_tail_eager PTail.micro200 5
host_chunk_read_tail_eager PTail.micro200 6
host_chunk_read_tail_eager PTail.micro200 7
host_chunk_read_tail_eager PTail.micro200 8
host_chunk_read_tail_eager PTail.micro200 9
tail_compose PTail.micro200 PTail.micro200.run :=
  PTail.micro200.tac0 PTail.micro200.tac1 PTail.micro200.tac2 PTail.micro200.tac3 PTail.micro200.tac4 PTail.micro200.tac5 PTail.micro200.tac6 PTail.micro200.tac7
  PTail.micro200.tac8 PTail.micro200.tac9
tail_chunk_from P 200 := PTail.micro200.run

end Host.Load.Run.Full
