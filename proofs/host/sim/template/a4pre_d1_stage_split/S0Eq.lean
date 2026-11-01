import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.full.DropTokens
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The start of chain `D1StageSplit`: the setup's end with the mlx token queue set to its live tokens. Both states are read through their literal boot snapshots, so the kernel does not replay the bridge log. -/

boot_rfl D1StageSplit.s0_tok from D1StageSplit.s0 to PRE_setup_early_r0.s16 :
  D1StageSplit.s0 = PRE_setup_early_r0.s16.setFfi (Host.Ts.Sim.Full.fullSetTokens PRE_setup_early_r0.s16.ffi [.ref 1, .ref 2])

end Host.Load.Run.Tpl
