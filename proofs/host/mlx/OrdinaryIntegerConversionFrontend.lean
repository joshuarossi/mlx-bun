import host.mlx.NativeIntegerConversionFrontend
import host.mlx.OrdinaryVectorStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.IntegerConversionCases

host_retained_bigint P.F, P.RestStream.micro0.micro2.s47 using P.RestStream.micro0.micro2.S47
  to P.RestStream.micro0.micro2.s48 using P.RestStream.micro0.micro2.S48 as Source247

/-- error: host_retained_bigint: expected literal numeric argument -/
#guard_msgs in
host_retained_bigint P.F, {Source247.input with ctl := .call (.obj Source247.address) Source247.sourceThis [.num (.ref 0)]}
  using P.RestStream.micro0.micro2.S47 to Source247.output using P.RestStream.micro0.micro2.S48 as RejectReference

end Host.Load.Run.Full.Ordinary.IntegerConversionCases
