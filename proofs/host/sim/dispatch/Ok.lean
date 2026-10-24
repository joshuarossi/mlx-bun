import host.sim.dispatch.Ev
import host.sim.dispatch.Ex
import host.sim.dispatch.Ret
import host.sim.dispatch.Abr
import host.sim.dispatch.Bind
import host.sim.dispatch.Call
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # The acceptance function and the one-step theorem

`okJS P s S` decides, for a source state, which step kind it is (mirroring
`step`: the control constructor, the expression or statement, the top frame, the
callee's kind or builtin) and whether that kind has a step lemma whose source-side
side conditions hold; it also bounds the heap counter (`s.next + margin < bound`).

`stepSimXVW` is the one-step obligation for `okJS P` under frames `W` the parameters declare
(`Wp`), `stepSimXV` its frame-free case (`Wp.free`), for valuations satisfying a
predicate `VBOk` (`StepSimXV`: `StepSimX` with `VBOk ν`), given the native
interface (`FfiSim` for buffer reads, `FfiCallSim` with smallness premise `small`
for calls, `FRLaws`, `FfiLawful`), the soundness of the smallness decider `P.smallB`
under `VBOk`, and the map facts `NativeFacts`. `runOk_simXV` is `runOk_simX` for it. -/

section
variable {F : Ffi}

def okCtl (P : JSP F) (s : St F.S) (S : SSrv) : Bool :=
  match s.ctl with
  | .ev e env => okEv P s e env
  | .ex st _ => okEx s st
  | .ret v => okRet P s S.tab.length v s.stack
  | .abr _ => okAbr P s S.tab.length s.stack
  | .call f this args => okCallB P s S S.tab.length f this args
  | .construct f args nt => okConsB P s S S.tab.length f args nt
  | .bind p v env mode _ => okBind P s S.tab.length p v env mode
  | .short => true
  | .halt _ => true

/-- The acceptance function of the checked runs. -/
def okJS (P : JSP F) (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && okCtl P s S

variable {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

theorem dispatch {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hF : FfiSim F FR okCall0 okBack)
    (hC : FfiCallSim F FR P.okCall small) (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hW : Wp P W)
    (h : RelB F FR W stk M ν K s S t C)
    (hh : isHalt s.ctl = false) (hok : okJS P s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJS, Bool.and_eq_true] at hok
  have hn := next_ok hok.1
  have hk := hok.2
  unfold okCtl at hk
  cases hc : s.ctl with
  | ev e env => rw [hc] at hk; exact simEv hF hK hW h hc hn hk
  | ex st env => rw [hc] at hk; exact simEx h hc hn hk
  | ret v => rw [hc] at hk; exact simRet hF hFR hK hW hN h hc hn hk hloc
  | abr a => rw [hc] at hk; exact simAbr hF hK hW h hc hn hk hloc
  | call f this args => rw [hc] at hk; exact simCall hF hC hsm hFR hL hK hW hN h hc hn hk
  | construct f args nt => rw [hc] at hk; exact simCons hF hFR hK hW hN h hc hn hk
  | bind p v env mode kind => rw [hc] at hk; exact simBind hF hK hW h hc hn hk
  | short => exact MSim.toX (step_short h hc)
  | halt c => rw [hc] at hh; exact absurd hh (by simp [isHalt])

end

/-- `StepSimX` for the valuations satisfying `VBOk`. -/
def StepSimXV (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → VBOk ν → RelX F FR M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) → ok s1 S1 = true →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelX F FR M' ν K s1 S1 t1 C1

/-- `StepSimXV` under the frames `W` and the target-only stack base `stk` (`RelXB`), for the
steps reading no frame below the source's (`localB`, or no base). -/
def StepSimXVB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (W : Nat → Option WFrame) (stk : List Frame) (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → VBOk ν → RelXB F FR W stk M ν K s S t C →
    isHalt s.ctl = false → (stk = [] ∨ localB s = true) → ok s S = true → interpS (step F s).run S = some (s1, S1) →
    ok s1 S1 = true → ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelXB F FR W stk M' ν K s1 S1 t1 C1

/-- `StepSimXV` under the frames `W` (`RelXF`); `StepSimXV` is its frame-free case. -/
def StepSimXVW (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (W : Nat → Option WFrame) (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → VBOk ν → RelXF F FR W M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) → ok s1 S1 = true →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelXF F FR W M' ν K s1 S1 t1 C1

/-- Without a stack base `StepSimXVB` is `StepSimXVW`. -/
theorem StepSimXVB.nil {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
    {Kp : Ctx → Prop} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} (h : StepSimXVB F FR ok Kp W [] VBOk) :
    StepSimXVW F FR ok Kp W VBOk :=
  fun M ν K s S t C s1 S1 hK hν hr hh hok hs hk => h M ν K s S t C s1 S1 hK hν hr hh (.inl rfl) hok hs hk

/-- The frame-free case is `StepSimXV` (definitionally). -/
theorem StepSimXVW.free {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
    {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop} (h : StepSimXVW F FR ok Kp noFrames VBOk) :
    StepSimXV F FR ok Kp VBOk := h

/-- `runOk_simX` for `StepSimXVB`: a checked run whose accepted states read no frame below their
own (`hloc`). -/
theorem runOk_simXVB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (W : Nat → Option WFrame) (stk : List Frame) (VBOk : (Nat → F64) → Prop)
    (hsim : StepSimXVB F FR ok Kp W stk VBOk) (hloc : ∀ s S, ok s S = true → stk = [] ∨ localB s = true)
    (ν : Nat → F64) (K : Ctx) (hK : Kp K) (hν : VBOk ν) :
    ∀ n M s S t C s' S', RelXB F FR W stk M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelXB F FR W stk M' ν K s' S' t' C' := by
  intro n
  induction n with
  | zero =>
    intro M s S t C s' S' hr _ h
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨M, t, C, rfl, Ext.refl _ _, hr⟩
  | succ n ih =>
    intro M s S t C s' S' hr hok h
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim M ν K s S t C s1 S1 hK hν hr hh (hloc s S hok) hok hs hk
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_true]

/-- `runOk_simX` for `StepSimXVW`. -/
theorem runOk_simXVW (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (W : Nat → Option WFrame) (VBOk : (Nat → F64) → Prop) (hsim : StepSimXVW F FR ok Kp W VBOk)
    (ν : Nat → F64) (K : Ctx) (hK : Kp K) (hν : VBOk ν) :
    ∀ n M s S t C s' S', RelXF F FR W M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelXF F FR W M' ν K s' S' t' C' :=
  runOk_simXVB F FR ok Kp W [] VBOk (fun M ν K s S t C s1 S1 hK hν hr hh _ hok hs hk =>
    hsim M ν K s S t C s1 S1 hK hν hr hh hok hs hk) (fun _ _ _ => .inl rfl) ν K hK hν

/-- `runOk_simX` for `StepSimXV`. -/
theorem runOk_simXV (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (VBOk : (Nat → F64) → Prop) (hsim : StepSimXV F FR ok Kp VBOk) (ν : Nat → F64) (K : Ctx)
    (hK : Kp K) (hν : VBOk ν) :
    ∀ n M s S t C s' S', RelX F FR M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelX F FR M' ν K s' S' t' C' := by
  intro n
  induction n with
  | zero =>
    intro M s S t C s' S' hr _ h
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨M, t, C, rfl, Ext.refl _ _, hr⟩
  | succ n ih =>
    intro M s S t C s' S' hr hok h
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim M ν K s S t C s1 S1 hK hν hr hh hok hs hk
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_true]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {P : JSP F}

/-- **The one-step simulation of the checked runs under the frames `W`** the parameters declare
and a target-only stack base `stk`, for the steps reading no frame below the source's. -/
theorem stepSimXVB {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXVB F FR (okJS P) (Kp P) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs _
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatch hF hC (hsmall ν · · · · hν) hFR hL hN hK hW hr hh hok hloc) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, hr1⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

/-- **The one-step simulation of the checked runs under the frames `W`** the parameters declare. -/
theorem stepSimXVW {W : Nat → Option WFrame} {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXVW F FR (okJS P) (Kp P) W VBOk :=
  (stepSimXVB (stk := []) hF hC hsmall hFR hL hN hW).nil

/-- The one-step simulation of the checked runs (`stepSimXVW` without frames). -/
theorem stepSimXV {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) :
    StepSimXV F FR (okJS P) (Kp P) VBOk :=
  (stepSimXVW hF hC hsmall hFR hL hN Wp.free).free

end
end Host.Ts.Sim.Disp
