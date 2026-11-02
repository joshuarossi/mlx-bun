import host.sim.template.a4pre_fd_x0_r0.Boundary
-- stream revision 1793652258
import host.sim.template.BridgeLiteral
import host.sim.template.ServerData
import host.sim.template.ChainLit
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
server_data PRE_fd_x0_r0_body.inputSrv := PRE_fd_x0_r0.endSrv
bridge_empty PRE_fd_x0_r0_body.input from PRE_fd_x0_r0.s24
set_option interpreter.prefer_native true in
tpl_chain_lit PRE_fd_x0_r0_body from PRE_fd_x0_r0_body.input, PRE_fd_x0_r0_body.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_fd_x0_r0_body/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.nativeWorld)
end Host.Load.Run.Tpl
