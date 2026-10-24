import host.sim.dispatch.OkBack
import host.sim.steps.BigJs
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # The acceptance function with JavaScript pointer integers

`okJSJ P okBack D0` is `okJSK P okBack` and two steps that need the map law `BigJs`
(`steps/BigJs.lean`):

* `BigInt(ptr(b) + off)` with `b < 2^29`, `off < 2^32` (`bigJsCallB`, `step_num_bigint_js`);
* `new T(xs)` from an unframed array whose bigints each convert as before (`convB`) or are JS
  pointer integers of present addresses (`jsElemB`, `step_buf_typedCtor_arr`). Their images must
  be small: the decider checks `s.next + D0 < 2^29` and the run's counter offset is at most `D0`
  (`KpJ P D0`), so every present address has an image below `2^29` (`RelB.bound`, `RelB.offset`).

`dispatchJ` is the one-step theorem with `BigJs M` as a hypothesis. Along a run the law is carried
by the native relation `FRJ FR` (every `Ext` keeps it, `BigJs.ext`): `stepSimXLBJ` is the checked
runs' one-step theorem for it, from the interfaces of `FR`. Everything `okJSK` accepts `okJSJ`
accepts (`okJSK_J`). -/

/-- The native relation with the law `BigJs` of the map. -/
def FRJ {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) : Map → Nat → F.S → F.S → Prop :=
  fun M n x y => FR M n x y ∧ BigJs M

/-- The context predicate with a bound on the counter offset. -/
def KpJ {F : Ffi} (P : JSP F) (D0 : Nat) (K : Ctx) : Prop := Kp P K ∧ K.D ≤ D0

/-- `2 ^ 29` as a literal. -/
def lim29 : Nat := 536870912

section
variable {F : Ffi} (P : JSP F) (okBack : F.S → Arg → Bool) (D0 : Nat)

/-- `BigInt` of a JS pointer (`step_num_bigint_js`). -/
def bigJsCallB (s : St F.S) : Bool :=
  match s.ctl with
  | .call (.obj fa) _ args => match s.obj? fa with
    | some o => match o.kind with
      | .fn (.native (.num .bigint) _) => match arg args 0 with
        | .ptr (.js b) off => Nat.blt b lim29 && Nat.blt off jsOff
        | _ => false
      | _ => false
    | none => false
  | _ => false

/-- A stored element that is a JS pointer integer of a present address with a small image. -/
def jsElemB (s : St F.S) : Val → Bool
  | .big i => match jsPtrOf i with
    | some (b, _) => presB s b && Nat.blt (s.next + D0) lim29
    | none => false
  | _ => true

/-- The elements of `new T(xs)`: each converts as before or is a JS pointer integer. -/
def ctorElemsJB (s : St F.S) (S : SSrv) (k : EltK) (v : Val) : Bool :=
  match interpS (elemsOf F s v).run S with
  | some (some vs, _) => allB (fun x => convB P s k x || jsElemB D0 s x) vs
  | _ => true

/-- `new T(xs)` from an array (`step_buf_typedCtor_arr`). -/
def typedJsB (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && match s.ctl with
  | .construct (.obj a) args _ => match s.obj? a with
    | some o => match o.kind with
      | .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]) => match F64.toIndex? c, F64.toIndex? p with
        | some ci, some proto => Nat.blt proto aFirst && presB s aArrayBufferProto && presB s proto &&
            presB s aTypeErrorProto && elemsB P s S.tab.length (arg args 0) &&
            (match arg args 0 with
              | .obj b => match s.obj? b with
                | some ob => match ob.kind with
                  | .array _ => ctorElemsJB P D0 s S (eltOfCode ci) (arg args 0)
                  | _ => false
                | none => false
              | _ => false)
        | _, _ => false
      | _ => false
    | none => false
  | _ => false

/-- **The acceptance function with JS pointer integers.** -/
def okJSJ (s : St F.S) (S : SSrv) : Bool :=
  okJSK P okBack s S || bigJsCallB s || typedJsB P D0 s S

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F} {okBack : F.S → Arg → Bool}
  {D0 : Nat}

/-- **Agreement**: every state `okJSK` accepts `okJSJ` accepts. -/
theorem okJSK_J (h : okJSK P okBack s S = true) : okJSJ P okBack D0 s S = true := by
  simp [okJSJ, h]

