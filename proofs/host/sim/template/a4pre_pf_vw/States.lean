import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B0
import host.sim.template.ReturnLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/pf_vw.json revision 4: the VW groups' window divisors as variables 30 and 31
def PRE_pf_vw.windowA : SymE := .bin .mul (.lit (.fin false 1 0)) (.un .int32 (.var 10))
def PRE_pf_vw.windowB : SymE := .un .int32 (.bin .mul (.lit (.fin false 1 0)) (.un .int32 (.un .int32 (.var 10))))
/-- The entries the VW groups write with divisor 16 or 24, with the divisor `d`. -/
def PRE_pf_vw.quot (w d : SymE) : SymE := .bin .div w d
def PRE_pf_vw.ceiling (w d : SymE) : SymE := .un .ceil (PRE_pf_vw.quot w d)
def PRE_pf_vw.rounded (w d : SymE) : SymE := .un .int32 (PRE_pf_vw.ceiling w d)
/-- An entry over the window `w` with divisor 16 becomes the entry with divisor `.var v`. -/
def PRE_pf_vw.divisorOf (w : SymE) (v : Nat) (e : SymE) : Option SymE :=
  let d : SymE := .lit (.fin false 16 0)
  if e = PRE_pf_vw.quot w d then some (PRE_pf_vw.quot w (.var v))
  else if e = PRE_pf_vw.ceiling w d then some (PRE_pf_vw.ceiling w (.var v))
  else if e = PRE_pf_vw.rounded w d then some (PRE_pf_vw.rounded w (.var v))
  else none
def PRE_pf_vw.window (e : SymE) : SymE :=
  match PRE_pf_vw.divisorOf PRE_pf_vw.windowA 30 e with
  | some e' => e'
  | none => (PRE_pf_vw.divisorOf PRE_pf_vw.windowB 31 e).getD e
bridge_empty PRE_pf_vw.input from PRE_first_tail_x15_r0_suffix.s8
server_data PRE_pf_vw.inputSrv := (⟨PRE_first_tail_x15_r0_suffix.S8.tab.map PRE_pf_vw.window, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_template PRE_pf_vw from PRE_pf_vw.input, PRE_pf_vw.inputSrv («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/pf_vw.json")
end Host.Load.Run.Tpl
