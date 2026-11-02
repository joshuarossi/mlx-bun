import host.sim.template.a4pre_first_tail_x0_r0.Boundary
import host.sim.template.BridgeLiteral
import host.sim.template.ChainLit
-- revision: chunk literal, the prompt's length a variable
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_first_tail_x0_r0_body.input from PRE_first_tail_x0_r0.s41

set_option interpreter.prefer_native true in
tpl_chain_lit PRE_first_tail_x0_r0_body from PRE_first_tail_x0_r0_body.input, PRE_first_tail_x0_r0.endSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_first_tail_x0_r0_body/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.nativeWorld)

end Host.Load.Run.Tpl
