import host.sim.template.PostOk
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.dispatch.BridgeSpread
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly
open PostHeadSmall (VP smallFX2_sound)

theorem simulation_ngrow (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      ok (Disp.KpJ J 4096) wideG [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : J.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) J.okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB J rfl rfl rfl).liftQ wp
  simpa only [P, backRest, ok] using hs

theorem simulation0_ngrow (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      ok0 (Disp.KpJ J0 4096) wideGPf [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : J0.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) J0.okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB J0 rfl rfl rfl).liftQ wp0
  simpa only [P, backRest, ok0] using hs

theorem simulationF_ngrow (NB T : Nat) (tk : Nat → Nat) (extra : List Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okF extra) (Disp.KpJ (JF extra) 4096) wideG [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (JF extra).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (JF extra).okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB (JF extra) rfl rfl rfl).liftQ (wpF extra)
  simpa only [P, backRest, okF] using hs

end Host.Load.Run.Tpl.PostOk
