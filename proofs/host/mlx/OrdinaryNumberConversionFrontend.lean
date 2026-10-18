import host.mlx.NativeNumberConversionFrontend
import host.mlx.OrdinaryFreeStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.NumberConversionCases

host_retained_number P.F, P.RestStream.micro0.micro4.s86 using P.RestStream.micro0.micro4.S86
  to P.RestStream.micro0.micro4.s87 using P.RestStream.micro0.micro4.S87 as Source486

/-- error: host_retained_number: expected bigint argument -/
#guard_msgs in
host_retained_number P.F, {Source486.input with ctl := .call (.obj Source486.address) Source486.sourceThis [.num (.ref 0)]}
  using P.RestStream.micro0.micro4.S86 to Source486.output using P.RestStream.micro0.micro4.S87 as RejectReference

end Host.Load.Run.Full.Ordinary.NumberConversionCases
