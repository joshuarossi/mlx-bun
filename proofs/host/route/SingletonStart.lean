import host.sim.compose.a4b.SetupAll
import host.sim.compose.a4b.SetupDropLegacy
import host.sim.compose.a4b.SetupD1SavedCells
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Compose Host.Ts.Sim.Lin.Cls

/-- The singleton route enters the existing forward with its loaded inputs and driver binding retained. -/
theorem singleton_start (NB T : Nat) (tk : Nat → Nat) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk 1)
      (SetupD1SavedCells.forwardSavedInputCut NB T tk) 3011 := by
  have hs := SetupAll.forClass_count (NB := NB) (T := T) (tk := tk)
    (c := SetupClass.early) (by decide : 1 ≤ 1) (by decide : 1 ≤ 262143) (by change 1 ≤ 1 ∧ 1 ≤ 8; decide)
  have hp := (SetupD1SavedCells.toForwardValuesInput (NB := NB) (T := T) (tk := tk)).convL
    (SetupDrop.toSingleton NB T tk)
  exact (hs.trans hp).cast rfl rfl rfl

end Host.Route
