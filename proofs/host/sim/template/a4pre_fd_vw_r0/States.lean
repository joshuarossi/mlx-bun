import host.sim.template.a4pre_pf_vw.S
import host.sim.template.ReturnLiteral
import host.sim.template.ChainLit
-- stream revision 1793590199036
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- plan revision 4: the row literal, the ghosts framed
bridge_empty PRE_fd_vw_r0.input from PRE_pf_vw.s0
server_literal PRE_fd_vw_r0.inputSrv := (⟨PRE_pf_vw.S0.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain_lit PRE_fd_vw_r0 from PRE_fd_vw_r0.input, PRE_fd_vw_r0.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_fd_vw_r0/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
