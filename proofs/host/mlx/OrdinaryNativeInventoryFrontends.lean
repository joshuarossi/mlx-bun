import host.mlx.NativeInventoryFrontends
import host.ts.renameOrdinary.HostCuts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.NativeInventoryCases

/-- error: host_retained_arrayBuffer: expected source native call -/
#guard_msgs in
host_retained_arrayBuffer P.F, P.RestStream.micro0.micro0.s12 using P.RestStream.micro0.micro0.S12
  to P.RestStream.micro0.micro0.s13 using P.RestStream.micro0.micro0.S13 as RejectConstruct

/-- error: host_retained_typedBuffer: expected source construct -/
#guard_msgs in
host_retained_typedBuffer P.F, P.RestStream.micro0.micro0.s10 using P.RestStream.micro0.micro0.S10
  to P.RestStream.micro0.micro0.s11 using P.RestStream.micro0.micro0.S11 as RejectCall

host_retained_arrayBuffer P.F, P.RestStream.micro0.micro0.s10 using P.RestStream.micro0.micro0.S10
  to P.RestStream.micro0.micro0.s11 using P.RestStream.micro0.micro0.S11 as Source10

host_retained_typedBuffer P.F, P.RestStream.micro0.micro0.s12 using P.RestStream.micro0.micro0.S12
  to P.RestStream.micro0.micro0.s13 using P.RestStream.micro0.micro0.S13 as Source12

host_retained_shapeSpread P.F, P.RestStream.micro0.micro0.s13 using P.RestStream.micro0.micro0.S13
  to P.RestStream.micro0.micro0.s14 using P.RestStream.micro0.micro0.S14 as Source13

end Host.Load.Run.Full.Ordinary.NativeInventoryCases
