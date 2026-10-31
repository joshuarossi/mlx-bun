import host.sim.compose.a4b.GraphColdInputBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

/-- Read actual numeric heap fields, rather than cacheT's offset placeholder. -/
def offsetOf (s : St LSt) (S : SSrv) (v : Val) : Option Int := do
  let .num x ← own s v chars!"offset" | none
  (coldNumVal S x).bind F64.toInt?

noncomputable def offsetsOf (s : St LSt) (S : SSrv) : Option (List Int) := do
  let vs ← ((bindingOf s (entryEnv Host.Load.Run.Prompt.P.s0) chars!"cache").bind (elements s))
  vs.mapM (offsetOf s S)

theorem offsetOf_sound (s : St LSt) (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (v : Val) (i : Int) (hi : offsetOf s S v = some i) :
    ∃ x, own s v chars!"offset" = some (.num x) ∧
      ((νsOf S ρ x).bind F64.toInt?) = some i := by
  cases hv : own s v chars!"offset" with
  | none => simp [offsetOf, hv] at hi
  | some a =>
    cases a with
    | num x =>
      have hread : (coldNumVal S x).bind F64.toInt? = some i := by
        simpa only [offsetOf, hv, Option.bind_eq_bind, Option.bind_some] using hi
      obtain ⟨f, hf, hfi⟩ := Option.bind_eq_some_iff.mp hread
      refine ⟨x, rfl, ?_⟩
      rw [coldNumVal_sound S ρ hρ x f hf]
      exact hfi
    | _ => simp [offsetOf, hv] at hi
end Host.Ts.Sim.Compose.ColdGraph
