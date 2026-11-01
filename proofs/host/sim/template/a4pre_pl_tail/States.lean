import host.sim.template.a4pre_pl_common.H0
import host.sim.template.ReturnLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/post_tail.json: only the prompt framed
bridge_empty PRE_pl_tail.input from PRE_pl_common.s4
server_literal PRE_pl_tail.inputSrv := (⟨PRE_pl_common.S4.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_template PRE_pl_tail from PRE_pl_tail.input, PRE_pl_tail.inputSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/post_tail.json")
end Host.Load.Run.Tpl
