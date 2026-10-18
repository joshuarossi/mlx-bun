import host.ts.renameOrdinary.ConvTailSetupPath
import host.ts.RenameRouteDriverReads
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_structural P.F, P.RestStream.micro0.micro4.s40 to P.RestStream.micro0.micro4.s41 as ConvLengthExpression440
host_transport_structural P.F, P.RestStream.micro0.micro4.s41 to P.RestStream.micro0.micro4.s42 as ConvWeightIndex441
host_transport_structural P.F, P.RestStream.micro0.micro4.s42 to P.RestStream.micro0.micro4.s43 as ConvWeightShape442
host_transport_step P.F, P.RestStream.micro0.micro4.s43 to P.RestStream.micro0.micro4.s44 as ConvWeightVariable443
host_transport_read P.F, P.RestStream.micro0.micro4.s44 to P.RestStream.micro0.micro4.s45 as ConvWeightGetter444
end Host.Load.Run.Full.Ordinary.VectorToConcat
