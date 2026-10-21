import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 175 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 175, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro175 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro175 0
host_chunk_read_tail_eager PTail.micro175 1
host_chunk_read_tail_eager PTail.micro175 2
host_chunk_read_tail_eager PTail.micro175 3
host_chunk_read_tail_eager PTail.micro175 4
host_chunk_read_tail_eager PTail.micro175 5
host_chunk_read_tail_eager PTail.micro175 6
host_chunk_read_tail_eager PTail.micro175 7
host_chunk_read_tail_eager PTail.micro175 8
host_chunk_read_tail_eager PTail.micro175 9
tail_compose PTail.micro175 PTail.micro175.run :=
  PTail.micro175.tac0 PTail.micro175.tac1 PTail.micro175.tac2 PTail.micro175.tac3 PTail.micro175.tac4 PTail.micro175.tac5 PTail.micro175.tac6 PTail.micro175.tac7
  PTail.micro175.tac8 PTail.micro175.tac9
tail_chunk_from P 175 := PTail.micro175.run

end Host.Load.Run.Full
