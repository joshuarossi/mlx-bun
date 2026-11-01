import host.sim.compose.a4b.SetupDropLegacy
import host.sim.compose.a4b.SetupD1SavedCells
import host.sim.template.a4pre_d1_prompt_identity.Dispatch

namespace Host.Ts.Sim.Compose.D1Common
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full

/-- The checked singleton prefix consumes the shared setup cut and keeps its
reserved values and emitted-cell anchor at the forward call. -/
/-- The same run keeps the route's prompt in its frame. -/
theorem toForwardPrompt (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutStep (SetupCommon.nextCut NB T tk π 1)
      (SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV)) 603 :=
  SetupD1PromptIdentity.toForwardValuesInput.convL ((withMem_true _).trans
    ((SetupDrop.toSingletonPin NB T tk π (Mem := fun _ => True) (fun _ _ _ h => h)).trans
      fun x hr hb => ⟨x, rfl, rfl, hr, ⟨hb.1.1, hb.1.2.1⟩, hb.1.2.2.1⟩))

end Host.Ts.Sim.Compose.D1Common
