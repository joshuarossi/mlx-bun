import host.sim.template.a4pre_post_head.Small
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.full.JsLimit
import host.sim.conv.RunAccept
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PostSimulation
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Run.Tpl
open Host.Ts.Sim.Compose.SetupEarly

abbrev params (T : Nat) (tk : Nat → Nat) : LoadP := { setupP with rest := machReads T tk }

abbrev ok (bytes : List Byte) (limit cap : Nat) :=
  Disp.okJSJLimit (PostHeadSmall.J bytes) limit cap (okBackFXS setupP)

/-- POST's checked row-smallness proof serves every prompt length and admitted offset. -/
theorem simulation (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (limit cap : Nat)
    (hlimit : limit ≤ jsSignedLimit) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD (params T tk) NB)) (ok bytes limit cap)
      (Disp.KpJ (PostHeadSmall.J bytes) cap) (D1Frames.typedW bytes) stk PostHeadSmall.VP := by
  have hj : (PostHeadSmall.J bytes).okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hs := Disp.stepSimXLBJSLimit (P := PostHeadSmall.J bytes) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit (fullFfiSimXD (params T tk) NB)
    (fullBackSimXDS (params T tk) NB) (by rw [hj]; exact fullCallSimXD (params T tk) NB)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB) fullLawful
    (fullNativeFactsXD (params T tk) NB (PostHeadSmall.J bytes) rfl rfl rfl)
    (PostHeadSmall.wp bytes)
  simpa only [params, backRest, ok] using hs

/-- The same POST simulation retains the actual target's native growth. -/
theorem simulationQ (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (limit cap : Nat)
    (hlimit : limit ≤ jsSignedLimit) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (ok bytes limit cap) (Disp.KpJ (PostHeadSmall.J bytes) cap)
      (D1Frames.typedW bytes) stk PostHeadSmall.VP := by
  have hj : (PostHeadSmall.J bytes).okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (params T tk) NB) (PostHeadSmall.J bytes).okCall smallFX2 := by
    rw [hj]; exact fullCallSimXD (params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := PostHeadSmall.J bytes) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit ((fullFfiSimXD (params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (params T tk) NB (PostHeadSmall.J bytes) rfl rfl rfl).liftQ
    (PostHeadSmall.wp bytes)
  simpa only [params, backRest, ok] using hs

theorem accepted_signed {bytes : List Byte} {cap : Nat} {s : St FF.S} {S : SSrv}
    (hcap : cap ≤ 4096 + 1593835520) (h : PostHeadSmall.ok bytes s S = true) :
    ok bytes jsSignedLimit cap s S = true :=
  Disp.okJSJLimit_signed_of_allowance hcap h

theorem run_signed {bytes : List Byte} {cap n : Nat} {s s1 : St FF.S} {S S1 : SSrv}
    (hcap : cap ≤ 4096 + 1593835520)
    (h : runOk FF (PostHeadSmall.ok bytes) n s S = some (s1, S1)) :
    runOk FF (ok bytes jsSignedLimit cap) n s S = some (s1, S1) :=
  runOk_mono (fun _ _ => accepted_signed hcap) h

end Host.Route.PostSimulation
