import host.sim.compose.a4b.SetupDropLegacy
import host.sim.compose.a4b.SetupD1SavedCells
import host.sim.template.a4pre_d1_prompt_identity.Dispatch

namespace Host.Ts.Sim.Compose.D1Common
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full

/-- The checked singleton prefix consumes the shared setup cut and keeps its reserved values, its
emitted-cell anchor and the route's prompt in its frame at the forward call. -/
theorem toForwardPrompt (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutStep (SetupCommon.nextCut NB T tk π 1)
      (SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV)) 603 := by
  have h : CutConv (SetupCommon.nextCut NB T tk π 1)
      (SetupD1PromptIdentity.setupNextValuesCut NB T tk 1 (π.map natV)) := by
    intro x hr hb
    obtain ⟨y, ht, hC, hr', hb'⟩ := ((withMem_true _).trans
      (SetupDrop.toSingletonPin NB T tk π (Mem := fun _ => True) (fun _ _ _ h => h))) x hr hb
    exact ⟨y, ht, hC, hr', ⟨hb'.1.1, hb'.1.2.1⟩, hb'.1.2.2.1⟩
  exact SetupD1PromptIdentity.toForwardValuesInput.convL h

end Host.Ts.Sim.Compose.D1Common
