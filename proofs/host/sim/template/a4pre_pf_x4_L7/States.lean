import host.sim.template.a4pre_first_tail_x4_L7_r0_suffix.m.B3
import host.sim.template.ReturnLiteral
import host.sim.template.ServerData
-- stream revision 1793637906
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
bridge_empty PRE_pf_x4_L7.input from PRE_first_tail_x4_L7_r0_suffix.s8
server_data PRE_pf_x4_L7.inputSrv := (⟨PRE_first_tail_x4_L7_r0_suffix.S8.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_template PRE_pf_x4_L7 from PRE_pf_x4_L7.input, PRE_pf_x4_L7.inputSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x4_L7_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/pf_x4_L7.json")
end Host.Load.Run.Tpl
