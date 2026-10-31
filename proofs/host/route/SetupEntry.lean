import host.route.LoadCut
import host.sim.compose.PreFill
import host.sim.template.FullOk
import host.sim.template.EndGen
import host.sim.template.SetupP
import host.sim.template.a4pre_setup_early_r0.Start
import host.sim.template.a4pre_setup_early_r0.OkB
namespace Host.Route
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Lin.Cls
open Host.Load.Run.Tpl

/-- The actual setup acceptance: only the prompt is framed in the context. -/
abbrev setupJ : Disp.JSP FF := fullJSPPXS setupP [2665] [(4910, .memo [])]

/-- These are the parameters of the checked first segment, including its offset budget. -/
theorem setup_acceptance (s : St FF.S) (S : SSrv) :
    PRE_setup_early_r0.okB0 s S = Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S := rfl

theorem setupW_ok : Disp.Wp setupJ wideP := by
  intro a w hw
  simpa only [wideP, Disp.wideAt, Disp.lookupW] using hw

/-- The prompt frame's real prefixes come from the loaded prompt, independently of variable 9. -/
theorem ldCut_setupFrame {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
      x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 0 ∧ AneFresh x.t := by
  obtain ⟨π, hL, hv, hK⟩ := hB.2.2.2.1
  refine ⟨π, hL, hv, ?_, ?_, hB.2.2.2.2⟩
  · rw [hK, Host.Load.Run.Prompt.FrameRel.ctx_fr]
    rfl
  · rw [hK]
    rfl

/-- The load context already has exactly the setup's frame domain and zero offset. -/
theorem ldCut_setupContext {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none := by
  obtain ⟨π, _, _, hK⟩ := hB.2.2.2.1
  rw [hK]
  refine ⟨⟨⟨rfl, rfl, ?_⟩, by change 0 ≤ 4096; decide⟩, ?_⟩
  · intro a
    rw [Host.Load.Run.Prompt.FrameRel.ctx_fr]
    by_cases ha : a = 2665 <;> simp [ha]
  · rw [Host.Load.Run.Prompt.FrameRel.ctx_fr]
    simp

/-- Fresh variable 9 carries the row quantity; all loaded inputs retain their values. -/
theorem ldCut_setupValues_bound {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hL : L ≤ 2 ^ 20)
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    VBOkF loopVB (rowVal x.ν L) ∧ MapOk (rowVal x.ν L) (setupI L) [(9, .L)] ∧
      (∀ i, i < 9 → rowVal x.ν L i = machVal T tk i) := by
  refine ⟨?_, ⟨rowVal_at x.ν L, trivial⟩, ?_⟩
  · exact rowVal_bounded x.ν L (2 ^ 20) hB.2.2.1 (by omega)
  · intro i hi
    rw [rowVal_reserved x.ν L i hi, hB.2.1]


theorem ldCut_setupValues {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hctx : L + T ≤ 262144)
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    VBOkF loopVB (rowVal x.ν L) ∧ MapOk (rowVal x.ν L) (setupI L) [(9, .L)] ∧
      (∀ i, i < 9 → rowVal x.ν L i = machVal T tk i) :=
  ldCut_setupValues_bound (by omega) hB

/-- The explicit converted pair, retaining the actual frame witness for later length bridges. -/
theorem ldCut_setupEntryAt_bound {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hL : L ≤ 2 ^ 20)
    (hR : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).R x
      (Host.Load.Run.Prompt.ldStT [] []) ⟨Host.Load.Decode.tab, []⟩)
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    (pbCut (FullRXD { setupP with rest := machReads T tk } NB) setupJ wideP [(9, .L)]
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 (setupI L)).R
      { x with ν := rowVal x.ν L } PRE_setup_early_r0.s0 ⟨PRE_setup_early_r0.S0.tab, []⟩ ∧
    Disp.KpJ setupJ 4096 x.K ∧
    ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
      x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 0 ∧ AneFresh x.t := by
  refine ⟨⟨?_, ?_⟩, (ldCut_setupContext hB).1, ldCut_setupFrame hB⟩
  · change RelB FF (FullRXD { setupP with rest := machReads T tk } NB) wideP []
      x.M (rowVal x.ν L) x.K PRE_setup_early_r0.s0 ⟨PRE_setup_early_r0.S0.tab, []⟩ x.t x.C
    rw [PRE_setup_early_r0.start_eq, PRE_setup_early_r0.start_tab]
    exact ldCut_rowR hR
  · exact ⟨(ldCut_setupValues_bound hL hB).1, (ldCut_setupContext hB).1.1,
      (ldCut_setupValues_bound hL hB).2.1⟩


theorem ldCut_setupEntryAt {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hctx : L + T ≤ 262144)
    (hR : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).R x
      (Host.Load.Run.Prompt.ldStT [] []) ⟨Host.Load.Decode.tab, []⟩)
    (hB : (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L).B x) :
    (pbCut (FullRXD { setupP with rest := machReads T tk } NB) setupJ wideP [(9, .L)]
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 (setupI L)).R
      { x with ν := rowVal x.ν L } PRE_setup_early_r0.s0 ⟨PRE_setup_early_r0.S0.tab, []⟩ ∧
    Disp.KpJ setupJ 4096 x.K ∧
    ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
      x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 0 ∧ AneFresh x.t :=
  ldCut_setupEntryAt_bound (by omega) hR hB

/-- Convert the actual loadDone relation into the checked setup's first cut. The target,
server, map and context are retained; only the fresh row variable changes. -/
theorem ldCut_setupEntry {NB T L : Nat} {tk : Nat → Nat} (hctx : L + T ≤ 262144) :
    CutConv (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (pbCut (FullRXD { setupP with rest := machReads T tk } NB) setupJ wideP [(9, .L)]
        PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 (setupI L)) := by
  intro x hR hB
  exact ⟨{ x with ν := rowVal x.ν L }, rfl, rfl, (ldCut_setupEntryAt hctx hR hB).1, trivial⟩

/-- Bookkeeping at the initial setup boundary, before any setup execution. -/
def setupInitialBook (L : Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
    ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
      x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 0 ∧ AneFresh x.t

/-- The checked setup's first cut, retaining the loaded prompt and initial context facts. -/
noncomputable def setupInitialCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (FullRXD { setupP with rest := machReads T tk } NB) setupJ wideP [(9, .L)]
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 (setupI L) with
    B := setupInitialBook L }

/-- Derive all initial bookkeeping from the loadDone cut, changing only fresh variable 9. -/
theorem ldCut_setupInitial {NB T L : Nat} {tk : Nat → Nat} (hctx : L + T ≤ 262144) :
    CutConv (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (setupInitialCut NB T tk L) := by
  intro x hR hB
  have hentry := ldCut_setupEntryAt hctx hR hB
  exact ⟨{ x with ν := rowVal x.ν L }, rfl, rfl, hentry.1,
    hentry.2.1, (ldCut_setupContext hB).2, hentry.2.2⟩

/-- Forget the initial bookkeeping when only the original setup cut is needed. -/
theorem setupInitialCut_forget (NB T : Nat) (tk : Nat → Nat) (L : Nat) :
    CutConv (setupInitialCut NB T tk L)
      (pbCut (FullRXD { setupP with rest := machReads T tk } NB) setupJ wideP [(9, .L)]
        PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 (setupI L)) := by
  intro x hR _
  exact ⟨x, rfl, rfl, hR, trivial⟩

end Host.Route
