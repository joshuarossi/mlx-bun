import host.sim.template.a4pre_d1_body.D4
import host.sim.template.a4pre_first_tail_x15_r0.States
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
noncomputable def PRE_post_head.rawSrv : Host.Ts.SSrv :=
  ⟨D1Body.S155.tab.map (·.subst (fun v => if v = 9 then .var 10 else .var v)), []⟩
server_data PRE_post_head.chooserSrv := PRE_post_head.rawSrv
bridge_empty PRE_post_head.input from D1Body.s155
set_option interpreter.prefer_native true in
tpl_chain PRE_post_head from PRE_post_head.input, PRE_post_head.chooserSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_post_head/plan.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
