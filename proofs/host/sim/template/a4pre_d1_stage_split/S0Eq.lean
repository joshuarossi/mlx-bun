import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.full.DropTokens
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `D1StageSplit`: its source `Host.Load.Run.Tpl.D1StageSplit.input` with the mlx token queue set to its live tokens. -/

kernel_rfl D1StageSplit.s0_tok : D1StageSplit.s0 = Host.Load.Run.Tpl.D1StageSplit.input.setFfi (Host.Ts.Sim.Full.fullSetTokens Host.Load.Run.Tpl.D1StageSplit.input.ffi [.ref 1, .ref 2])

end Host.Load.Run.Tpl
