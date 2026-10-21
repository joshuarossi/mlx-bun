import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 88 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 88, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro88 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro88 0
host_chunk_read_tail_eager PTail.micro88 1
host_chunk_read_tail_eager PTail.micro88 2
host_chunk_read_tail_eager PTail.micro88 3
host_chunk_read_tail_eager PTail.micro88 4
host_chunk_read_tail_eager PTail.micro88 5
host_chunk_read_tail_eager PTail.micro88 6
host_chunk_read_tail_eager PTail.micro88 7
host_chunk_read_tail_eager PTail.micro88 8
host_chunk_read_tail_eager PTail.micro88 9
tail_compose PTail.micro88 PTail.micro88.run :=
  PTail.micro88.tac0 PTail.micro88.tac1 PTail.micro88.tac2 PTail.micro88.tac3 PTail.micro88.tac4 PTail.micro88.tac5 PTail.micro88.tac6 PTail.micro88.tac7
  PTail.micro88.tac8 PTail.micro88.tac9
tail_chunk_from P 88 := PTail.micro88.run

end Host.Load.Run.Full
