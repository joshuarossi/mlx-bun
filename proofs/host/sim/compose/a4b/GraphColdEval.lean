import host.sim.compose.a4b.GraphColdPDim
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

/-- Partial evaluation with exactly the already fixed length variable. -/
def evalClosed : SymE → Option F64
  | .lit f => some f
  | .var i => if i = 9 then some (F64.ofNat 1) else none
  | .un op a => (evalClosed a).map (F64.un op)
  | .bin op a b => do pure (F64.bin op (← evalClosed a) (← evalClosed b))

theorem evalClosed_sound (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) :
    ∀ e f, evalClosed e = some f → e.eval ρ = f := by
  intro e
  induction e with
  | lit a => intro f hf; exact Option.some.inj hf
  | var i =>
    intro f hf
    by_cases hi : i = 9
    · subst i
      change some (F64.ofNat 1) = some f at hf
      exact hρ.trans (Option.some.inj hf)
    · simp [evalClosed, hi] at hf
  | un op a ih =>
    intro f hf
    obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp hf
    exact congrArg (F64.un op) (ih v hv)
  | bin op a b iha ihb =>
    intro f hf
    change ((evalClosed a).bind fun va => (evalClosed b).bind fun vb => some (F64.bin op va vb)) = some f at hf
    obtain ⟨va, ha, hr⟩ := Option.bind_eq_some_iff.mp hf
    obtain ⟨vb, hb, hr⟩ := Option.bind_eq_some_iff.mp hr
    exact (congrArg₂ (F64.bin op) (iha va ha) (ihb vb hb)).trans (Option.some.inj hr)

def coldNumVal (S : SSrv) : NumV → Option F64
  | .lit f => some f
  | .ref i => (nth? S.tab i).bind evalClosed

theorem coldNumVal_sound (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (x : NumV) (f : F64) (hf : coldNumVal S x = some f) : νsOf S ρ x = some f := by
  cases x with
  | lit a => exact hf
  | ref i =>
    obtain ⟨e, he, hf⟩ := Option.bind_eq_some_iff.mp hf
    change ((nth? S.tab i).map (SymE.eval ρ)) = some f
    rw [he]
    exact congrArg some (evalClosed_sound ρ hρ e f hf)

/-- Preserve the proved normalizer first, then evaluate only fixed-length expressions. -/
def coldDims (S : SSrv) (x : NumV) : Option PDim :=
  (coldClass S x).orElse fun _ => ((coldNumVal S x).bind F64.toInt?).map PDim.lit

theorem coldDims_sound (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) (ν : Nat → Int) :
    ClsSoundD (coldDims S) (νsOf S ρ) (PDim.eval ν) := by
  intro x d hd
  cases hc : coldClass S x with
  | some c =>
    rw [coldDims, hc] at hd
    change some c = some d at hd
    cases hd
    exact coldClass_sound S ρ hρ ν x _ hc
  | none =>
    rw [coldDims, hc] at hd
    change ((coldNumVal S x).bind F64.toInt?).map PDim.lit = some d at hd
    obtain ⟨i, hi, rfl⟩ := Option.map_eq_some_iff.mp hd
    obtain ⟨f, hf, hi⟩ := Option.bind_eq_some_iff.mp hi
    change ((νsOf S ρ x).bind F64.toInt?) = some i
    rw [coldNumVal_sound S ρ hρ x f hf]
    exact hi

/-- Bigint cells retain the original reader's refusal; numeric cells use only
proved closed numeric expressions. Native fields themselves are unchanged. -/
def coldByte (S : SSrv) : Byte → Option Nat
  | .lit b => some b
  | .part k (.num x) i => concreteByte (coldNumVal S) (.part k (.num x) i)
  | .part _ (.big _) _ => none

def coldNums (S : SSrv) : Nums PDim :=
  { symNumsD (coldDims S) PDim.lit with byte := coldByte S }
end Host.Ts.Sim.Compose.ColdGraph
