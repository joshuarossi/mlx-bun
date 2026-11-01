import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.template.ReturnLiteral
-- revision: literal chunk length
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

bridge_empty D1StageSplit.input from PRE_setup_early_r0.s16
server_literal D1StageSplit.inputSrv := (⟨PRE_setup_early_r0.S16.tab, []⟩ : SSrv)

set_option interpreter.prefer_native true in
tpl_chain D1StageSplit from D1StageSplit.input, D1StageSplit.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_d1_stage_split/plan.json" («world» := Host.Load.Run.Tpl.PRE_setup_early_r0.nativeWorld)

end Host.Load.Run.Tpl
