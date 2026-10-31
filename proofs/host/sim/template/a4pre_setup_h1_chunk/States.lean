import host.sim.template.a4pre_first_tail_x15_r0.SharedStart
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_setup_h1_chunk.input from PRE_first_tail_x15_r0.s4
server_literal PRE_setup_h1_chunk.inputSrv := PRE_first_tail_x15_r0.S4

set_option interpreter.prefer_native true in
tpl_chain PRE_setup_h1_chunk from PRE_setup_h1_chunk.input, PRE_setup_h1_chunk.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_setup_h1_chunk/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)

end Host.Load.Run.Tpl
