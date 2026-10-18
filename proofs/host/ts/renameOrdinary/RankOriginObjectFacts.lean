import host.ts.renameOrdinary.RankOriginNativeSeed
import host.mlx.NativeIdentityObjects
import host.mlx.OrdinaryVectorStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.ObjectSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

theorem source_objects : Initial.allPaged (Initial.checkObject NativeSeed.native.nnext)
    NativeSeed.native.objs = true := by host_kernel_rfl

theorem vector_entry_objects : P.RestStream.micro0.micro2.s49.ffi.mlx.objs = NativeSeed.native.objs := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.RankOrigin.ObjectSeed
