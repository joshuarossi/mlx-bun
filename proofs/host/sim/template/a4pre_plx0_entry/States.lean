import host.sim.template.a4pre_fd_x0_r0_body.H13
-- stream revision 1793635929
import host.sim.template.ServerData
import host.sim.template.BridgeLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/post_x0.json. The tail's rows and offset (10, 11) move out of POST's way to 27 and 28.
def PRE_plx0_entry.rebind (v : Nat) : SymE :=
  if v = 10 then .var 27 else if v = 11 then .var 28 else .var v
noncomputable def PRE_plx0_entry.rawSrv : SSrv :=
  ⟨PRE_fd_x0_r0_body.S447.tab.map (·.subst PRE_plx0_entry.rebind), []⟩
server_data PRE_plx0_entry.chooserSrv := PRE_plx0_entry.rawSrv
bridge_empty PRE_plx0_entry.input from PRE_fd_x0_r0_body.s447
set_option interpreter.prefer_native true in
tpl_template PRE_plx0_entry from PRE_plx0_entry.input, PRE_plx0_entry.chooserSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/post_x0.json")
end Host.Load.Run.Tpl
