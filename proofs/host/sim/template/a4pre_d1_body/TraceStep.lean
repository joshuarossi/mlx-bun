import host.sim.template.a4pre_d1_body.TraceRest
import host.sim.template.a4pre_d1_body.Advance
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

abbrev typedJ (bytes : List Byte) : Disp.JSP FF :=
  { D1Frames.typedJ bytes with okCall := callOk setupP, smallB := smallB setupP loopVB }

noncomputable def typedOk (bytes : List Byte) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (typedJ bytes) (okBackFXS setupP) 4096

theorem typed_wp (bytes : List Byte) : Disp.Wp (typedJ bytes) (D1Frames.typedW bytes) := by
  intro a w hw
  change Disp.wideAt (D1Frames.typedJ bytes) a = some w
  exact D1Frames.typed_wp bytes a w hw

theorem call_rest (P : LoadP) (rest : List NumV) :
    callOk {P with rest := rest} = callOk P := by
  funext x name args
  unfold callOk
  rw [Host.Ts.Sim.Compose.SetupEarly.callRaiseRest P rest, additional_rest P rest]

theorem simulation (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (D1BodyAdvance.Native NB T tk y0) (typedOk bytes)
      (Disp.KpJ (D1Frames.typedJ bytes) 4096) (D1Frames.typedW bytes) [] (VBOkF loopVB) := by
  let P : LoadP := {setupP with rest := machReads T tk}
  have hJ : (typedJ bytes).okCall = callOk P := (call_rest setupP (machReads T tk)).symm
  have hsb : (typedJ bytes).smallB = smallB P loopVB :=
    (smallB_rest setupP (machReads T tk) loopVB).symm
  have hC : FfiCallSim FF (FullRXD P NB) (typedJ bytes).okCall (small P) := by
    rw [hJ]
    exact callSim P NB rfl
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hW := typed_wp bytes
  have hkp : Disp.KpJ (typedJ bytes) 4096 = Disp.KpJ (D1Frames.typedJ bytes) 4096 := by
    funext K
    rfl
  have hs : Disp.StepSimXLB FF (D1BodyAdvance.Native NB T tk y0)
      (Disp.okJSJ (typedJ bytes) (okBackFXS P) 4096) (Disp.KpJ (typedJ bytes) 4096)
      (D1Frames.typedW bytes) [] (VBOkF loopVB) :=
    Disp.stepSimXLBJS ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun ν S x name args hν hb => smallB_sound (P := P) (VB := loopVB) hν (by
      rw [hsb] at hb
      exact hb))
    (fun ν S x arg hν hb => smallBackFB_sound (VB := loopVB) hν (by
      change smallBackFB loopVB S x arg = true at hb
      exact hb))
    (fullRXD_laws P NB).liftQ fullLawful
    (fullNativeFactsXD P NB (typedJ bytes) rfl rfl rfl).liftQ hW
  rw [hkp] at hs
  simpa only [typedOk, P, Host.Ts.Sim.Compose.SetupEarly.backRest] using hs

noncomputable def checkedOk (bytes : List Byte) (s : St FF.S) (S : SSrv) : Bool :=
  D1Frames.typedOk bytes s S || typedOk bytes s S

theorem checkedSimulation (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (D1BodyAdvance.Native NB T tk y0) (checkedOk bytes)
      (Disp.KpJ (D1Frames.typedJ bytes) 4096) (D1Frames.typedW bytes) [] (VBOkF loopVB) := by
  intro M ν K s S t C s1 S1 hK hν hr hh hl hok hrun
  simp only [checkedOk, Bool.or_eq_true] at hok
  rcases hok with hold | hnew
  · exact D1BodyAdvance.simulation NB T tk bytes y0 M ν K s S t C s1 S1 hK hν hr hh hl hold hrun
  · exact simulation NB T tk bytes y0 M ν K s S t C s1 S1 hK hν hr hh hl hnew hrun

end Host.Load.Run.Tpl.D1BodyTrace
