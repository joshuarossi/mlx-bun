import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 215 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 215, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro215 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro215 0
host_chunk_read_tail_eager PTail.micro215 1
host_chunk_read_tail_eager PTail.micro215 2
host_chunk_read_tail_eager PTail.micro215 3
host_chunk_read_tail_eager PTail.micro215 4
host_chunk_read_tail_eager PTail.micro215 5
host_chunk_read_tail_eager PTail.micro215 6
host_chunk_read_tail_eager PTail.micro215 7
host_chunk_read_tail_eager PTail.micro215 8
host_chunk_read_tail_eager PTail.micro215 9
tail_compose PTail.micro215 PTail.micro215.run :=
  PTail.micro215.tac0 PTail.micro215.tac1 PTail.micro215.tac2 PTail.micro215.tac3 PTail.micro215.tac4 PTail.micro215.tac5 PTail.micro215.tac6 PTail.micro215.tac7
  PTail.micro215.tac8 PTail.micro215.tac9
tail_chunk_from P 215 := PTail.micro215.run

end Host.Load.Run.Full
