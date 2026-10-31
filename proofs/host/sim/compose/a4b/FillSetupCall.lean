import host.sim.compose.Pieces
import host.sim.lin.checks.Chunk
import host.sim.compose.a4b.SetupChunkStage

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FillSetupEarly
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The early row constrains the prompt length even when other instance fields
are irrelevant to setup. -/
theorem bounds {i : Cls.Inst} (h : InRow setup_early.r0 i) : 1 ≤ i.L ∧ i.L ≤ 8 := by
  obtain ⟨_, x, hx, hq⟩ := h
  change InBox [⟨1, 8, []⟩] 0 x at hx
  change ((i.L : Int) = (⟨0, [1]⟩ : Aff).eval x) ∧ _ at hq
  simp only [InBox, eval_mk, dot] at hx hq
  omega

def setupRows : List Row :=
  [setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0, setup_h5.r0]

theorem setupBound {r : Row} {i : Cls.Inst} (hr : r ∈ setupRows) (hi : InRow r i) : i.L ≤ 2 ^ 20 := by
  simp only [setupRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0,
      setup_h5.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

theorem setupC {r : Row} {i : Cls.Inst} (hr : r ∈ setupRows) (hi : InRow r i) : i.C = chunkC i.L := by
  simp only [setupRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0,
      setup_h5.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    rw [chunkC_eq i.L (by omega)]
    (repeat' split) <;> omega

theorem initial {NB T L : Nat} {tk : Nat → Nat} (hL : L ≤ 2 ^ 20) :
    CutConv (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (withSetupInputs T tk (initialFixedCut NB T tk L)) := by
  intro x hR hB
  have he := ldCut_setupEntryAt_bound hL hR hB
  refine ⟨{ x with ν := rowVal x.ν L }, rfl, rfl, he.1,
    ⟨⟨he.2.1, (ldCut_setupContext hB).2, he.2.2⟩, ?_, ?_⟩,
    (ldCut_setupValues_bound hL hB).2.2, ?_⟩
  · change BigJs x.M
    rw [hB.1]
    exact BigJs.id
  · change x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589
    rw [hB.1]
    exact ⟨rfl, rfl⟩
  · change x.M.a 2590 = 2590
    rw [hB.1]
    rfl

/-- Concrete boundaries of the compiled setup chain: s4/S4 and s6/S6.
The final cut is s16/S16, with the framed prompt and anchors retained. -/
noncomputable def g0a (NB T : Nat) (tk : Nat → Nat) :
    GluePiece FF setupRows
      (fun i => ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk i.L)
      (fun i => withSetupInputs T tk (chunkCallFixedCut NB T tk i.L)) where
  m := [(9, .L)]
  n := 900
  O := PRE_setup_early_r0.S0.oracle
  chk := by decide +kernel
  ok r hr i hi _ := by
    have hc : goodLin r.ps (varsOf r.V [(9, .L)]) PRE_setup_early_r0.S0.oracle = true := by
      have all : ∀ r ∈ setupRows, goodLin r.ps (varsOf r.V [(9, .L)]) PRE_setup_early_r0.S0.oracle = true :=
        by decide +kernel
      exact all r hr
    exact (((initial_chunkCall_fixed_oracle_keeps (fun _ hm => good_of_row hc hi hm)).withInputs T tk).cast rfl rfl rfl).convL
      (initial (setupBound hr hi))

/-- The site oracle uses variable 9; the standalone K8 oracle uses variable 0. -/
noncomputable def chunk_K8_literal (NB T : Nat) (tk : Nat → Nat) :
    StagePiece FF [setup_early.r0] [⟨[(0, .L)], Stage.ChunkSize.K8.O⟩]
      (fun i => withSetupInputs T tk (chunkCallFixedCut NB T tk i.L))
      (fun i => withSetupInputs T tk (setupChunkCut NB T tk i.L)) where
  m := [(9, .L)]
  n := 101
  O := PRE_setup_early_r0.st0.S0.oracle
  chk r hr := by
    have : r = setup_early.r0 := List.mem_singleton.mp hr
    subst r
    exact stageOracle
  ok r hr i hi _ := by
    have : r = setup_early.r0 := List.mem_singleton.mp hr
    subst r
    obtain ⟨h1, h8⟩ := bounds hi
    exact StageCall.intro (CutConv.refl _) ((chunkCall_merged_keeps h1 h8).withInputs T tk)
      (merged_compact_keeps.withInputs T tk)

end Host.Ts.Sim.Compose.FillSetupEarly
