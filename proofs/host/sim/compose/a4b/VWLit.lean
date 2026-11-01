import host.sim.compose.a4b.VWLitDefs
import host.sim.compose.a4b.VWSim
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The one-step theorems of the body's acceptance over a literal prompt length

`bodyLitSim`, `bodyLitGrowSim`, `bodyLitLocalSim` and `bodyLitGrowLocalSim` are those of `bodySim`, `typedGrowSimAt`,
`bodyLocalSim` and `bodyGrowLocalSim` at `VWFrames.bodyLitOk`, same relation, context and frames. -/

namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem bodyLitSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.bodyLitOk bytes n) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (VWFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs : Disp.StepSimXLB FF (Disp.FRJ (FullRXD P NB))
      (Disp.okJSLit (VWFrames.typedJ bytes n) (okBackFXS P) VWFrames.bodyD0)
      (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) :=
    Disp.stepSimXLBJLit (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hj]; exact fullCallSimXD P NB)
      (fun _ _ _ _ _ hν hb => smallFX2B_sound hν hb) (fun _ _ _ _ hν hb => smallBackFB_sound hν hb)
      (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB (VWFrames.typedJ bytes n) rfl rfl rfl)
      (VWFrames.typed_wp bytes n)
  unfold VWFrames.bodyLitOk
  simpa only [P, backRest] using hs

theorem bodyLitGrowSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (VWFrames.bodyLitOk bytes n) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (VWFrames.typedJ bytes n).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (VWFrames.typedJ bytes n).okCall smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs : Disp.StepSimXLB FF (Disp.FRJ (FRQ (FullRXD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSLit (VWFrames.typedJ bytes n) (okBackFXS P) VWFrames.bodyD0)
      (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0) (VWFrames.typedW bytes n) stk (VBOkF loopVB) :=
    Disp.stepSimXLBJLit ((fullFfiSimXD P NB).liftQ fullLawful hQ)
      (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
      (fun _ _ _ _ _ hν hb => smallFX2B_sound hν hb) (fun _ _ _ _ hν hb => smallBackFB_sound hν hb)
      (fullRXD_laws P NB).liftQ fullLawful
      (fullNativeFactsXD P NB (VWFrames.typedJ bytes n) rfl rfl rfl).liftQ (VWFrames.typed_wp bytes n)
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  unfold VWFrames.bodyLitOk
  simpa only [P, backRest] using hs

theorem bodyLitLocalSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (okLocal (VWFrames.bodyLitOk bytes n)) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  apply (bodyLitSim NB T tk bytes n stk).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

theorem bodyLitGrowLocalSim (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (n : Nat) (stk : List Frame)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okLocal (VWFrames.bodyLitOk bytes n)) (Disp.KpJ (VWFrames.typedJ bytes n) VWFrames.bodyD0)
      (VWFrames.typedW bytes n) stk (VBOkF loopVB) := by
  apply (bodyLitGrowSim NB T tk bytes n stk y0).mono
  intro s S h
  simp only [okLocal, Bool.and_eq_true] at h
  exact h.1

end Host.Ts.Sim.Compose.VWFirst
