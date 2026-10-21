import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 242 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 242, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro242 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro242 0
host_chunk_read_tail_eager PTail.micro242 1
host_chunk_read_tail_eager PTail.micro242 2
host_chunk_read_tail_eager PTail.micro242 3
host_chunk_read_tail_eager PTail.micro242 4
host_chunk_read_tail_eager PTail.micro242 5
host_chunk_read_tail_eager PTail.micro242 6
host_chunk_read_tail_eager PTail.micro242 7
host_chunk_read_tail_eager PTail.micro242 8
host_chunk_read_tail_eager PTail.micro242 9
tail_compose PTail.micro242 PTail.micro242.run :=
  PTail.micro242.tac0 PTail.micro242.tac1 PTail.micro242.tac2 PTail.micro242.tac3 PTail.micro242.tac4 PTail.micro242.tac5 PTail.micro242.tac6 PTail.micro242.tac7
  PTail.micro242.tac8 PTail.micro242.tac9
tail_chunk_from P 242 := PTail.micro242.run

end Host.Load.Run.Full
