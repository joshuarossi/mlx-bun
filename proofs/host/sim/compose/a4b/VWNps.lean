import host.sim.compose.a4b.VWNpsCompact
import host.sim.compose.a4b.VWFirstRows
import host.sim.stage.NextStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

noncomputable def nps_DTtail_first__start__g1_DTtail_first (NB T : Nat) (tk : Nat → Nat) :
    StagePiece FF firstTailRows [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.DTtail.O⟩]
      (fun i => SetupCommon.nextCut NB T tk i.L) (afterNpsCut NB T tk) where
  m := [(9, .L)]
  n := PRE_first_tail_x15_r0.st1.tpl.n + 1
  O := PRE_first_tail_x15_r0.st1.S0.oracle
  chk r hr := List.all_eq_true.mp PRE_first_tail_x15_r0.chk_site1 r hr
  ok r hr i hi ho := by
    obtain ⟨h1, hL, hn, hC⟩ := firstTailFacts hr hi
    have hc : chunkC i.L = 2048 := by
      rw [chunkC_eq i.L (by omega)]
      (repeat' split) <;> omega
    have horacle : ∀ ν, MapOk ν (setupI i.L) [(9, .L)] → Good ν PRE_first_tail_x15_r0.st1.S0.oracle := by
      intro ν hm
      exact ho.1 ν ⟨hm.1, trivial⟩
    exact StageCall.intro (toNps hc) (nps_merged horacle) (nps_compact (by omega) (by omega) hn)
end Host.Ts.Sim.Compose.VWFirst
