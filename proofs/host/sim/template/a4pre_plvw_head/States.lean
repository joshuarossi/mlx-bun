import host.sim.template.a4pre_plvw_entry.S
-- stream revision 1793673289
import host.sim.template.ReturnLiteral
-- revision: literal row
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_plvw_head.input from PRE_plvw_entry.s0
server_literal PRE_plvw_head.inputSrv := (⟨PRE_plvw_entry.S0.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_plvw_head from PRE_plvw_head.input, PRE_plvw_head.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_plvw_head/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
