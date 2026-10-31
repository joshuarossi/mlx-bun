import host.sim.template.a4pre_d128p_r0.Boundary
import host.sim.template.BridgeLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

bridge_empty PRE_d128p_r0_body.input from PRE_d128p_r0.s41

set_option interpreter.prefer_native true in
tpl_chain PRE_d128p_r0_body from PRE_d128p_r0_body.input, PRE_d128p_r0.endSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_d128p_r0_body/plan.json" («world» := Host.Load.Run.Tpl.PRE_d128p_r0.nativeWorld)

end Host.Load.Run.Tpl
