import host.mlx.NativeConcatInventoryFrontend
import host.mlx.OrdinaryConcatStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConcatInventoryCases

/-- error: host_retained_concat: expected source call -/
#guard_msgs in
host_retained_concat P.F, {P.RestStream.micro0.micro3.s36 with ctl := .construct .undef [] .undef}
  using P.RestStream.micro0.micro3.S36 to P.RestStream.micro0.micro3.s37 using P.RestStream.micro0.micro3.S37 as RejectConstruct

host_retained_concat P.F, P.RestStream.micro0.micro3.s36 using P.RestStream.micro0.micro3.S36
  to P.RestStream.micro0.micro3.s37 using P.RestStream.micro0.micro3.S37 as Source336

end Host.Load.Run.Full.Ordinary.ConcatInventoryCases
