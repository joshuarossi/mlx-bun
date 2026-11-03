import host.sim.template.a4pre_plx0_call.H0
-- stream revision 1793673719
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_plx0_common.input from PRE_plx0_call.s1
server_literal PRE_plx0_common.inputSrv := (⟨PRE_plx0_call.S1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_plx0_common from PRE_plx0_common.input, PRE_plx0_common.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_plx0_common/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.nativeWorld)
end Host.Load.Run.Tpl
