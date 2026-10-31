import host.sim.template.a4dec_clearGrow.H0
import host.sim.full.DropTokens
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `DEC_clearGrow`: its source `Host.Load.Run.Tpl.DT.s0` with the mlx token queue set to its live tokens. -/

kernel_rfl DEC_clearGrow.s0_tok : DEC_clearGrow.s0 = Host.Load.Run.Tpl.DT.s0.setFfi (Host.Ts.Sim.Full.fullSetTokens Host.Load.Run.Tpl.DT.s0.ffi [.ref 79])

end Host.Load.Run.Tpl
