import host.sim.template.finalc0.H0
import host.sim.template.base.Rel
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Load.Run.Full (P.S3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINALC0` starts from the template with a second token reference: `FINALC0.s0` is
`Base.s0` with `mlx.tokens = [ref 79, ref 112]`, and `FINALC0.S0.tab = Base.S0.tab ++ [var 17]`.
At the cut, `ref 112` denotes the token after the current one (`P`'s `var 3`). -/

kernel_rfl FINALC0.S0_tab : FINALC0.S0.tab = Base.S0.tab ++ [.var 17]

/-- The base map of the final template: `ref 112` is the cut's next token. -/
noncomputable def FINALC0.M : Map :=
  ⟨fun a => a, fun i => bif Nat.beq i 112 then .ref 3 else Base.numOf i, fun i => i, fun r => r, fun k => k⟩

/-- `var 17` (the second token) is the cut's `var 3`. -/
def FINALC0.θB (v : Nat) : SymE := bif Nat.beq v 17 then .var 3 else Base.θB v

kernel_rfl FINALC0.numB_check : checkNum FINALC0.M FINALC0.θB FINALC0.S0 P.S3272 = true

theorem FINALC0.numOK (ρ : Nat → F64) : NumOK FINALC0.M (fun j => (FINALC0.θB j).eval ρ) FINALC0.S0 (Base.COf ρ) :=
  numOK_of_subst (checkNum_sound FINALC0.numB_check) ρ

end Host.Load.Run.Tpl
