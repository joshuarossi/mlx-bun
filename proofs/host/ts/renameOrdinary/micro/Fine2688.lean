import host.ts.renameOrdinary.micro.Fine2688Tail
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_chunk_prefix_frames P.RestStream.micro0.micro2688 0
host_chunk_prefix_frames P.RestStream.micro0.micro2688 1
host_chunk_prefix_frames P.RestStream.micro0.micro2688 2
host_chunk_prefix_frames P.RestStream.micro0.micro2688 3
host_chunk_prefix_frames P.RestStream.micro0.micro2688 4
host_chunk_prefix_frames P.RestStream.micro0.micro2688 5
host_chunk_prefix_frames P.RestStream.micro0.micro2688 6
host_chunk_prefix_frames P.RestStream.micro0.micro2688 7
host_chunk_prefix_frames P.RestStream.micro0.micro2688 8
host_chain_prefix_frames P.RestStream.micro0.micro2688 0, 10
end Host.Load.Run.Full
namespace Host.Load.Run.Full.P.RestStream.micro0
open Host.Ts
theorem pfac2688 (fw : List Val) (tail : List NumV) :
 runS F 100 (pfa2688 fw tail) S2688 = some (pfa2689 fw tail,S2689) :=
 micro2688.prefixRun0_10 fw tail
theorem pftc2688 : runS F 100 s2688 S2688 = some (s2689,S2689) :=
 pfac2688 prefixBase tokenBase
end Host.Load.Run.Full.P.RestStream.micro0
