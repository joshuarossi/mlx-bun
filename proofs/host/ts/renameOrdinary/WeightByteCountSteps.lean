import host.ts.renameOrdinary.WeightShapeSteps
import host.ts.RenameRouteDriverArithmetic
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
host_transport_structural P.F, P.RestStream.micro0.micro5.s46 to P.RestStream.micro0.micro5.s47 as ByteBinary
host_transport_step P.F, P.RestStream.micro0.micro5.s47 to P.RestStream.micro0.micro5.s48 as ByteRank
host_transport_structural P.F, P.RestStream.micro0.micro5.s48 to P.RestStream.micro0.micro5.s49 as ByteLeft
host_transport_step P.F, P.RestStream.micro0.micro5.s49 to P.RestStream.micro0.micro5.s50 as ByteFour
host_transport_arithmetic P.F, P.RestStream.micro0.micro5.s50 to P.RestStream.micro0.micro5.s51 as ByteMultiply
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
