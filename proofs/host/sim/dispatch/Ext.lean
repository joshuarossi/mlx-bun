import host.sim.dispatch.Ok
import host.sim.steps.Ext
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Further accepted steps (`steps/Ext.lean`)

`moreB P s S` accepts, beyond `okJS`: a `yield*` start and an async `yield*`'s inner result and iterator under frames
(`LookupNoW` decided by `lookupNoWB` in place of `noWideB`), `Math.max`, `Function.prototype.bind`, an iterator's
`[Symbol.iterator]` and value-mode `next()` over an array, `Set.prototype.values`/`has` on an
unframed `Set`, `new Set(xs)` from an array whose elements compare alike (`svzB`), and
`new Promise(executor)`. `dispatchMore` is its one-step theorem; `okJSK` includes it. -/

section
variable {F : Ffi} (P : JSP F)

/-- An unframed value-mode iterator over an array. -/
def iterNextB (s : St F.S) (n : Nat) (this : Val) : Bool :=
  match this with
  | .obj a => frB P a && match s.obj? a with
    | some io => match io.kind with
      | .iter src _ 0 => elemsB P s n src
      | _ => false
    | none => false
  | _ => false

/-- An unframed `Set`. -/
def setThisB (s : St F.S) (this : Val) : Bool :=
  match this with
  | .obj a => frB P a && match s.obj? a with
    | some o => match o.kind with
      | .set _ => true
      | _ => false
    | none => false
  | _ => false

/-- An unframed `Set` whose elements compare with `k` alike. -/
def setHasB (s : St F.S) (this k : Val) : Bool :=
  match this with
  | .obj a => frB P a && match s.obj? a with
    | some o => match o.kind with
      | .set es => allB (fun x => svzB P x k) es
      | _ => false
    | none => false
  | _ => false

/-- `new Set(xs)` from an array whose elements compare alike with each other. -/
def setCtorB (s : St F.S) (S : SSrv) (args : List Val) : Bool :=
  match arg args 0 with
  | .obj b => elemsB P s S.tab.length (.obj b) && match interpS (elemsOf F s (.obj b)).run S with
    | some (some vs, _) => allB (fun x => allB (fun y => svzB P y x) vs) vs
    | _ => true
  | _ => false

/-- A value returning to an async `yield*` frame under frames. -/
def extRetB (s : St F.S) : Bool :=
  match s.ctl, s.stack with
  | .ret v, .k (.ystarAResult _ _) :: _ =>
    presB s aObjectProto && presB s aFunctionProto && doneB P s v && lookupNoWB P s v
  | .ret v, .k .ystarAIt :: _ => lookupNoWB P s v
  | .ret v, .k (.yield true) :: _ => presB s aTypeErrorProto && presB s aArrayIterProto && lookupNoWB P s v
  | _, _ => false

/-- A call of a builtin `moreB` adds. -/
def extCallB (s : St F.S) (S : SSrv) : Bool :=
  match s.ctl with
  | .call (.obj fa) this args => match s.obj? fa with
    | some o => match o.kind with
      | .fn (.native (.math .max) _) => true
      | .fn (.native (.fn .bind) _) => presB s aFunctionProto
      | .fn (.native (.iter .self) _) => true
      | .fn (.native (.iter .next) _) => presB s aObjectProto && iterNextB P s S.tab.length this
      | .fn (.native (.set .values) _) => presB s aArrayProto && presB s aArrayIterProto && setThisB P s this
      | .fn (.native (.set .has) _) => setHasB P s this (arg args 0)
      | _ => false
    | none => false
  | _ => false

/-- A construction `moreB` adds. -/
def extConsB (s : St F.S) (S : SSrv) : Bool :=
  match s.ctl with
  | .construct (.obj a) args _ => match s.obj? a with
    | some o => match o.kind with
      | .fn (.native (.set .ctor) _) => presB s aSetProto && setCtorB P s S args
      | .fn (.native (.ctl .promiseCtor) _) => presB s aPromiseProto && presB s aFunctionProto
      | _ => false
    | none => false
  | _ => false

