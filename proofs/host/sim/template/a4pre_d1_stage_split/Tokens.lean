import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.full.Raise
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl D1StageSplit.tokens0 : (Full.mlxOf D1StageSplit.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl D1StageSplit.tokens22 : (Full.mlxOf D1StageSplit.s22.ffi).tokens = [.ref 1, .ref 2]

end Host.Load.Run.Tpl
