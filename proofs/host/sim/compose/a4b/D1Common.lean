import host.sim.compose.a4b.SetupDropLegacy
import host.sim.compose.a4b.SetupD1SavedCells

namespace Host.Ts.Sim.Compose.D1Common
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full

/-- The checked singleton prefix consumes the shared setup cut and keeps its
reserved values and emitted-cell anchor at the forward call. -/
theorem toForwardSaved (NB T : Nat) (tk : Nat → Nat) :
    CutStep (SetupCommon.nextCut NB T tk 1) (SetupD1SavedCells.forwardSavedInputCut NB T tk) 603 :=
  SetupD1SavedCells.toForwardValuesInput.convL (SetupDrop.toSingleton NB T tk)

end Host.Ts.Sim.Compose.D1Common
