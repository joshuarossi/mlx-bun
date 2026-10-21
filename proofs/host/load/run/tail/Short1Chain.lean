import host.load.run.tail.Short1Stream
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_stream_state Short1 0
host_stream_state Short1 1
host_stream_state Short1 2
host_stream_state Short1 3
host_stream_state Short1 4
host_chunk Short1 0
host_chunk Short1 1
host_chunk Short1 2
host_chunk Short1 3
host_chain_run Short1

end Host.Load.Run.Full
