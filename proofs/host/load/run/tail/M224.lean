import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 224 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 224, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro224 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro224 0
host_chunk_read_tail_eager PTail.micro224 1
host_chunk_read_tail_eager PTail.micro224 2
host_chunk_read_tail_eager PTail.micro224 3
host_chunk_read_tail_eager PTail.micro224 4
host_chunk_read_tail_eager PTail.micro224 5
host_chunk_read_tail_eager PTail.micro224 6
host_chunk_read_tail_eager PTail.micro224 7
host_chunk_read_tail_eager PTail.micro224 8
host_chunk_read_tail_eager PTail.micro224 9
tail_compose PTail.micro224 PTail.micro224.run :=
  PTail.micro224.tac0 PTail.micro224.tac1 PTail.micro224.tac2 PTail.micro224.tac3 PTail.micro224.tac4 PTail.micro224.tac5 PTail.micro224.tac6 PTail.micro224.tac7
  PTail.micro224.tac8 PTail.micro224.tac9
tail_chunk_from P 224 := PTail.micro224.run

end Host.Load.Run.Full
