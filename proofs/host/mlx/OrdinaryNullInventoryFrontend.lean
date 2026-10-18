import host.mlx.NativeNullInventoryFrontend
import host.mlx.OrdinaryVectorStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.NullInventoryCases

/-- error: host_retained_arrayNew: expected no arguments -/
#guard_msgs in
host_retained_arrayNew P.F, P.RestStream.micro0.micro2.s49 using P.RestStream.micro0.micro2.S49
  to P.RestStream.micro0.micro2.s50 using P.RestStream.micro0.micro2.S50 as RejectVector

host_retained_arrayNew P.F, P.RestStream.micro0.micro2.s95 using P.RestStream.micro0.micro2.S95
  to P.RestStream.micro0.micro2.s96 using P.RestStream.micro0.micro2.S96 as Source295

end Host.Load.Run.Full.Ordinary.NullInventoryCases
