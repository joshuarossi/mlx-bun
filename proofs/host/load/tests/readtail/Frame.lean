import host.load.tests.readtail.Tail
namespace Host.Load.Tests.ReadTail
host_forward_frame P 0, 2 array initialPair.1
set_option maxRecDepth 1000000 in
host_chunk_forward_frame P 0
set_option maxRecDepth 1000000 in
host_chunk_forward_frame P 1
end Host.Load.Tests.ReadTail
