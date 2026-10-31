import host.simgraph.prompt.NativeD
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

def coldBox : Box := [(9, 1, 1)]
def coldValue : Nat → Int := fun _ => 1

theorem coldBox_mem {x : Nat} {l h : Int} (hg : coldBox.get x = some (l,h)) :
    x = 9 ∧ l = 1 ∧ h = 1 := by
  by_cases hx : x = 9
  · subst x
    have hp : (1 : Int) = l ∧ (1 : Int) = h := by simpa [coldBox, Box.get] using hg
    exact ⟨rfl, hp.1.symm, hp.2.symm⟩
  · simp [coldBox, Box.get, hx, Ne.symm hx] at hg

theorem coldValue_box : InBox coldBox coldValue := by
  intro x l h hg
  obtain ⟨rfl, rfl, rfl⟩ := coldBox_mem hg
  exact ⟨le_rfl, le_rfl⟩

/-- Use the existing proved normalizer, evaluated at the actual singleton prompt length. -/
def coldClass (S : SSrv) (x : NumV) : Option PDim :=
  (clsOfP S coldBox x).map (fun d => PDim.lit (d.eval coldValue))

theorem coldClass_sound (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) (ν : Nat → Int) :
    ClsSoundD (coldClass S) (νsOf S ρ) (PDim.eval ν) := by
  have hr : ∀ x l h, coldBox.get x = some (l,h) → ρ x = F64.ofInt (coldValue x) := by
    intro x l h hg
    obtain ⟨rfl, rfl, rfl⟩ := coldBox_mem hg
    exact hρ
  intro x d hx
  obtain ⟨dim, hs, rfl⟩ := Option.map_eq_some_iff.mp hx
  exact clsOfP_sound S coldBox coldValue ρ coldValue_box hr x dim hs
end Host.Ts.Sim.Compose.ColdGraph
