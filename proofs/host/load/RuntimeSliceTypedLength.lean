import host.mlx.OrdinarySliceStates
import host.ts.RenameRuntimeDriverTypedLength
import host.load.RuntimeSliceLiteralI32Cases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.SliceTypedLength
open Host.Ts.Owned.Annotated

host_retained_typed_length P.F, P.RestStream.micro0.micro10.s48
  using (P.RestStream.micro0.micro10.S48.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro10.s49 using (P.RestStream.micro0.micro10.S49.substitute LoopVariables.oracleVariables)
  as Source1048

theorem source_count : Source1048.count = 3 := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.SliceTypedLength
