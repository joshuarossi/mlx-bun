import host.sim.dispatch.DecideProps
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/Expr.lean

`VarOK`, the bigint-literal condition of `step_lit` and the shorthand-property
condition of `step_object`. -/

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

/-- `VarOK`. -/
def varB {S' : Type} (s : St S') (env : Env) (n : Name) : Bool :=
  match lookupEnv n env with
  | some _ => true
  | none => presB s aGlobal && plainKeyB (.str n)

theorem varB_sound {S' : Type} {s : St S'} {env : Env} {n : Name} (h : varB s env n = true) : VarOK s env n := by
  unfold VarOK
  unfold varB at h
  cases hl : lookupEnv n env with
  | some _ => trivial
  | none =>
    simp only [hl, Bool.and_eq_true] at h
    exact ⟨h.1, plainKeyB_sound h.2⟩

/-- The bigint condition of a literal. -/
def litB (P : JSP F) : Lit → Bool
  | .big raw => match F64.parseIntLit raw with
    | some n => bfB P (n : Int)
    | none => true
  | _ => true

theorem Kp.lit (hK : Kp P K) {l : Lit} (h : litB P l = true) :
    ∀ raw n, l = .big raw → F64.parseIntLit raw = some n → BigFixed K.lo K.hi (n : Int) := by
  rintro raw n rfl hp
  simp only [litB, hp] at h
  exact hK.bf h

/-- Shorthand properties of an object literal read variables (`VarOK`). -/
def shortB {S' : Type} (s : St S') (env : Env) : Property → Bool
  | .short n => varB s env n
  | _ => true

theorem shortB_sound {S' : Type} {s : St S'} {env : Env} {props : List Property}
    (h : allB (shortB s env) props = true) : ∀ n, Property.short n ∈ props → VarOK s env n :=
  fun _ hn => varB_sound (allB_sound h _ hn)

end
end Host.Ts.Sim.Disp
