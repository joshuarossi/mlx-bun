import host.sim.compose.a4b.GraphColdEval
import host.simgraph.GenLoadRel
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

theorem cold_agree (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) (ν : Nat → Int)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Host.Mlx.SimGraph.Agree (coldNums S) (concrete νt) (PDim.eval ν) (numImg μ β α η) kn kn' A := by
  have base := agree_runD (coldDims S) PDim.lit (PDim.eval ν) (fun _ => rfl)
    (νsOf S ρ) νt μ β α η hlitμ hlitt hν (coldDims_sound S ρ hρ ν) A hα kn kn' hk
  refine ⟨base.d, base.dim, base.word, ?_, hα, hk⟩
  intro b v hb
  cases b with
  | lit n => exact hb
  | part k c i =>
    cases c with
    | big n => simp [coldNums, coldByte] at hb
    | num x =>
      change concreteByte (coldNumVal S) (.part k (.num x) i) = some v at hb
      change concreteByte νt (.part k (.num (μ x)) i) = some v
      cases hv : coldNumVal S x with
      | none => simp [concreteByte, concreteCell, hv] at hb
      | some f =>
        have ht := hν x f (coldNumVal_sound S ρ hρ x f hv)
        simpa only [concreteByte, concreteCell, ht, hv, Option.map_some] using
          (show concreteByte (coldNumVal S) (.part k (.num x) i) = some v from hb)
end Host.Ts.Sim.Compose.ColdGraph
