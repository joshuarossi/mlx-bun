import host.ts.RenameRouteDriverStructural
import host.ts.renameOrdinary.HostCuts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
host_transport_structural P.F, P.RestStream.micro0.micro0.s1 to P.RestStream.micro0.micro0.s2 as Structural1
host_transport_structural P.F, P.RestStream.micro0.micro0.s3 to P.RestStream.micro0.micro0.s4 as Structural3
host_transport_structural P.F, P.RestStream.micro0.micro0.s4 to P.RestStream.micro0.micro0.s5 as Structural4
host_transport_structural P.F, P.RestStream.micro0.micro0.s6 to P.RestStream.micro0.micro0.s7 as Structural6
/-- error: host_transport_structural: unsupported expression frame Host.Ts.ExprF.binR -/
#guard_msgs in
host_transport_structural P.F, P.RestStream.micro0.micro0.s8 to P.RestStream.micro0.micro0.s9 as UnsupportedBinaryRight
end Host.Load.Run.Full.Ordinary
