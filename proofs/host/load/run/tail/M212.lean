import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 212 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 212, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro212 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro212 0
host_chunk_read_tail_eager PTail.micro212 1
host_chunk_read_tail_eager PTail.micro212 2
host_chunk_read_tail_eager PTail.micro212 3
host_chunk_read_tail_eager PTail.micro212 4
host_chunk_read_tail_eager PTail.micro212 5
host_chunk_read_tail_eager PTail.micro212 6
host_chunk_read_tail_eager PTail.micro212 7
host_chunk_read_tail_eager PTail.micro212 8
host_chunk_read_tail_eager PTail.micro212 9
tail_compose PTail.micro212 PTail.micro212.run :=
  PTail.micro212.tac0 PTail.micro212.tac1 PTail.micro212.tac2 PTail.micro212.tac3 PTail.micro212.tac4 PTail.micro212.tac5 PTail.micro212.tac6 PTail.micro212.tac7
  PTail.micro212.tac8 PTail.micro212.tac9
tail_chunk_from P 212 := PTail.micro212.run

end Host.Load.Run.Full
