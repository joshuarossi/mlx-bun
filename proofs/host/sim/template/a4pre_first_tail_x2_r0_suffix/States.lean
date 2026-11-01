import host.sim.template.a4pre_first_tail_x2_r0_body.m.B23
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_first_tail_x2_r0_suffix.input from PRE_first_tail_x2_r0_body.s1395
server_literal PRE_first_tail_x2_r0_suffix.inputSrv := PRE_first_tail_x2_r0_body.endSrv

set_option interpreter.prefer_native true in
tpl_chain PRE_first_tail_x2_r0_suffix from PRE_first_tail_x2_r0_suffix.input, PRE_first_tail_x2_r0_suffix.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_first_tail_x2_r0_suffix/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x2_r0.nativeWorld)

end Host.Load.Run.Tpl
