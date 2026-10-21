import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 220 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 220, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro220 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro220 0
host_chunk_read_tail_eager PTail.micro220 1
host_chunk_read_tail_eager PTail.micro220 2
host_chunk_read_tail_eager PTail.micro220 3
host_chunk_read_tail_eager PTail.micro220 4
host_chunk_read_tail_eager PTail.micro220 5
host_chunk_read_tail_eager PTail.micro220 6
host_chunk_read_tail_eager PTail.micro220 7
host_chunk_read_tail_eager PTail.micro220 8
host_chunk_read_tail_eager PTail.micro220 9
tail_compose PTail.micro220 PTail.micro220.run :=
  PTail.micro220.tac0 PTail.micro220.tac1 PTail.micro220.tac2 PTail.micro220.tac3 PTail.micro220.tac4 PTail.micro220.tac5 PTail.micro220.tac6 PTail.micro220.tac7
  PTail.micro220.tac8 PTail.micro220.tac9
tail_chunk_from P 220 := PTail.micro220.run

end Host.Load.Run.Full
