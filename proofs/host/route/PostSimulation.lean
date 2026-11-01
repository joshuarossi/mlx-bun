import host.sim.template.PostOk
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.dispatch.BridgeSpread
import host.sim.full.JsLimit
import host.sim.conv.RunAccept
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PostSimulation
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose.SetupEarly

abbrev params (T : Nat) (tk : Nat → Nat) : LoadP := { setupP with rest := machReads T tk }

abbrev ok (limit cap : Nat) :=
  Disp.okJSJLimit PostOk.J limit cap (okBackFXS setupP)

/-- With the arrays a tail's spread frames. -/
abbrev okF (extra : List Nat) (limit cap : Nat) :=
  Disp.okJSJLimit (PostOk.JF extra) limit cap (okBackFXS setupP)

/-- POST's checked row-smallness proof serves every prompt length and admitted offset. -/
theorem simulation (NB T : Nat) (tk : Nat → Nat) (limit cap : Nat)
    (hlimit : limit ≤ jsSignedLimit) (stk : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD (params T tk) NB)) (ok limit cap)
      (Disp.KpJ PostOk.J cap) wideP stk PostHeadSmall.VP := by
  have hj : PostOk.J.okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hs := Disp.stepSimXLBJSLimit (P := PostOk.J) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit (fullFfiSimXD (params T tk) NB)
    (fullBackSimXDS (params T tk) NB) (by rw [hj]; exact fullCallSimXD (params T tk) NB)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB) fullLawful
    (fullNativeFactsXD (params T tk) NB PostOk.J rfl rfl rfl)
    PostOk.wp
  simpa only [params, backRest, ok] using hs

/-- The same POST simulation retains the actual target's native growth. -/
theorem simulationQ (NB T : Nat) (tk : Nat → Nat) (limit cap : Nat)
    (hlimit : limit ≤ jsSignedLimit) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (ok limit cap) (Disp.KpJ PostOk.J cap) wideP stk PostHeadSmall.VP := by
  have hj : PostOk.J.okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (params T tk) NB) PostOk.J.okCall smallFX2 := by
    rw [hj]; exact fullCallSimXD (params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := PostOk.J) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit ((fullFfiSimXD (params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (params T tk) NB PostOk.J rfl rfl rfl).liftQ
    PostOk.wp
  simpa only [params, backRest, ok] using hs

/-- `simulationQ` after a tail's spread. -/
theorem simulationFQ (NB T : Nat) (tk : Nat → Nat) (extra : List Nat) (limit cap : Nat)
    (hlimit : limit ≤ jsSignedLimit) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD (params T tk) NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (okF extra limit cap) (Disp.KpJ (PostOk.JF extra) cap) wideP stk PostHeadSmall.VP := by
  have hj : (PostOk.JF extra).okCall = okCallFXD (params T tk) :=
    (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD (params T tk) NB) (PostOk.JF extra).okCall smallFX2 := by
    rw [hj]; exact fullCallSimXD (params T tk) NB
  have hQ := fullTargetPres (FR := FullRXD (params T tk) NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := PostOk.JF extra) (D0 := cap) (stk := stk)
    (VBOk := PostHeadSmall.VP) hlimit ((fullFfiSimXD (params T tk) NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS (params T tk) NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => PostHeadSmall.smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws (params T tk) NB).liftQ fullLawful
    (fullNativeFactsXD (params T tk) NB (PostOk.JF extra) rfl rfl rfl).liftQ
    (PostOk.wpF extra)
  simpa only [params, backRest, okF] using hs

theorem accepted_signed {cap : Nat} {s : St FF.S} {S : SSrv}
    (hcap : cap ≤ 4096 + 1593835520) (h : PostOk.ok s S = true) :
    ok jsSignedLimit cap s S = true :=
  Disp.okJSJLimit_signed_of_allowance hcap h

theorem run_signed {cap n : Nat} {s s1 : St FF.S} {S S1 : SSrv}
    (hcap : cap ≤ 4096 + 1593835520)
    (h : runOk FF PostOk.ok n s S = some (s1, S1)) :
    runOk FF (ok jsSignedLimit cap) n s S = some (s1, S1) :=
  runOk_mono (fun _ _ => accepted_signed hcap) h

theorem acceptedF_signed {extra : List Nat} {cap : Nat} {s : St FF.S} {S : SSrv}
    (hcap : cap ≤ 4096 + 1593835520) (h : PostOk.okF extra s S = true) :
    okF extra jsSignedLimit cap s S = true :=
  Disp.okJSJLimit_signed_of_allowance hcap h

theorem runF_signed {extra : List Nat} {cap n : Nat} {s s1 : St FF.S} {S S1 : SSrv}
    (hcap : cap ≤ 4096 + 1593835520)
    (h : runOk FF (PostOk.okF extra) n s S = some (s1, S1)) :
    runOk FF (okF extra jsSignedLimit cap) n s S = some (s1, S1) :=
  runOk_mono (fun _ _ => acceptedF_signed hcap) h

end Host.Route.PostSimulation
