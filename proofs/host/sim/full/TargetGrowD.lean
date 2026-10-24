import host.sim.full.BridgeStepD
import host.sim.full.TargetGrow

/-! # The target's mlx growth along checked runs with continuations

`TargetGrow`'s growth for the one-step theorems with continuations (`Disp.okJSK`): at a raise
(`FullRD`, `okBackF`; `fullStepSimXLBDKQ`) and with the Neural Engine bridge at a raise (`FullRXD`,
`okBackFX`; `fullStepSimXLBXDKQ`). The glue segments' growth (`glue_ngrow`, `glueCall_ngrow`) holds
for any such simulation carrying the growth. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.Ffi.NGrowCall (NInv)

theorem backSim_liftQ {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {Q : F.S → Prop} {okBack : F.S → Arg → Bool}
    (hB : FfiBackSim F FR okBack) (hL : BufSim.FfiLawful F) (hQ : TargetPres F FR Q) :
    FfiBackSim F (FRQ FR Q) okBack where
  back M ν S C x y a hs hr hok hsupp :=
    MSim.mono (MSim.withRunT (hB.back M ν S C x y a hs hr.1 hok hsupp) (hL.back _ _) (hL.back _ _))
      fun _ _ C' _ _ ⟨⟨hg, hc⟩, hrun⟩ => ⟨hg, hc.liftQ fun y' rr ws e => by
        subst e; exact hQ.back M _ x y _ C y' rr ws C' hr.1 hr.2 hrun⟩

theorem fullRXD_ninv {P : LoadP} {NB : Nat} : ∀ M n x y, FullRXD P NB M n x y → NInv (mlxOf y) := by
  rintro M n x y ⟨P', -, hr⟩
  exact fun h hh => (hr.load.mlx.yabsent h hh).2

/-- `fullStepSimXLBDK` with the target's growth from `y0`. -/
theorem fullStepSimXLBDKQ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSD P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) (Disp.okJSK J (okBackF P))
      (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSDD P NB
  have hQ := fullTargetPres (FR := FullRD P NB) fullRD_ninv y0
  exact Disp.stepSimXLBK ((fullFfiSimD P NB).liftQ fullLawful hQ) (backSim_liftQ (fullBackSimD P NB) fullLawful hQ)
    (hC.liftQ fullLawful hQ) (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB).liftQ fullLawful (fullNativeFactsD P NB J hlo hh hg).liftQ hW

/-- `fullStepSimXLBXDK` with the target's growth from `y0`. -/
theorem fullStepSimXLBXDKQ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFXD P)
    (hsm : J.smallB = smallFX2B VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullRXD P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) (Disp.okJSK J (okBackFX P))
      (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRXD P NB) J.okCall smallFX2 := by rw [hJ]; exact fullCallSimXD P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  exact Disp.stepSimXLBK ((fullFfiSimXD P NB).liftQ fullLawful hQ) (backSim_liftQ (fullBackSimXD P NB) fullLawful hQ)
    (hC.liftQ fullLawful hQ) (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB J hlo hh hg).liftQ hW

section
variable {FR : Map → Nat → FF.S → FF.S → Prop} {ok : St FF.S → SSrv → Bool} {Kp : Ctx → Prop}
  {VBOk : (Nat → F64) → Prop} {W : Nat → Option WFrame}
  (hsim : ∀ y0 : Host.Mlx.Ffi.St,
    Disp.StepSimXLB FF (FRQ FR fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) ok Kp W [] VBOk)
include hsim

/-- **The target's mlx state grows along a glue segment** (a checked run of `n` steps), under a
simulation carrying the growth. -/
theorem glue_ngrow {sa sb : St FF.S} {Sa Sb : SSrv} {n : Nat} (hok : ok sa Sa = true)
    (hrun : runOk FF ok n sa Sa = some (sb, Sb)) {M : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S}
    {C C' : CSrv} (hν : VBOk ν) (hK : Kp K) (hr : RelB FF FR W [] M ν K sa Sa t C)
    (ht : runC FF n t C = some (t', C')) : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  obtain ⟨M1, t1, C1, hr1, -, hx1⟩ := Disp.runOk_simXVB FF _ _ Kp W [] VBOk (hsim (mlxOf t.ffi)).xv
    (fun _ _ _ => .inl rfl) ν K hK hν n M sa Sa t C sb Sb (.inl (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))) hok hrun
  rw [ht] at hr1
  cases hr1
  exact relXB_q hx1

/-- **The target's mlx state grows along a glue segment and the step into the next call.** -/
theorem glueCall_ngrow {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {n : Nat} (hok : ok sa Sa = true)
    (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (hokb : ok sb Sb = true) (hhalt : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) {M : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S}
    {C C' : CSrv} (hν : VBOk ν) (hK : Kp K) (hr : RelB FF FR W [] M ν K sa Sa t C)
    (ht : runC FF (n + 1) t C = some (t', C')) : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  have hs := hsim (mlxOf t.ffi)
  obtain ⟨M1, t1, C1, hr1, -, hx1⟩ := Disp.runOk_simXVB FF _ _ Kp W [] VBOk hs.xv
    (fun _ _ _ => .inl rfl) ν K hK hν n M sa Sa t C sb Sb (.inl (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))) hok hrun
  obtain ⟨M2, t2, C2, ht2, -, hx2⟩ := hs M1 ν K sb Sb t1 C1 sc Sc hK hν hx1 hhalt (.inl rfl) hokb hstep
  have hth : isHalt t1.ctl = false := by rw [hx1.isHalt, hhalt]
  rw [runC_trans hr1 (runC_one hth ht2)] at ht
  cases ht
  exact relXB_q hx2

end

end Host.Ts.Sim.Full
