import host.mlx.NativeShapelessFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ShapelessCases

host_retained_shapeless P.F, P.RestStream.micro0.micro36.s86 using P.RestStream.micro0.micro36.S86
  to P.RestStream.micro0.micro36.s87 using P.RestStream.micro0.micro36.S87 as Source3686

/-- error: host_retained_shapeless: expected source call -/
#guard_msgs in
host_retained_shapeless P.F, Source3686.output using P.RestStream.micro0.micro36.S87
  to Source3686.output using P.RestStream.micro0.micro36.S87 as RejectReturn

/-- error: host_retained_shapeless: expected owned closure handle -/
#guard_msgs in
host_retained_shapeless P.F, {Source3686.input with ctl := .call (.obj 4782) (.obj 4817) [.ptr (.js 3127055) 0,.num (.ref 0),.big (Int.ofNat 29382)]}
  using P.RestStream.micro0.micro36.S86 to Source3686.output using P.RestStream.micro0.micro36.S87 as RejectNumericReference

end Host.Load.Run.Full.Ordinary.ShapelessCases
