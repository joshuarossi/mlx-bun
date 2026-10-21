import host.load.run.tail.Short2Stream
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_stream_state Short2 0
host_stream_state Short2 1
host_stream_state Short2 2
host_chunk Short2 0
host_chunk Short2 1
host_chain_run Short2

end Host.Load.Run.Full
