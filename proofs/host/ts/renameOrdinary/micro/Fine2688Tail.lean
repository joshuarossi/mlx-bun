import host.ts.renameOrdinary.micro.Fine2688Base
import host.ts.renameOrdinary.micro.Fine2688TailStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_read_tail P.RestStream.micro0.micro2688.micro9 0, 10 keep 0
host_prefix_frames P.RestStream.micro0.micro2688.micro9 0, 10 arrays [2673447,12502]
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 0
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 1
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 2
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 3
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 4
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 5
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 6
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 7
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 8
host_chunk_prefix_frames P.RestStream.micro0.micro2688.micro9 9
host_chain_prefix_frames P.RestStream.micro0.micro2688.micro9 0, 10
end Host.Load.Run.Full
namespace Host.Load.Run.Full.P.RestStream.micro0.micro2688
open Host.Ts
theorem pfac9 (fw : List Val) (tail : List NumV) :
 runS F 10 (pfa9 fw tail) S9 = some (pfa10 fw tail,S10) :=
 micro9.prefixRun0_10 fw tail
end Host.Load.Run.Full.P.RestStream.micro0.micro2688
