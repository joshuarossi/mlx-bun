import host.sim.compose.a4b.D1G2
import host.sim.compose.a4b.D1Common
import host.sim.compose.Reach
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

noncomputable abbrev start (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) :=
  withMem (Mem 1) (SetupCommon.nextCut NB T tk π 1)
noncomputable def g1Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) :=
  reached (start NB T tk π Mem) (withMem (Mem 1) (D1Split.g1Cut NB T tk)) 180
noncomputable def dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) :=
  reached (start NB T tk π Mem) (withMem (Mem 1) (D1Split.dispatchCut NB T tk)) 441
noncomputable def g2Cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) :=
  reached (start NB T tk π Mem) (withMem (Mem 1) (D1Split.g2Cut NB T tk)) 596
noncomputable def forwardCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) :=
  reached (start NB T tk π Mem) (withMem (Mem 1) (D1Split.forwardCut NB T tk)) 603

noncomputable def nps_FIN_first__start__g1_FIN_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [final_cold.r0] [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.FIN.O⟩]
      (fun i => withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L)) (fun _ => g1Cut NB T tk π Mem) where
  m := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π Mem hMem).m
  n := 180
  O := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π Mem hMem).O
  chk := (D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π Mem hMem).chk
  ok r hr i hi ho := by
    have hs := ((D1Split.nps_FIN_first__start__g1_FIN_first NB T tk π Mem hMem).ok r hr i hi ho).step
    obtain rfl := List.mem_singleton.mp hr
    have hL : i.L = 1 := D1Split.finalRowL hi
    change StageCall (withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L)) (g1Cut NB T tk π Mem) 180
    rw [hL] at hs ⊢
    exact StageCall.intro (CutConv.refl _) (CutStep.record hs) (CutConv.refl _)

noncomputable def g1_FIN_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [final_cold.r0] (fun _ => g1Cut NB T tk π Mem) (fun _ => dispatchCut NB T tk π Mem) where
  m := (D1Split.g1_FIN_first NB T tk (Mem 1) (hMem 1)).m
  n := 261
  O := (D1Split.g1_FIN_first NB T tk (Mem 1) (hMem 1)).O
  chk := (D1Split.g1_FIN_first NB T tk (Mem 1) (hMem 1)).chk
  ok r hr i hi ho := CutStep.reached ((D1Split.g1_FIN_first NB T tk (Mem 1) (hMem 1)).ok r hr i hi ho)

noncomputable def disp_D1__g1_FIN_first__g2_fin_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [final_cold.r0] [] (fun _ => dispatchCut NB T tk π Mem) (fun _ => g2Cut NB T tk π Mem) where
  m := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk (Mem 1) (hMem 1)).m
  n := 155
  O := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk (Mem 1) (hMem 1)).O
  chk := (D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk (Mem 1) (hMem 1)).chk
  ok r hr i hi ho := StageCall.intro (CutConv.refl _)
    (CutStep.reached (((D1Split.disp_D1__g1_FIN_first__g2_fin_first NB T tk (Mem 1) (hMem 1)).ok r hr i hi ho).step)) (CutConv.refl _)

noncomputable def g2_fin_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [final_cold.r0] (fun _ => g2Cut NB T tk π Mem) (fun _ => forwardCut NB T tk π Mem) where
  m := (D1Split.g2_fin_first NB T tk (Mem 1) (hMem 1)).m
  n := 7
  O := (D1Split.g2_fin_first NB T tk (Mem 1) (hMem 1)).O
  chk := (D1Split.g2_fin_first NB T tk (Mem 1) (hMem 1)).chk
  ok r hr i hi ho := CutStep.reached ((D1Split.g2_fin_first NB T tk (Mem 1) (hMem 1)).ok r hr i hi ho)

kernel_rfl forwardNext : (mlxOf D1StageSplit.s22.ffi).next = (mlxOf D1Call.s1.ffi).next
kernel_rfl forwardNnext : (mlxOf D1StageSplit.s22.ffi).nnext = (mlxOf D1Call.s1.ffi).nnext

/-- The native counters at the forward's call. -/
abbrev NatForward (x : SegInst FF) : Prop := NativeAt 0 0 D1Call.s1 x.t

/-- The checked prefix and the split stages run from one start, so the prefix's witness has the
same target and server: the property and the native counters move across when they read no more than those. -/
theorem toForwardPrompt (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {Mem : Nat → SegInst FF → Prop}
    (hWit : ∀ L x y, y.t = x.t → y.C = x.C → Mem L x → Mem L y) :
    CutConv (forwardCut NB T tk π Mem)
      (withMem (Mem 1) (withMem NatForward (SetupD1PromptIdentity.forwardPromptCut NB T tk (π.map natV)))) := by
  rintro x ⟨_, t0, C0, hi, hr⟩ hB
  obtain ⟨t', C', hd, y, hyt, hyc, hyR, hyB⟩ :=
    (D1Common.toForwardPrompt NB T tk π).convL (withMem_forget (Mem 1) _) t0 C0 hi
  rw [hr] at hd
  cases hd
  have hn : NativeAt 0 0 D1StageSplit.s22 x.t := hB.1.2.2
  refine ⟨y, hyt, hyc, hyR, ⟨hyB, ?_⟩, hWit 1 x y hyt hyc hB.2⟩
  change NativeAt 0 0 D1Call.s1 y.t
  rw [hyt]
  exact ⟨forwardNext ▸ hn.1, forwardNnext ▸ hn.2⟩

end Host.Ts.Sim.Compose.D1First
