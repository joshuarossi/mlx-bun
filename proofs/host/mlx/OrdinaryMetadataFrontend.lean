import host.mlx.NativeMetadataFrontend
import host.mlx.OrdinaryFreeStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetadataCases

/-- error: host_retained_metadata: expected mlx_array_ndim or mlx_array_shape -/
#guard_msgs in
host_retained_metadata P.F, P.RestStream.micro0.micro4.s21 using P.RestStream.micro0.micro4.S21
  to P.RestStream.micro0.micro4.s22 using P.RestStream.micro0.micro4.S22 as RejectVectorFree

host_retained_metadata P.F, P.RestStream.micro0.micro4.s84 using P.RestStream.micro0.micro4.S84
  to P.RestStream.micro0.micro4.s85 using P.RestStream.micro0.micro4.S85 as Source484

host_retained_metadata P.F, P.RestStream.micro0.micro5.s29 using P.RestStream.micro0.micro5.S29
  to P.RestStream.micro0.micro5.s30 using P.RestStream.micro0.micro5.S30 as Source529

end Host.Load.Run.Full.Ordinary.MetadataCases
