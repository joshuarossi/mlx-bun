import host.sim.template.FlatFwd
import host.sim.template.PostOkSim
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # POST's row acceptance

A row's forward at `PostOk.J`'s frames, with its convolutions and reshapes small at the row count too (`FlatFwd`'s smallness at
variable 10), over the fast table: `runOkS` at `okRN` is `runOk` at `okR` (`okRN_ok`). The contexts and the valuations are `PostOk.ok`'s. -/

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly
open PostHeadSmall (VP)

abbrev JR : Disp.JSP FF := { J with smallB := FlatFwd.smallFX2 10 }

noncomputable def okR : St FF.S → SSrv → Bool :=
  Disp.okJSJ JR (okBackFXS setupP) 4096

noncomputable def okRN : St FF.S → FSrv → Bool :=
  Disp.okJSJN JR (okBackFXS setupP) 4096 (FlatFwd.smallFX2F 10)

theorem okRN_ok (s : St FF.S) (c : FSrv) (h : c.Wf) : okRN s c = okR s c.toS :=
  Disp.okJSJN_eq JR (okBackFXS setupP) 4096 (fun _ x name args hw => FlatFwd.smallFX2F_eq 10 hw x name args) s h

theorem kpR (K : Host.Ts.Sim.Ctx) : Disp.KpJ JR 4096 K ↔ Disp.KpJ J 4096 K := Iff.rfl

theorem simulationR_ngrow (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF
      (Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
        fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      okR (Disp.KpJ JR 4096) wideP [] VP := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : JR.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) JR.okCall Full.smallFX2 := by
    rw [hj]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP) (fun _ _ _ _ _ hν hb => FlatFwd.smallFX2_sound (r := 10) hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB JR rfl rfl rfl).liftQ wp
  simpa only [P, backRest, okR] using hs

end Host.Load.Run.Tpl.PostOk
