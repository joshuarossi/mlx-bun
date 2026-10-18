import host.ts.renameOrdinary.WeightByteCountPath
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
host_transport_step P.F, P.RestStream.micro0.micro5.s42 to P.RestStream.micro0.micro5.s43 as BufferPointer
host_transport_structural P.F, P.RestStream.micro0.micro5.s43 to P.RestStream.micro0.micro5.s44 as PointerArgument
host_transport_step P.F, P.RestStream.micro0.micro5.s44 to P.RestStream.micro0.micro5.s45 as BufferZero
host_transport_structural P.F, P.RestStream.micro0.micro5.s45 to P.RestStream.micro0.micro5.s46 as ZeroArgument
host_transport_structural P.F, P.RestStream.micro0.micro5.s51 to P.RestStream.micro0.micro5.s52 as CountArgument
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
