import host.sim.template.a4pre_post_selector.H0
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_post_call.input from PRE_post_selector.s1
server_literal PRE_post_call.inputSrv := (⟨PRE_post_selector.S1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_post_call from PRE_post_call.input, PRE_post_call.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_post_call/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
