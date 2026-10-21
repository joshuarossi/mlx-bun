import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 400 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 400, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro400 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro400 0
host_chunk_read_tail_eager PTail.micro400 1
host_chunk_read_tail_eager PTail.micro400 2
host_chunk_read_tail_eager PTail.micro400 3
host_chunk_read_tail_eager PTail.micro400 4
host_chunk_read_tail_eager PTail.micro400 5
host_chunk_read_tail_eager PTail.micro400 6
host_chunk_read_tail_eager PTail.micro400 7
host_chunk_read_tail_eager PTail.micro400 8
host_chunk_read_tail_eager PTail.micro400 9
tail_compose PTail.micro400 PTail.micro400.run :=
  PTail.micro400.tac0 PTail.micro400.tac1 PTail.micro400.tac2 PTail.micro400.tac3 PTail.micro400.tac4 PTail.micro400.tac5 PTail.micro400.tac6 PTail.micro400.tac7
  PTail.micro400.tac8 PTail.micro400.tac9
tail_chunk_from P 400 := PTail.micro400.run

end Host.Load.Run.Full
