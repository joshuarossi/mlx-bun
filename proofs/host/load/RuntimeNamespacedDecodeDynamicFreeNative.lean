import host.load.RuntimeNamespacedDecodePlan1550
import host.mlx.NativeArrayFreeFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
noncomputable def At1677.s0 := Region1550.s127
noncomputable def At1677.S0 := Region1550.S127
noncomputable def At1677.s1 := Host.Ts.finishStatus At1677.s0
  (Host.Load.Owned.freeArray At1677.s0.ffi 29373) chars!"mlx_array_free" [.big (Int.ofNat 29373)]
noncomputable def At1677.S1 := At1677.S0
host_retained_arrayFree P.F, At1677.s0 using (At1677.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to At1677.s1 using (At1677.S1.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Free1677
end Host.Load.Run.Full.Ordinary.NamespacedDecode
