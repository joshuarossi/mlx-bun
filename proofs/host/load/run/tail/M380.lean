import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 380 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 380, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro380 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro380 0
host_chunk_read_tail_eager PTail.micro380 1
host_chunk_read_tail_eager PTail.micro380 2
host_chunk_read_tail_eager PTail.micro380 3
host_chunk_read_tail_eager PTail.micro380 4
host_chunk_read_tail_eager PTail.micro380 5
host_chunk_read_tail_eager PTail.micro380 6
host_chunk_read_tail_eager PTail.micro380 7
host_chunk_read_tail_eager PTail.micro380 8
host_chunk_read_tail_eager PTail.micro380 9
tail_compose PTail.micro380 PTail.micro380.run :=
  PTail.micro380.tac0 PTail.micro380.tac1 PTail.micro380.tac2 PTail.micro380.tac3 PTail.micro380.tac4 PTail.micro380.tac5 PTail.micro380.tac6 PTail.micro380.tac7
  PTail.micro380.tac8 PTail.micro380.tac9
tail_chunk_from P 380 := PTail.micro380.run

end Host.Load.Run.Full
