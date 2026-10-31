import host.sim.compose.a4b.D1G2
import host.sim.compose.a4b.D1Common
import host.sim.compose.Reach
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable abbrev start (NB T : Nat) (tk : Nat → Nat) (π : List Nat) := SetupCommon.nextCut NB T tk π 1
noncomputable def g1Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) := reached (start NB T tk π) (D1Split.g1Cut NB T tk) 180
noncomputable def dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) := reached (start NB T tk π) (D1Split.dispatchCut NB T tk) 441
noncomputable def g2Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) := reached (start NB T tk π) (D1Split.g2Cut NB T tk) 596
noncomputable def forwardCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) := reached (start NB T tk π) (D1Split.forwardCut NB T tk) 603

noncomputable def nps_FIN_first__start__g1_FIN_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    StagePiece FF [final_cold.r0] [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.FIN.O⟩]
      (fun i => SetupCommon.nextCut NB T tk π i.L) (fun _ => g1Cut NB T tk π) where
  m := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π).m
  n := 180
  O := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π).O
  chk := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π).chk
  ok r hr i hi ho := by
    have hs := ((D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π).ok r hr i hi ho).step
    obtain rfl := List.mem_singleton.mp hr
    have hL : i.L = 1 := D1Split.finalRowL hi
    change StageCall (SetupCommon.nextCut NB T tk π i.L) (g1Cut NB T tk π) 180
    rw [hL] at hs ⊢
    exact StageCall.intro (CutConv.refl _) (CutStep.record hs) (CutConv.refl _)

noncomputable def g1_FIN_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    GluePiece FF [final_cold.r0] (fun _ => g1Cut NB T tk π) (fun _ => dispatchCut NB T tk π) where
  m := (D1Split.g1_FIN_first NB T tk).m
  n := 261
  O := (D1Split.g1_FIN_first NB T tk).O
  chk := (D1Split.g1_FIN_first NB T tk).chk
  ok r hr i hi ho := CutStep.reached ((D1Split.g1_FIN_first NB T tk).ok r hr i hi ho)

noncomputable def disp_D1__g1_FIN_first__g2_fin_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    StagePiece FF [final_cold.r0] [] (fun _ => dispatchCut NB T tk π) (fun _ => g2Cut NB T tk π) where
  m := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk).m
  n := 155
  O := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk).O
  chk := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk).chk
  ok r hr i hi ho := StageCall.intro (CutConv.refl _)
    (CutStep.reached (((D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk).ok r hr i hi ho).step)) (CutConv.refl _)

noncomputable def g2_fin_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    GluePiece FF [final_cold.r0] (fun _ => g2Cut NB T tk π) (fun _ => forwardCut NB T tk π) where
  m := (D1Split.g2_fin_first NB T tk).m
  n := 7
  O := (D1Split.g2_fin_first NB T tk).O
  chk := (D1Split.g2_fin_first NB T tk).chk
  ok r hr i hi ho := CutStep.reached ((D1Split.g2_fin_first NB T tk).ok r hr i hi ho)

/-- The forward's call at the route's prompt and within the template's native counters. -/
noncomputable def forwardPinCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) : ICut FF :=
  { SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV) with
    B := fun x => (SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV)).B x ∧
      NativeAt 0 0 Host.Load.Run.Tpl.D1StageSplit.s22 x.t }

/-- The checked prefix and the split stages run from the same start: the prefix's prompt and the
stages' native bound hold at the same target. -/
theorem toForwardPrompt (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :
    CutConv (forwardCut NB T tk π) (forwardPinCut NB T tk π) := by
  rintro x ⟨_, t0, C0, hi, hr⟩ hB
  obtain ⟨t', C', hd, y, hyt, hyc, hyR, hyB⟩ := D1Common.toForwardPrompt NB T tk π t0 C0 hi
  rw [hr] at hd
  cases hd
  exact ⟨y, hyt, hyc, hyR, hyB, by rw [← hyt]; exact hB.2.2⟩

end Host.Ts.Sim.Compose.D1First
