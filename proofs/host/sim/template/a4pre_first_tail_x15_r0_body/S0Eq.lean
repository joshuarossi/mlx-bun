import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.full.DropTokens
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `PRE_first_tail_x15_r0_body`: its source `PRE_first_tail_x15_r0.s41` with the mlx token queue set to its live tokens. -/

kernel_rfl PRE_first_tail_x15_r0_body.s0_tok : PRE_first_tail_x15_r0_body.s0 = PRE_first_tail_x15_r0.s41.setFfi (Host.Ts.Sim.Full.fullSetTokens PRE_first_tail_x15_r0.s41.ffi [.ref 1, .ref 2])

kernel_rfl PRE_first_tail_x15_r0_body.s0_tab : PRE_first_tail_x15_r0_body.S0.tab = (PRE_first_tail_x15_r0.S41.tab.map (·.subst (fun v => if v = 1087 then .var 10 else .var v)))

end Host.Load.Run.Tpl
