import host.sim.compose.a4b.fd.NpsCompact
import host.sim.compose.a4b.VWFirstRows
import host.sim.stage.NextStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

noncomputable def nps_DTtail_first__start__g1_DTtail_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF firstTailRows [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.DTtail.O⟩]
      (fun i => withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L))
      (fun i => withMem (Mem i.L) (afterNpsCut NB T tk π i)) where
  m := [(9, .L)]
  n := PRE_fd_vw_r0.st0.tpl.n + 1
  O := PRE_fd_vw_r0.st0.S0.oracle
  chk r hr := List.all_eq_true.mp PRE_fd_vw_r0.chk_site0 r hr
  ok r hr i hi ho := by
    obtain ⟨h1, hL, hn, hC⟩ := firstTailFacts hr hi
    have hc : chunkC i.L = 2048 := by
      rw [chunkC_eq i.L (by omega)]
      (repeat' split) <;> omega
    have horacle : ∀ ν, MapOk ν (setupI i.L) [(9, .L)] → Good ν PRE_fd_vw_r0.st0.S0.oracle := by
      intro ν hm
      exact ho.1 ν ⟨hm.1, trivial⟩
    exact StageCall.intro (toNps (hMem i.L) hc) (nps_merged (hMem i.L) horacle)
      (nps_compact (hMem i.L) (by omega) (by omega) hn)
end Host.Ts.Sim.Compose.FDVW
