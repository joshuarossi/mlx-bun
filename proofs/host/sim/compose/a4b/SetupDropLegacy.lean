import host.sim.compose.a4b.SetupDrop
import host.sim.compose.a4b.SetupRestCuts

namespace Host.Ts.Sim.Compose.SetupDrop
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
open Host.Ts.Sim.Compose.SetupChunk

theorem oldToLegacy {NB T L : Nat} {tk : Nat → Nat} (h8 : L ≤ 8) :
    CutConv (cut NB T tk L) (withSetupInputs T tk (SetupRest.setupNextCut NB T tk L)) := by
  rintro x hr ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩, hv, hids, _⟩
  exact ⟨x, rfl, rfl, hr, ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hsmall.1 h8, hfresh⟩, hids⟩, hv⟩

/-- The common setup cut enters the checked singleton prefix with all loaded
values and the emitted binding still attached to its own map. -/
theorem toSingleton (NB T : Nat) (tk : Nat → Nat) :
    CutConv (SetupCommon.nextCut NB T tk 1)
      (withSetupInputs T tk (SetupRest.setupNextCut NB T tk 1)) :=
  (toOld (chunkC2048 (by decide) (by decide))).trans (oldToLegacy (by decide))

end Host.Ts.Sim.Compose.SetupDrop
