import host.mlx.NativeVectorInventoryFrontend
import host.mlx.OrdinaryVectorStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorInventoryCases

/-- error: host_retained_vectorData: expected source call -/
#guard_msgs in
host_retained_vectorData P.F, P.RestStream.micro0.micro2.s23 using P.RestStream.micro0.micro2.S23
  to P.RestStream.micro0.micro2.s24 using P.RestStream.micro0.micro2.S24 as RejectConstruct

host_retained_vectorData P.F, P.RestStream.micro0.micro2.s49 using P.RestStream.micro0.micro2.S49
  to P.RestStream.micro0.micro2.s50 using P.RestStream.micro0.micro2.S50 as Source249

end Host.Load.Run.Full.Ordinary.VectorInventoryCases
