import host.sim.compose.a4b.SetupDrop
import host.sim.compose.a4b.SetupRestCuts

namespace Host.Ts.Sim.Compose.SetupDrop
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
open Host.Ts.Sim.Compose.SetupChunk

theorem oldToLegacy {NB T L : Nat} {tk : Nat → Nat} {ρ : List Nat} (h8 : L ≤ 8) :
    CutConv (cut NB T tk ρ L) (withSetupPin T tk ρ (SetupRest.setupNextCut NB T tk L)) := by
  rintro x hr ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall⟩, hv, hids, _, hp, hn⟩
  exact ⟨x, rfl, rfl, hr, ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hsmall.1 h8, hfresh⟩, hids⟩, hv, hp, hn⟩

/-- The common setup cut enters the checked singleton prefix with all loaded
values and the emitted binding still attached to its own map. -/
theorem toSingletonPin (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutConv (SetupCommon.nextCut NB T tk π 1)
      (withSetupPin T tk π (SetupRest.setupNextCut NB T tk 1)) :=
  (toOld (chunkC2048 (by decide) (by decide))).trans (oldToLegacy (by decide))

theorem toSingleton (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutConv (SetupCommon.nextCut NB T tk π 1)
      (withSetupInputs T tk (SetupRest.setupNextCut NB T tk 1)) :=
  (toSingletonPin NB T tk π).trans fun x hr hb => ⟨x, rfl, rfl, hr, hb.1, hb.2.1⟩

end Host.Ts.Sim.Compose.SetupDrop
