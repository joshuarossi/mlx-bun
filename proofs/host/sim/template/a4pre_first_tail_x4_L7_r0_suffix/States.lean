import host.sim.template.a4pre_first_tail_x4_L7_r0_body.Boundary
import host.sim.template.ReturnLiteral
import host.sim.template.ChainLit
-- revision: chunk literal, the prompt's length a variable
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_first_tail_x4_L7_r0_suffix.input from PRE_first_tail_x4_L7_r0_body.s1427
server_literal PRE_first_tail_x4_L7_r0_suffix.inputSrv := PRE_first_tail_x4_L7_r0_body.endSrv

set_option interpreter.prefer_native true in
tpl_chain_lit PRE_first_tail_x4_L7_r0_suffix from PRE_first_tail_x4_L7_r0_suffix.input, PRE_first_tail_x4_L7_r0_suffix.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_first_tail_x4_L7_r0_suffix/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld)

end Host.Load.Run.Tpl
