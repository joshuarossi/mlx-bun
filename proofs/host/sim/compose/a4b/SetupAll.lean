import host.sim.compose.a4b.FillSetupEarly
import host.sim.compose.a4b.FillSetupH0
import host.sim.compose.a4b.FillSetupH1
import host.sim.compose.a4b.FillSetupH2
import host.sim.compose.a4b.FillSetupH3
import host.sim.compose.a4b.FillSetupH4
import host.sim.compose.a4b.FillSetupH5
import host.sim.lin.CoverA
import host.sim.lin.checks.Chunk

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupAll
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

private theorem rowRun {NB T : Nat} {tk : Nat → Nat} {r : Row} {i : Cls.Inst} {obls : List Obl}
    (hr : r ∈ FillSetupEarly.setupRows) (hi : InRow r i)
    (p : StagePiece FF [r] obls
      (fun i => withSetupInputs T tk (SetupChunk.chunkCallFixedCut NB T tk i.L))
      (SetupCommon.cut NB T tk PRE_g0b.s0 PRE_g0b.S0))
    (ho : OblOk i obls) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk i.L)
      (SetupCommon.nextCut NB T tk i.L)
      ((FillSetupEarly.g0a NB T tk).n + p.n + (FillSetupEarly.g0b NB T tk).n) := by
  have hga := (FillSetupEarly.g0a NB T tk).ok r hr i hi
    ⟨obl_of_row hi ((FillSetupEarly.g0a NB T tk).chk r hr), trivial⟩
  have hs := (p.ok r (by simp) i hi ⟨obl_of_row hi (p.chk r (by simp)), ho⟩).step
  have hgb := (FillSetupEarly.g0b NB T tk).ok r hr i hi
    ⟨obl_of_row hi ((FillSetupEarly.g0b NB T tk).chk r hr), trivial⟩
  exact (hga.trans hs).trans hgb

theorem row {NB T : Nat} {tk : Nat → Nat} {r : Row} {i : Cls.Inst}
    (hr : r ∈ FillSetupEarly.setupRows) (hi : InRow r i) :
    ∃ n, CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk i.L)
      (SetupCommon.nextCut NB T tk i.L) n := by
  simp only [FillSetupEarly.setupRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (FillSetupEarly.chunk_K8__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_early.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH0.chunk_K2048__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h0.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH1.chunk_K1024__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h1.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH2.chunk_K512__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h2.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH3.chunk_K256__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h3.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH4.chunk_K128__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h4.r0.chunk, trivial⟩⟩
  · exact ⟨_, rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH5.chunk_K64__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h5.r0.chunk, trivial⟩⟩

noncomputable def count (NB T : Nat) (tk : Nat → Nat) : SetupClass → Nat
  | .early => (FillSetupEarly.g0a NB T tk).n + (FillSetupEarly.chunk_K8__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h0 => (FillSetupEarly.g0a NB T tk).n + (SetupH0.chunk_K2048__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h1 => (FillSetupEarly.g0a NB T tk).n + (SetupH1.chunk_K1024__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h2 => (FillSetupEarly.g0a NB T tk).n + (SetupH2.chunk_K512__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h3 => (FillSetupEarly.g0a NB T tk).n + (SetupH3.chunk_K256__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h4 => (FillSetupEarly.g0a NB T tk).n + (SetupH4.chunk_K128__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n
  | .h5 => (FillSetupEarly.g0a NB T tk).n + (SetupH5.chunk_K64__g0a__g0b NB T tk).n + (FillSetupEarly.g0b NB T tk).n

theorem forClass_count {NB T L : Nat} {tk : Nat → Nat} {c : SetupClass}
    (h1 : 1 ≤ L) (h2 : L ≤ 262143) (ha : c.Applies L) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (SetupCommon.nextCut NB T tk L) (count NB T tk c) := by
  cases c
  · obtain ⟨r, hr, hi⟩ := setup_early.cover L h1 h2 ha
    have he : r = setup_early.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (FillSetupEarly.chunk_K8__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_early.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h0.cover L h1 h2 ha
    have he : r = setup_h0.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH0.chunk_K2048__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h0.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h1.cover L h1 h2 ha
    have he : r = setup_h1.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH1.chunk_K1024__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h1.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h2.cover L h1 h2 ha
    have he : r = setup_h2.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH2.chunk_K512__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h2.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h3.cover L h1 h2 ha
    have he : r = setup_h3.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH3.chunk_K256__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h3.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h4.cover L h1 h2 ha
    have he : r = setup_h4.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH4.chunk_K128__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h4.r0.chunk, trivial⟩
  · obtain ⟨r, hr, hi⟩ := setup_h5.cover L h1 h2 ha
    have he : r = setup_h5.r0 := List.mem_singleton.mp hr
    subst r
    exact rowRun (by simp [FillSetupEarly.setupRows]) hi (SetupH5.chunk_K64__g0a__g0b NB T tk)
      ⟨obl_of_row hi setup_h5.r0.chunk, trivial⟩

theorem forClass {NB T L : Nat} {tk : Nat → Nat} {c : SetupClass}
    (h1 : 1 ≤ L) (h2 : L ≤ 262143) (ha : c.Applies L) :
    ∃ n, CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (SetupCommon.nextCut NB T tk L) n :=
  ⟨count NB T tk c, forClass_count h1 h2 ha⟩

/-- Every supported prompt length reaches the shared prefill boundary through
one checked chunk template and the common continuation. -/
theorem setup {NB T L : Nat} {tk : Nat → Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    ∃ n, CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (SetupCommon.nextCut NB T tk L) n :=
  forClass h1 h2 ((Host.Ts.Sim.Prefill.setup_cover h1 (by omega)).2.1)

end Host.Ts.Sim.Compose.SetupAll