/-- **Agreement**: every state `okJS` accepts `okJSJ` accepts. -/
theorem okJS_J (h : okJS P s S = true) : okJSJ P okBack D0 s S = true := okJSK_J (okJS_K h)

theorem bigJsCallB_spec {s : St F.S} (h : bigJsCallB s = true) :
    ∃ fa this args o data b off, s.ctl = .call (.obj fa) this args ∧ s.obj? fa = some o ∧
      o.kind = .fn (.native (.num .bigint) data) ∧ arg args 0 = .ptr (.js b) off ∧ b < 2 ^ 29 ∧
      off < 2 ^ 32 := by
  unfold bigJsCallB at h
  split at h
  · rename_i fa this args hc
    split at h
    · rename_i o ho
      split at h
      · rename_i data hk
        split at h
        · rename_i b off hx
          simp only [Bool.and_eq_true, Nat.blt_eq] at h
          exact ⟨fa, this, args, o, data, b, off, hc, ho, hk, hx, h.1, h.2⟩
        · cases h
      · cases h
    · cases h
  · cases h

theorem typedJsB_spec {s : St F.S} {S : SSrv} (h : typedJsB P D0 s S = true) :
    ∃ a args nt o c p ci proto b ob es, s.ctl = .construct (.obj a) args nt ∧ s.obj? a = some o ∧
      o.kind = .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]) ∧ F64.toIndex? c = some ci ∧
      F64.toIndex? p = some proto ∧ Nat.blt s.next nextMax = true ∧ proto < aFirst ∧
      Present s aArrayBufferProto ∧ Present s proto ∧ Present s aTypeErrorProto ∧
      elemsB P s S.tab.length (arg args 0) = true ∧ arg args 0 = .obj b ∧ s.obj? b = some ob ∧
      ob.kind = .array es ∧ ctorElemsJB P D0 s S (eltOfCode ci) (arg args 0) = true := by
  unfold typedJsB at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hn, h⟩ := h
  split at h
  · rename_i a args nt hc
    split at h
    · rename_i o ho
      split at h
      · rename_i c p hk
        split at h
        · rename_i ci proto hci hpi
          simp only [Bool.and_eq_true, Nat.blt_eq] at h
          obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
          split at h6
          · rename_i b hb
            split at h6
            · rename_i ob hob
              split at h6
              · rename_i es hes
                exact ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi, hn, h1, h2, h3, h4, h5,
                  hb, hob, hes, h6⟩
              · cases h6
            · cases h6
          · cases h6
        · cases h
      · cases h
    · cases h
  · cases h

/-- The cell of a stored element `ctorElemsJB` accepts converts alike. -/
theorem ctorElemsJB_cell (hK : Kp P K) (hD : K.D ≤ D0) (hN : NativeFacts F FR P) (hJ : BigJs M)
    (h : RelB F FR W stk M ν K s S t C) {k : EltK} {v : Val} (hv : ctorElemsJB P D0 s S k v = true) :
    ∀ vs S1, interpS (elemsOf F s v).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → toCellBig k (M.big i) = (toCellBig k i).map M.cell := by
  intro vs S1 hr i hi
  simp only [ctorElemsJB, hr] at hv
  have hx := allB_sound hv _ hi
  simp only [Bool.or_eq_true] at hx
  rcases hx with hx | hx
  · exact toCellBig_map h (hK.conv hx i rfl) (convB_range hK hN h hx i rfl)
  · simp only [jsElemB] at hx
    cases hp : jsPtrOf i with
    | none => rw [hp] at hx; cases hx
    | some q =>
      obtain ⟨b, off⟩ := q
      rw [hp] at hx
      simp only [Bool.and_eq_true, Nat.blt_eq] at hx
      obtain ⟨rfl, hb, hoff⟩ := jsPtrOf_some hp
      have himg : M.a b < 2 ^ 29 := by
        have h1 := h.bound b (presB_sound hx.1)
        have h2 := h.offset
        have h3 : s.next + D0 < 536870912 := hx.2
        show M.a b < 536870912
        omega
      exact toCellBig_js hJ hb hoff himg k

