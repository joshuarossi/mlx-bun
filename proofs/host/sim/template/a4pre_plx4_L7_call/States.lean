import host.sim.template.a4pre_plx4_L7_selector.H0
-- stream revision 1793674701
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_plx4_L7_call.input from PRE_plx4_L7_selector.s1
server_literal PRE_plx4_L7_call.inputSrv := (⟨PRE_plx4_L7_selector.S1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_plx4_L7_call from PRE_plx4_L7_call.input, PRE_plx4_L7_call.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_plx4_L7_call/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld)
end Host.Load.Run.Tpl
