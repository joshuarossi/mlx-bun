import host.sim.template.final.H0
import host.sim.template.base.Rel
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Load.Run.Full (P.S3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINAL` starts from the template with a second token reference: `FINAL.s0` is
`Base.s0` with `mlx.tokens = [ref 79, ref 112]`, and `FINAL.S0.tab = Base.S0.tab ++ [var 17]`.
At the cut, `ref 112` denotes the token after the current one (`P`'s `var 3`). -/

kernel_rfl FINAL.S0_tab : FINAL.S0.tab = Base.S0.tab ++ [.var 17]

/-- The base map of the final template: `ref 112` is the cut's next token. -/
noncomputable def FINAL.M : Map :=
  ⟨fun a => a, fun i => bif Nat.beq i 112 then .ref 3 else Base.numOf i, fun i => i, fun r => r, fun k => k⟩

/-- `var 17` (the second token) is the cut's `var 3`. -/
def FINAL.θB (v : Nat) : SymE := bif Nat.beq v 17 then .var 3 else Base.θB v

kernel_rfl FINAL.numB_check : checkNum FINAL.M FINAL.θB FINAL.S0 P.S3272 = true

theorem FINAL.numOK (ρ : Nat → F64) : NumOK FINAL.M (fun j => (FINAL.θB j).eval ρ) FINAL.S0 (Base.COf ρ) :=
  numOK_of_subst (checkNum_sound FINAL.numB_check) ρ

end Host.Load.Run.Tpl
