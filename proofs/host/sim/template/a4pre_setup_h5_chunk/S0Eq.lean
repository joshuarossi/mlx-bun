import host.sim.template.a4pre_setup_h5_chunk.H0
import host.sim.full.DropTokens
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `PRE_setup_h5_chunk`: its source `PRE_first_tail_x15_r0.s4` with the mlx token queue set to its live tokens. -/

kernel_rfl PRE_setup_h5_chunk.s0_tok : PRE_setup_h5_chunk.s0 = PRE_first_tail_x15_r0.s4.setFfi (Host.Ts.Sim.Full.fullSetTokens PRE_first_tail_x15_r0.s4.ffi [.ref 1, .ref 2])

end Host.Load.Run.Tpl
