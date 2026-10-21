import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 143 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 143, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro143 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro143 0
host_chunk_read_tail_eager PTail.micro143 1
host_chunk_read_tail_eager PTail.micro143 2
host_chunk_read_tail_eager PTail.micro143 3
host_chunk_read_tail_eager PTail.micro143 4
host_chunk_read_tail_eager PTail.micro143 5
host_chunk_read_tail_eager PTail.micro143 6
host_chunk_read_tail_eager PTail.micro143 7
host_chunk_read_tail_eager PTail.micro143 8
host_chunk_read_tail_eager PTail.micro143 9
tail_compose PTail.micro143 PTail.micro143.run :=
  PTail.micro143.tac0 PTail.micro143.tac1 PTail.micro143.tac2 PTail.micro143.tac3 PTail.micro143.tac4 PTail.micro143.tac5 PTail.micro143.tac6 PTail.micro143.tac7
  PTail.micro143.tac8 PTail.micro143.tac9
tail_chunk_from P 143 := PTail.micro143.run

end Host.Load.Run.Full
