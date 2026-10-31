import host.sim.template.a4pre_first_tail_x22_r0_body.H18
import host.sim.template.a4pre_first_tail_x22_r0.World
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

server_literal PRE_first_tail_x22_r0_suffix.inputSrv := (⟨PRE_first_tail_x22_r0_body.S579.tab, []⟩ : Host.Ts.SSrv)

set_option interpreter.prefer_native true in
tpl_chain PRE_first_tail_x22_r0_suffix from PRE_first_tail_x22_r0_body.s579, PRE_first_tail_x22_r0_suffix.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_first_tail_x22_r0_suffix/plan.json" («world» := Host.Ts.Sim.Template.neWorld)

end Host.Load.Run.Tpl
