import host.sim.template.a4pre_pf_x4_L7.S
import host.sim.template.ReturnLiteral
import host.sim.template.ChainLit
-- stream revision 1793638086
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_fd_x4_L7_r0.input from PRE_pf_x4_L7.s0
server_literal PRE_fd_x4_L7_r0.inputSrv := (⟨PRE_pf_x4_L7.S0.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain_lit PRE_fd_x4_L7_r0 from PRE_fd_x4_L7_r0.input, PRE_fd_x4_L7_r0.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_fd_x4_L7_r0/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld)
end Host.Load.Run.Tpl
