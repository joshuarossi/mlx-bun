import host.sim.template.a4pre_pl_tail.S
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- plan revision 1
bridge_empty PRE_pl_ta.input from PRE_pl_tail.s0
server_literal PRE_pl_ta.inputSrv := (⟨PRE_pl_tail.S0.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_pl_ta from PRE_pl_ta.input, PRE_pl_ta.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_pl_ta/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
