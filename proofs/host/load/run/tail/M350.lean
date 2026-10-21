import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 350 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 350, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro350 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro350 0
host_chunk_read_tail_eager PTail.micro350 1
host_chunk_read_tail_eager PTail.micro350 2
host_chunk_read_tail_eager PTail.micro350 3
host_chunk_read_tail_eager PTail.micro350 4
host_chunk_read_tail_eager PTail.micro350 5
host_chunk_read_tail_eager PTail.micro350 6
host_chunk_read_tail_eager PTail.micro350 7
host_chunk_read_tail_eager PTail.micro350 8
host_chunk_read_tail_eager PTail.micro350 9
tail_compose PTail.micro350 PTail.micro350.run :=
  PTail.micro350.tac0 PTail.micro350.tac1 PTail.micro350.tac2 PTail.micro350.tac3 PTail.micro350.tac4 PTail.micro350.tac5 PTail.micro350.tac6 PTail.micro350.tac7
  PTail.micro350.tac8 PTail.micro350.tac9
tail_chunk_from P 350 := PTail.micro350.run

end Host.Load.Run.Full
