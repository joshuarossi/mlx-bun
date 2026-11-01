import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B0
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/pf_vw.json revision 2: only the prompt framed
bridge_empty PRE_pf_vw.input from PRE_first_tail_x15_r0_suffix.s8
server_literal PRE_pf_vw.inputSrv := (⟨PRE_first_tail_x15_r0_suffix.S8.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_template PRE_pf_vw from PRE_pf_vw.input, PRE_pf_vw.inputSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/pf_vw.json")
end Host.Load.Run.Tpl
