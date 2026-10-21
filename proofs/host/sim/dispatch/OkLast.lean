import host.sim.extract.GrowRun
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # The one-step theorem without acceptance of the reached state

`StepSimXV` asks `ok s1 S1 = true` of the reached state, which `stepSimXV`'s proof
never uses. `StepSimXL` drops it, so a checked segment can end at a state `ok`
rejects (the final cases' epilogue spread). -/

/-- `StepSimXV` without acceptance of the reached state. -/
def StepSimXL (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → VBOk ν → RelX F FR M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelX F FR M' ν K s1 S1 t1 C1

/-- A `StepSimXL` gives the `StepSimXV`. -/
theorem StepSimXL.xv {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop}
    {VBOk : (Nat → F64) → Prop} (h : StepSimXL F FR ok Kp VBOk) : StepSimXV F FR ok Kp VBOk :=
  fun M ν K s S t C s1 S1 hK hν hr hh hok hs _ => h M ν K s S t C s1 S1 hK hν hr hh hok hs

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {P : JSP F}

/-- **The one-step simulation, for any reached state.** -/
theorem stepSimXL {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) :
    StepSimXL F FR (okJS P) (Kp P) VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatch hF hC (hsmall ν · · · · hν) hFR hL hN hK hr hh hok) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, hr1⟩
  · have e := RelD.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

/-- `stepSimXL` for the native relation with a kept target property. -/
theorem stepSimXL_Q {Q : F.S → Prop} {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hQ : TargetPres F FR Q) :
    StepSimXL F (FRQ FR Q) (okJS P) (Kp P) VBOk :=
  stepSimXL (hF.liftQ hL hQ) (hC.liftQ hL hQ) hsmall hFR.liftQ hL hN.liftQ

end
end Host.Ts.Sim.Disp

namespace Host.Ts.Sim
open Host.Ts

/-- **The one-step theorem of the load world, for any reached state.** -/
theorem loadStepSimL (framed : List Nat) (r : List NumV) :
    Disp.StepSimXL LF (LR loadP0 r) (Disp.okJS (loadJSP framed)) (Disp.Kp (loadJSP framed)) LoopVBOk := by
  have hC : FfiCallSim LF (LR loadP0 r) (loadJSP framed).okCall smallLoad := by
    show FfiCallSim LF (LR loadP0 r) (okCallS loadP0) smallLoad
    rw [← okCallS_rest loadP0 r]
    exact loadFfiCallSim _
  exact Disp.stepSimXL (loadFfiSim _) hC (fun _ _ _ _ _ hν hb => smallLoadB_sound hb hν) (loadR_laws _)
    loadFfiLawful (loadNativeFacts framed r)

/-- `loadStepSimL` with the growth of the target's mlx state from `y0`. -/
theorem loadStepSimLQ (framed : List Nat) (r : List NumV) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXL LF (FRQ (LR loadP0 r) fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow y0 y.mlx)
      (Disp.okJS (loadJSP framed)) (Disp.Kp (loadJSP framed)) LoopVBOk := by
  have hC : FfiCallSim LF (LR loadP0 r) (loadJSP framed).okCall smallLoad := by
    show FfiCallSim LF (LR loadP0 r) (okCallS loadP0) smallLoad
    rw [← okCallS_rest loadP0 r]
    exact loadFfiCallSim _
  exact Disp.stepSimXL_Q (loadFfiSim _) hC (fun _ _ _ _ _ hν hb => smallLoadB_sound hb hν) (loadR_laws _)
    loadFfiLawful (loadNativeFacts framed r) (loadTargetPres _ y0)

theorem RelX.withQ {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {Q : F.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelX F FR M ν K s S t C) (hq : Q t.ffi) :
    RelX F (FRQ FR Q) M ν K s S t C := by
  rcases h with h | ⟨v, v', r, env, fs, hc, htc, hs, h⟩
  · exact .inl (h.withQ hq)
  · exact .inr ⟨v, v', r, env, fs, hc, htc, hs, h.withQ hq⟩

/-- **One step of the load world grows the target's mlx state**, whatever the reached state. -/
theorem step_ngrow (framed : List Nat) (r : List NumV) {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St Host.Load.LSt} {S S1 : SSrv} {C C1 : CSrv}
    (hK : Disp.Kp (loadJSP framed) K) (hν : LoopVBOk ν) (hr : RelX LF (LR loadP0 r) M ν K s S t C)
    (hh : isHalt s.ctl = false) (hok : Disp.okJS (loadJSP framed) s S = true)
    (hs : interpS (step LF s).run S = some (s1, S1)) (ht : interpC (step LF t).run C = some (t1, C1)) :
    Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx := by
  obtain ⟨_, t1', C1', ht', _, hr1⟩ :=
    loadStepSimLQ framed r t.ffi.mlx M ν K s S t C s1 S1 hK hν
      (hr.withQ (Q := fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow t.ffi.mlx y.mlx) (Host.Mlx.Ffi.NGrow.refl _))
      hh hok hs
  rw [ht] at ht'
  cases ht'
  exact hr1.q

end Host.Ts.Sim
