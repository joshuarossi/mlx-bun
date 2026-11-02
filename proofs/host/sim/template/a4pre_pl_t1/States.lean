import host.sim.template.a4pre_pl_tail.S
import host.sim.template.ReturnLiteral
-- stream revision 1793635985
-- revision: literal row, ghosts, trace vars
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
-- plan revision 3: only the prompt framed
open Host.Ts
bridge_empty PRE_pl_t1.input from PRE_pl_tail.s0
server_literal PRE_pl_t1.inputSrv := (⟨PRE_pl_tail.S0.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_pl_t1 from PRE_pl_t1.input, PRE_pl_t1.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_pl_t1/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
