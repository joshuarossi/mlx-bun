import host.sim.template.a4pre_first_tail_x15_r0_body.BoundaryData
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_w15s_r0.input from PRE_first_tail_x15_r0_body.s1681
server_literal PRE_w15s_r0.inputSrv := PRE_first_tail_x15_r0_body.endSrv

set_option interpreter.prefer_native true in
tpl_chain PRE_w15s_r0 from PRE_w15s_r0.input, PRE_w15s_r0.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_w15s_r0/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)

end Host.Load.Run.Tpl