/-- **The further accepted steps.** -/
def moreB (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && (extRetB P s || extCallB P s S || extConsB P s S)

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

theorem iterNextB_spec {s : St F.S} {n : Nat} {this : Val} (h : iterNextB P s n this = true) :
    ∃ a io src i, this = .obj a ∧ s.obj? a = some io ∧ io.kind = .iter src i 0 ∧ frB P a = true ∧
      elemsB P s n src = true := by
  unfold iterNextB at h
  split at h
  · rename_i a
    simp only [Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    split at h2
    · rename_i io hio
      split at h2
      · rename_i src i hk
        exact ⟨a, io, src, i, rfl, hio, hk, h1, h2⟩
      · cases h2
    · cases h2
  · cases h

theorem setThisB_spec {s : St F.S} {this : Val} (h : setThisB P s this = true) :
    ∃ a so es, this = .obj a ∧ s.obj? a = some so ∧ so.kind = .set es ∧ frB P a = true := by
  unfold setThisB at h
  split at h
  · rename_i a
    simp only [Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    split at h2
    · rename_i so hso
      split at h2
      · rename_i es hk
        exact ⟨a, so, es, rfl, hso, hk, h1⟩
      · cases h2
    · cases h2
  · cases h

theorem setHasB_spec {s : St F.S} {this k : Val} (h : setHasB P s this k = true) :
    ∃ a so es, this = .obj a ∧ s.obj? a = some so ∧ so.kind = .set es ∧ frB P a = true ∧
      allB (fun x => svzB P x k) es = true := by
  unfold setHasB at h
  split at h
  · rename_i a
    simp only [Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    split at h2
    · rename_i so hso
      split at h2
      · rename_i es hk
        exact ⟨a, so, es, rfl, hso, hk, h1, h2⟩
      · cases h2
    · cases h2
  · cases h

theorem setCtorB_spec {s : St F.S} {S : SSrv} {args : List Val} (h : setCtorB P s S args = true) :
    ∃ b, arg args 0 = .obj b ∧ elemsB P s S.tab.length (arg args 0) = true ∧
      ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
        allB (fun x => allB (fun y => svzB P y x) vs) vs = true := by
  unfold setCtorB at h
  split at h
  · rename_i b hb
    simp only [Bool.and_eq_true] at h
    refine ⟨b, hb, by rw [hb]; exact h.1, fun vs S1 hr => ?_⟩
    have h2 := h.2
    rw [hb] at hr
    rw [hr] at h2
    exact h2
  · cases h

/-- **The one-step theorem of `moreB`.** -/
theorem dispatchMore {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall0 okBack0) (hFR : FRLaws FR) (hK : Kp P K) (hW : Wp P W)
    (h : RelB F FR W stk M ν K s S t C) (hok : moreB P s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [moreB, Bool.and_eq_true, Bool.or_eq_true] at hok
  obtain ⟨hnx, (hr | hca) | hco⟩ := hok
  · have hn := next_ok hnx
    unfold extRetB at hr
    split at hr
    · rename_i v it nx fs hc hs
      simp only [Bool.and_eq_true] at hr
      obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hr
      obtain ⟨a, o, dv, w, e, rfl, ho, hk, hd, hb⟩ := hK.done h3
      exact MSim.toX (step_ret_ystarAResultW h hF hFR h1 h2 hc hs ho hk hd hb hn (hK.lookupNoW hW h4))
    · rename_i v fs hc hs
      exact MSim.toX (step_ret_ystarAItW h hF hc hs (hK.lookupNoW hW hr))
    · rename_i v fs hc hs
      simp only [Bool.and_eq_true] at hr
      obtain ⟨⟨h1, h2⟩, h3⟩ := hr
      exact MSim.toX (step_ret_yield_delegateW h hF h1 h2 hc hs hn (hK.lookupNoW hW h3)
        (hloc.imp id fun hl => localB_tail hl hs rfl))
    · cases hr
  · have hn := next_ok hnx
    unfold extCallB at hca
    split at hca
    · rename_i fa this args hc
      split at hca
      · rename_i o ho
        split at hca
        · rename_i data hk
          exact MSim.toX (step_math_max h hFR hc ho hk)
        · rename_i data hk
          exact MSim.toX (step_fn_bind h hc ho hk hn hca)
        · rename_i data hk
          exact MSim.toX (step_iter_self h hc ho hk)
        · rename_i data hk
          simp only [Bool.and_eq_true] at hca
          obtain ⟨a, io, src, i, hthis, hio, hik, hfr, hel⟩ := iterNextB_spec hca.2
          exact MSim.toX (step_iter_next h hF hc ho hk hn hca.1 hthis hio hik (hK.fr_none hfr) (hK.elems hel))
        · rename_i data hk
          simp only [Bool.and_eq_true] at hca
          obtain ⟨a, so, es, hthis, hso, hsk, hfr⟩ := setThisB_spec hca.2
          exact MSim.toX (step_set_values h hc ho hk hn hca.1.1 hca.1.2 hthis hso hsk (hK.fr_none hfr))
        · rename_i data hk
          obtain ⟨a, so, es, hthis, hso, hsk, hfr, hall⟩ := setHasB_spec hca
          exact MSim.toX (step_set_has h hFR hc ho hk hthis hso hsk (hK.fr_none hfr)
            fun x hx => hK.svz (allB_sound hall x hx))
        · cases hca
      · cases hca
    · cases hca
  · have hn := next_ok hnx
    unfold extConsB at hco
    split at hco
    · rename_i a args nt hc
      split at hco
      · rename_i o ho
        split at hco
        · rename_i data hk
          simp only [Bool.and_eq_true] at hco
          obtain ⟨b, harg, hel, hsv⟩ := setCtorB_spec hco.2
          exact MSim.toX (step_set_ctor h hFR hF hc ho hk hn hco.1 harg (hK.elems hel)
            fun vs S1 hr x hx y hy => hK.svz (allB_sound (allB_sound (hsv vs S1 hr) x hx) y hy))
        · rename_i data hk
          simp only [Bool.and_eq_true] at hco
          exact MSim.toX (step_construct_promise h hc ho hk hn hco.1 hco.2)
        · cases hco
      · cases hco
    · cases hco

end
end Host.Ts.Sim.Disp
