import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 386 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 386, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro386 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro386 0
host_chunk_read_tail_eager PTail.micro386 1
host_chunk_read_tail_eager PTail.micro386 2
host_chunk_read_tail_eager PTail.micro386 3
host_chunk_read_tail_eager PTail.micro386 4
host_chunk_read_tail_eager PTail.micro386 5
host_chunk_read_tail_eager PTail.micro386 6
host_chunk_read_tail_eager PTail.micro386 7
host_chunk_read_tail_eager PTail.micro386 8
host_chunk_read_tail_eager PTail.micro386 9
tail_compose PTail.micro386 PTail.micro386.run :=
  PTail.micro386.tac0 PTail.micro386.tac1 PTail.micro386.tac2 PTail.micro386.tac3 PTail.micro386.tac4 PTail.micro386.tac5 PTail.micro386.tac6 PTail.micro386.tac7
  PTail.micro386.tac8 PTail.micro386.tac9
tail_chunk_from P 386 := PTail.micro386.run

end Host.Load.Run.Full
