import host.sim.template.a4pre_pl_t2p.H0
import host.sim.template.ReturnLiteral
-- revision: literal row, ghosts, trace vars
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
-- plan revision 3: only the prompt framed
open Host.Ts
bridge_empty PRE_pl_r1.input from PRE_pl_t2p.s1
server_literal PRE_pl_r1.inputSrv := (⟨PRE_pl_t2p.S1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_pl_r1 from PRE_pl_r1.input, PRE_pl_r1.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_pl_r1/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
