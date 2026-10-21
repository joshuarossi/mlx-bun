import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 396 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 396, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro396 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro396 0
host_chunk_read_tail_eager PTail.micro396 1
host_chunk_read_tail_eager PTail.micro396 2
host_chunk_read_tail_eager PTail.micro396 3
host_chunk_read_tail_eager PTail.micro396 4
host_chunk_read_tail_eager PTail.micro396 5
host_chunk_read_tail_eager PTail.micro396 6
host_chunk_read_tail_eager PTail.micro396 7
host_chunk_read_tail_eager PTail.micro396 8
host_chunk_read_tail_eager PTail.micro396 9
tail_compose PTail.micro396 PTail.micro396.run :=
  PTail.micro396.tac0 PTail.micro396.tac1 PTail.micro396.tac2 PTail.micro396.tac3 PTail.micro396.tac4 PTail.micro396.tac5 PTail.micro396.tac6 PTail.micro396.tac7
  PTail.micro396.tac8 PTail.micro396.tac9
tail_chunk_from P 396 := PTail.micro396.run

end Host.Load.Run.Full
