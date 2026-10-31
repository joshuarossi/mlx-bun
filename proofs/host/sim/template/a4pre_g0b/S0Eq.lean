import host.sim.template.a4pre_g0b.H0
import host.sim.full.DropTokens
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `PRE_g0b`: its source `PRE_g0b.rawInput` with the mlx token queue set to its live tokens. -/

kernel_rfl PRE_g0b.s0_tok : PRE_g0b.s0 = PRE_g0b.rawInput.setFfi (Host.Ts.Sim.Full.fullSetTokens PRE_g0b.rawInput.ffi [.ref 1, .ref 2])

end Host.Load.Run.Tpl
