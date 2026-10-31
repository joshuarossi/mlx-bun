import host.sim.compose.a4b.SetupChunkStage

namespace Host.Ts.Sim.Compose.SetupRest
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- Actual setup boundaries retain the incoming prompt, context and fixed cells. -/
noncomputable def restCut (NB T : Nat) (tk : Nat → Nat) (L : Nat)
    (s : St FF.S) (S : SSrv) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      setupJ wideP [(9, .L)] s S (setupI L) with
    B := fun x => chunkBook L x ∧ fixedCells x }

noncomputable def setupNextCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  restCut NB T tk L PRE_setup_early_r0.s16 PRE_setup_early_r0.S16

end Host.Ts.Sim.Compose.SetupRest
