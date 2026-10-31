import host.sim.template.a4pre_d1_body.D4
import host.sim.template.a4pre_first_tail_x15_r0.States
import host.sim.template.ServerData
import host.sim.template.BridgeLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
-- specs/post.json revision 3: nextTraceId literal
noncomputable def PRE_pl_entry.rawSrv : Host.Ts.SSrv :=
  ⟨D1Body.S155.tab.map (·.subst (fun v => if v = 9 then .var 10 else .var v)), []⟩
server_data PRE_pl_entry.chooserSrv := PRE_pl_entry.rawSrv
bridge_empty PRE_pl_entry.input from D1Body.s155
set_option interpreter.prefer_native true in
tpl_template PRE_pl_entry from PRE_pl_entry.input, PRE_pl_entry.chooserSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/post.json")
end Host.Load.Run.Tpl
