import host.sim.template.a4pre_pl_call.H0
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
-- plan revision 3: only the prompt framed
open Host.Ts
bridge_empty PRE_pl_common.input from PRE_pl_call.s1
server_literal PRE_pl_common.inputSrv := (⟨PRE_pl_call.S1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_pl_common from PRE_pl_common.input, PRE_pl_common.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_pl_common/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
