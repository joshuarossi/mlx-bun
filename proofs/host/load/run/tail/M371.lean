import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 371 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 371, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro371 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro371 0
host_chunk_read_tail_eager PTail.micro371 1
host_chunk_read_tail_eager PTail.micro371 2
host_chunk_read_tail_eager PTail.micro371 3
host_chunk_read_tail_eager PTail.micro371 4
host_chunk_read_tail_eager PTail.micro371 5
host_chunk_read_tail_eager PTail.micro371 6
host_chunk_read_tail_eager PTail.micro371 7
host_chunk_read_tail_eager PTail.micro371 8
host_chunk_read_tail_eager PTail.micro371 9
tail_compose PTail.micro371 PTail.micro371.run :=
  PTail.micro371.tac0 PTail.micro371.tac1 PTail.micro371.tac2 PTail.micro371.tac3 PTail.micro371.tac4 PTail.micro371.tac5 PTail.micro371.tac6 PTail.micro371.tac7
  PTail.micro371.tac8 PTail.micro371.tac9
tail_chunk_from P 371 := PTail.micro371.run

end Host.Load.Run.Full
