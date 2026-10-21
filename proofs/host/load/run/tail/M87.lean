import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 87 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 87, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro87 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro87 0
host_chunk_read_tail_eager PTail.micro87 1
host_chunk_read_tail_eager PTail.micro87 2
host_chunk_read_tail_eager PTail.micro87 3
host_chunk_read_tail_eager PTail.micro87 4
host_chunk_read_tail_eager PTail.micro87 5
host_chunk_read_tail_eager PTail.micro87 6
host_chunk_read_tail_eager PTail.micro87 7
host_chunk_read_tail_eager PTail.micro87 8
host_chunk_read_tail_eager PTail.micro87 9
tail_compose PTail.micro87 PTail.micro87.run :=
  PTail.micro87.tac0 PTail.micro87.tac1 PTail.micro87.tac2 PTail.micro87.tac3 PTail.micro87.tac4 PTail.micro87.tac5 PTail.micro87.tac6 PTail.micro87.tac7
  PTail.micro87.tac8 PTail.micro87.tac9
tail_chunk_from P 87 := PTail.micro87.run

end Host.Load.Run.Full
