import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.full.Raise
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_first_tail_x15_r0_body.tokens0 : (Full.mlxOf PRE_first_tail_x15_r0_body.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl PRE_first_tail_x15_r0_body.tokens1681 : (Full.mlxOf PRE_first_tail_x15_r0_body.s1681.ffi).tokens = [.ref 1, .ref 2]

end Host.Load.Run.Tpl
