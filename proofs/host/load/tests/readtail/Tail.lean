import host.load.tests.readtail.G2
namespace Host.Load.Tests.ReadTail
host_read_tail P 0, 2 keep 1
set_option maxRecDepth 1000000 in
host_chunk_read_tail P 0
set_option maxRecDepth 1000000 in
host_chunk_read_tail P 1

set_option maxRecDepth 1000000 in
/-- The read consumes the known head and preserves every possible remaining queue. -/
theorem remaining_queue (tail : List Host.Ts.NumV) :
    (P.ta1 tail).aux.ffi.tokens = tail := rfl
end Host.Load.Tests.ReadTail
