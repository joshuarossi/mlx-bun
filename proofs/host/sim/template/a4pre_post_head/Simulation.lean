import host.sim.template.a4pre_post_head.Small
import host.sim.compose.a4b.SetupEarlyGlue
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.PostHeadSmall
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly

theorem simulation (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (ok bytes) (Disp.KpJ (J bytes) 4096) (D1Frames.typedW bytes) [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (J bytes).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    (fullFfiSimXD P NB) (fullBackSimXDS P NB)
    (P := J bytes) (by rw [hj]; exact fullCallSimXD P NB)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB (J bytes) rfl rfl rfl) (wp bytes)
  simpa only [P, backRest, ok] using hs

theorem simulation_ngrow (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (ok bytes) (Disp.KpJ (J bytes) 4096) (D1Frames.typedW bytes) [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (J bytes).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (J bytes).okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB (J bytes) rfl rfl rfl).liftQ (wp bytes)
  simpa only [P, backRest, ok] using hs

end Host.Load.Run.Tpl.PostHeadSmall
