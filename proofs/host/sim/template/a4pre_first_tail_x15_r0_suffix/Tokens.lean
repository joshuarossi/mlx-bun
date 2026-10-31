import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.full.Raise
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_first_tail_x15_r0_suffix.tokens0 : (Full.mlxOf PRE_first_tail_x15_r0_suffix.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl PRE_first_tail_x15_r0_suffix.tokens8 : (Full.mlxOf PRE_first_tail_x15_r0_suffix.s8.ffi).tokens = [.ref 1, .ref 2]
end Host.Load.Run.Tpl
