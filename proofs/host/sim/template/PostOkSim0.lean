import host.sim.template.PostOk0
import host.sim.template.PostOkSim
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly
open PostHeadSmall (VP smallFX2_sound)

/-- `simulation0_ngrow` with a final forward's chunk still framed. -/
theorem simulationF0_ngrow (NB T : Nat) (tk : Nat → Nat) (extra : List Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okF0 extra) (Disp.KpJ (J0F extra) 4096) wideGPf [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (J0F extra).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (J0F extra).okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB (J0F extra) rfl rfl rfl).liftQ (wpF0 extra)
  simpa only [P, backRest, okF0] using hs

end Host.Load.Run.Tpl.PostOk