/-- **The one-step theorem of `okJSJ`**, under the law `BigJs M` and a counter offset at most `D0`. -/
theorem dispatchJ {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hF : FfiSim F FR okCall0 okBack0)
    (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hK : Kp P K) (hD : K.D ≤ D0)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M)
    (hh : isHalt s.ctl = false) (hok : okJSJ P okBack D0 s S = true) (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  simp only [okJSJ, Bool.or_eq_true] at hok
  rcases hok with (hok | hok) | hok
  · exact dispatchK hF hB hC hsm hFR hL hN hK hW h hh hok hloc
  · obtain ⟨fa, this, args, o, data, b, off, hc, ho, hk, hx, hb, hoff⟩ := bigJsCallB_spec hok
    exact MSim.toX (step_num_bigint_js h hJ hc ho hk hx hb hoff)
  · obtain ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi, hn, h1, h2, h3, h4, h5, hb, hob,
      hes, h6⟩ := typedJsB_spec hok
    exact MSim.toX (step_buf_typedCtor_arr h hFR hF hc ho hk hci hpi (next_ok hn) h1 h2 h3 h4 hb hob hes
      (hK.elems h5) (ctorElemsJB_cell hK hD hN hJ h h6))

/-! ## Along checked runs: the law in the native relation -/

theorem _root_.Host.Ts.Sim.RelB.ofJ (h : RelB F (FRJ FR) W stk M ν K s S t C) : RelB F FR W stk M ν K s S t C :=
  { h with ffi := h.ffi.1 }

theorem _root_.Host.Ts.Sim.RelB.toJ (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M) : RelB F (FRJ FR) W stk M ν K s S t C :=
  { h with ffi := ⟨h.ffi, hJ⟩ }

theorem _root_.Host.Ts.Sim.RelXB.toJ (h : RelXB F FR W stk M ν K s S t C) (hJ : BigJs M) : RelXB F (FRJ FR) W stk M ν K s S t C := by
  rcases h with h | ⟨v, v', r, env, fs, hc, htc, hs, h⟩
  · exact .inl (h.toJ hJ)
  · exact .inr ⟨v, v', r, env, fs, hc, htc, hs, h.toJ hJ⟩

/-- `stepSimXLBK` for `okJSJ`: the law rides in the native relation `FRJ FR`, the offset bound in
`KpJ P D0`. -/
theorem stepSimXLBJ {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXLB F (FRJ FR) (okJSJ P okBack D0) (KpJ P D0) W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hloc hok hs
  rcases hr with hr | hd
  · obtain ⟨M', t1, C1, ht, hg, hr1⟩ :=
      MSim.run (dispatchJ hF hB hC (hsmall ν · · · · hν) hFR hL hN hK.1 hK.2 hW hr.ofJ hr.ffi.2 hh hok hloc)
        s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, RelXB.toJ hr1 (hr.ffi.2.ext hg.ext)⟩
  · have e := RelDB.step_eq hd
    obtain ⟨v, v', r, env, fs, hc, _, hstk, hr⟩ := hd
    rw [e]
    obtain ⟨M', t1, C1, ht, hg, hr1⟩ := MSim.run (step_ret_block hr hc hstk) s1 S1 hs
    exact ⟨M', t1, C1, ht, hg.ext, .inl hr1⟩

/-- `stepSimXVBK` for `okJSJ`. -/
theorem stepSimXVBJ {W : Nat → Option WFrame} {stk : List Frame} {okCall0 : F.S → Name → List Arg → Bool}
    {okBack0 : F.S → Arg → Bool} {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) (hW : Wp P W) :
    StepSimXVB F (FRJ FR) (okJSJ P okBack D0) (KpJ P D0) W stk VBOk :=
  (stepSimXLBJ hF hB hC hsmall hFR hL hN hW).xv

/-- `stepSimXLK` for `okJSJ`. -/
theorem stepSimXLJ {okCall0 : F.S → Name → List Arg → Bool} {okBack0 : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack0) (hB : FfiBackSim F FR okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : NativeFacts F FR P) :
    StepSimXL F (FRJ FR) (okJSJ P okBack D0) (KpJ P D0) VBOk :=
  (stepSimXLBJ (stk := []) hF hB hC hsmall hFR hL hN Wp.free).nil

end

/-- No continuation accepted: the trivial `FfiBackSim` (`okJSJ P (fun _ _ => false) D0` adds the
JS pointer steps to `okJS` alone). -/
theorem FfiBackSim.none {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} : FfiBackSim F FR (fun _ _ => false) :=
  ⟨fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)⟩

end Host.Ts.Sim.Disp
