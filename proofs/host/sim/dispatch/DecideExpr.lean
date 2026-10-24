import host.sim.dispatch.DecideProps
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/Expr.lean

`VarOK`, `ShortOK`, `CellNoW`, the bigint-literal condition of `step_lit` and the
shorthand-property condition of `step_object`. -/

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame}

/-- `CellNoW`. -/
def cellNoWB (P : JSP F) (env : Env) (n : Name) : Bool :=
  match lookupEnv n env with
  | some c => nwB P c
  | none => true

theorem Kp.cellNoW (hK : Kp P K) (hW : Wp P W) {env : Env} {n : Name} (h : cellNoWB P env n = true) :
    CellNoW K W env n := by
  intro c hl
  simp only [cellNoWB, hl] at h
  exact hK.nw hW h

/-- `VarOK`. -/
def varB {S' : Type} (P : JSP F) (s : St S') (env : Env) (n : Name) : Bool :=
  match lookupEnv n env with
  | some c => nwB P c
  | none => presB s aGlobal && plainKeyB (.str n) && (noWideB P || chainNoWB P s 16 aGlobal)

theorem Kp.var {S' : Type} (hK : Kp P K) (hW : Wp P W) {s : St S'} {env : Env} {n : Name}
    (h : varB P s env n = true) : VarOK K W s env n := by
  unfold VarOK
  unfold varB at h
  cases hl : lookupEnv n env with
  | some c => rw [hl] at h; exact hK.nw hW h
  | none =>
    simp only [hl, Bool.and_eq_true, Bool.or_eq_true] at h
    refine ⟨h.1.1, (plainKeyB_sound h.1.2).1, (plainKeyB_sound h.1.2).2, ?_⟩
    rcases h.2 with h2 | h2
    · exact ChainNoW.of_none (hW.noWide h2) 16 aGlobal
    · exact hK.chainNoW hW h2

/-- The bigint condition of a literal; a regular expression reads the global object's chain
(no declared frames). -/
def litB (P : JSP F) : Lit → Bool
  | .big raw => match F64.parseIntLit raw with
    | some n => bfB P (n : Int)
    | none => true
  | .regex _ _ => noWideB P
  | _ => true

theorem Kp.lit (hK : Kp P K) {l : Lit} (h : litB P l = true) :
    ∀ raw n, l = .big raw → F64.parseIntLit raw = some n → BigFixed K.lo K.hi (n : Int) := by
  rintro raw n rfl hp
  simp only [litB, hp] at h
  exact hK.bf h

theorem Wp.lit (hW : Wp P W) {l : Lit} (h : litB P l = true) : ∀ p fl, l = .regex p fl → ∀ a, W a = none := by
  rintro p fl rfl
  exact hW.noWide h

/-- Shorthand properties of an object literal read variables (`ShortOK`). -/
def shortB {S' : Type} (P : JSP F) (s : St S') (env : Env) : Property → Bool
  | .short n => match lookupEnv n env with
    | some c => nwB P c
    | none => presB s aGlobal && plainKeyB (.str n) && noWideB P
  | _ => true

theorem Kp.short {S' : Type} (hK : Kp P K) (hW : Wp P W) {s : St S'} {env : Env} {props : List Property}
    (h : allB (shortB P s env) props = true) : ∀ n, Property.short n ∈ props → ShortOK K W s env n := by
  intro n hn
  have h1 := allB_sound h _ hn
  unfold ShortOK
  simp only [shortB] at h1
  cases hl : lookupEnv n env with
  | some c => rw [hl] at h1; exact hK.nw hW h1
  | none =>
    simp only [hl, Bool.and_eq_true] at h1
    exact ⟨h1.1.1, (plainKeyB_sound h1.1.2).1, (plainKeyB_sound h1.1.2).2, hW.noWide h1.2⟩

end
end Host.Ts.Sim.Disp
