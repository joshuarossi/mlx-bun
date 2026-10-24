import host.sim.steps.Builtins
import host.sim.steps.Buf
namespace Host.Ts.Sim

/-! # Bigints of JavaScript-memory pointers

`BigInt(ptr(b))` is the integer `ptrInt (.js b) off = 2^56 + b·2^32 + off`; the target computes it
at its own address `M.a b`. The relation keeps the source's bigints under `M.big`, so these steps
need the map to send a JS pointer integer to the image's (`BigJs M`, for `b < 2^29` and
`off < 2^32`: integers below `2^62`, apart from the fixed bigints below `2^56` and from native
pointer integers, `Rel.bigExt`). The law is a fact about the map alone and every `Ext` keeps it
(`BigJs.ext`). `Map.withJs M` defines `M.big` on the JS pointer band from `M.a`: it obeys the law
(`BigJs.withJs`), agrees with `M` off the band (`Map.withJs_big`), and is `M` where `M` obeys it
(`BigJs.withJs_eq`); identity names obey it (`BigJs.id`).

* `step_num_bigint_js`: `BigInt` of a JS pointer.
* `step_buf_typedCtor_arr`: `new T(xs)` from an array (`typedCtor`'s element branch) whose bigints
  each convert alike on both sides (`toCellBig_js` for JS pointer integers with a small image). -/

/-- **JS pointer integers follow their memory** under the map. -/
def BigJs (M : Map) : Prop :=
  ∀ b off, b < 2 ^ 29 → off < 2 ^ 32 → M.big (ptrInt (.js b) off) = ptrInt (.js (M.a b)) off

theorem BigJs.ext {M M' : Map} {n : Nat} (h : BigJs M) (he : Ext M M' n) : BigJs M' := by
  intro b off hb ho
  rw [he.big, he.a]
  exact h b off hb ho

/-- `2 ^ 56`, `2 ^ 61`, `2 ^ 32` as literals. -/
def jsBase : Nat := 72057594037927936
def jsSpan : Nat := 2305843009213693952
def jsOff : Nat := 4294967296

theorem ptrInt_js (b off : Nat) : ptrInt (.js b) off = ((jsBase + b * jsOff + off : Nat) : Int) := rfl

/-- The JS pointer `(b, off)` whose integer is `i`, with `b < 2^29` and `off < 2^32`. -/
def jsPtrOf : Int → Option (Nat × Nat)
  | .ofNat n => bif Nat.ble jsBase n && Nat.blt n (jsBase + jsSpan) then
      some ((n - jsBase) / jsOff, (n - jsBase) % jsOff) else none
  | .negSucc _ => none

theorem jsPtrOf_some {i : Int} {b off : Nat} (h : jsPtrOf i = some (b, off)) :
    i = ptrInt (.js b) off ∧ b < 2 ^ 29 ∧ off < 2 ^ 32 := by
  cases i with
  | negSucc _ => simp [jsPtrOf] at h
  | ofNat n =>
    simp only [jsPtrOf] at h
    cases hc : (Nat.ble jsBase n && Nat.blt n (jsBase + jsSpan)) with
    | false => rw [hc] at h; cases h
    | true =>
      rw [hc] at h
      simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at hc
      rw [ptrInt_js]
      simp only [jsBase, jsSpan, jsOff] at hc ⊢
      refine ⟨?_, ?_, ?_⟩
      · have := Nat.div_add_mod (n - 72057594037927936) 4294967296
        have e : n = 72057594037927936 + (n - 72057594037927936) / 4294967296 * 4294967296 +
            (n - 72057594037927936) % 4294967296 := by omega
        rw [← e]
        rfl
      · show _ < 536870912
        omega
      · show _ < 4294967296
        omega

theorem jsPtrOf_ptrInt {b off : Nat} (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32) :
    jsPtrOf (ptrInt (.js b) off) = some (b, off) := by
  rw [ptrInt_js]
  have hb' : b < 536870912 := hb
  have ho' : off < 4294967296 := hoff
  show (bif Nat.ble jsBase (jsBase + b * jsOff + off) && Nat.blt (jsBase + b * jsOff + off) (jsBase + jsSpan) then
      some ((jsBase + b * jsOff + off - jsBase) / jsOff, (jsBase + b * jsOff + off - jsBase) % jsOff) else none) = _
  simp only [jsBase, jsSpan, jsOff]
  have h1 : Nat.ble 72057594037927936 (72057594037927936 + b * 4294967296 + off) = true := by
    rw [Nat.ble_eq]; omega
  have h2 : Nat.blt (72057594037927936 + b * 4294967296 + off) (72057594037927936 + 2305843009213693952) = true := by
    rw [Nat.blt_eq]; omega
  rw [h1, h2]
  simp only [Bool.and_self, Bool.cond_true, Option.some.injEq, Prod.mk.injEq]
  constructor <;> omega

/-- Outside the JS pointer band `[2^56, 2^56 + 2^61)` there is no JS pointer integer. -/
theorem jsPtrOf_none {i : Int} (h : i < 72057594037927936 ∨ 72057594037927936 + 2305843009213693952 ≤ i) :
    jsPtrOf i = none := by
  cases i with
  | negSucc _ => rfl
  | ofNat n =>
    show (bif Nat.ble jsBase n && Nat.blt n (jsBase + jsSpan) then _ else none) = none
    simp only [jsBase, jsSpan]
    simp only [Int.ofNat_eq_natCast] at h
    rcases h with h | h
    · have : Nat.ble 72057594037927936 n = false := by
        rw [Bool.eq_false_iff, ne_eq, Nat.ble_eq]; omega
      rw [this]; rfl
    · have : Nat.blt n (72057594037927936 + 2305843009213693952) = false := by
        rw [Bool.eq_false_iff, ne_eq, Nat.blt_eq]; omega
      rw [this, Bool.and_false]; rfl

/-- **The map whose JS pointer integers follow its addresses**: `M.big` replaced on the JS pointer
band by `ptrInt (.js (M.a b)) off`; elsewhere it is `M.big` (`withJs_big`). -/
def Map.withJs (M : Map) : Map :=
  { M with big := fun i => match jsPtrOf i with
    | some (b, off) => ptrInt (.js (M.a b)) off
    | none => M.big i }

theorem Map.withJs_a (M : Map) : M.withJs.a = M.a := rfl

theorem Map.withJs_big_eq (M : Map) (i : Int) : M.withJs.big i = (match jsPtrOf i with
    | some (b, off) => ptrInt (.js (M.a b)) off
    | none => M.big i) := rfl

theorem BigJs.withJs (M : Map) : BigJs M.withJs := fun b off hb hoff => by
  rw [Map.withJs_big_eq, Map.withJs_a, jsPtrOf_ptrInt hb hoff]

theorem Map.withJs_big {M : Map} {i : Int} (h : jsPtrOf i = none) : M.withJs.big i = M.big i := by
  rw [Map.withJs_big_eq, h]

/-- Where the map already obeys the law, `withJs` changes nothing. -/
theorem BigJs.withJs_eq {M : Map} (h : BigJs M) : M.withJs = M := by
  have e : M.withJs.big = M.big := by
    funext i
    rw [Map.withJs_big_eq]
    cases hi : jsPtrOf i with
    | none => rfl
    | some q =>
      obtain ⟨b, off⟩ := q
      obtain ⟨rfl, hb, hoff⟩ := jsPtrOf_some hi
      exact (h b off hb hoff).symm
  cases M with
  | mk a num big region node =>
    simp only [Map.withJs, Map.mk.injEq, true_and, and_true]
    exact e

/-- Identity names obey the law. -/
theorem BigJs.id : BigJs Map.id := fun _ _ _ _ => rfl

namespace BufSim

theorem modInt_js {x : Nat} (h : x < 9223372036854775808) : ((modInt (x : Int) (2 ^ 64) : Nat) : Int) = x :=
  modInt_small (Int.natCast_nonneg x) (by show (x : Int) < 18446744073709551616; omega)

/-- A JS pointer integer with a small image converts alike to a 64-bit element. -/
theorem toCellBig_js {M : Map} (hJ : BigJs M) {b off : Nat} (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32)
    (himg : M.a b < 2 ^ 29) (k : EltK) :
    toCellBig k (M.big (ptrInt (.js b) off)) = (toCellBig k (ptrInt (.js b) off)).map M.cell := by
  rw [hJ b off hb hoff, ptrInt_js, ptrInt_js]
  have hb' : b < 536870912 := hb
  have hi' : M.a b < 536870912 := himg
  have ho' : off < 4294967296 := hoff
  have h1 : jsBase + b * jsOff + off < 9223372036854775808 := by simp only [jsBase, jsOff]; omega
  have h2 : jsBase + M.a b * jsOff + off < 9223372036854775808 := by simp only [jsBase, jsOff]; omega
  have hJ' := hJ b off hb hoff
  rw [ptrInt_js, ptrInt_js] at hJ'
  cases k <;> simp only [toCellBig, Option.map_some, Option.map_none, Map.cell]
  · rw [signed_small (Int.natCast_nonneg _) (by show _ < (9223372036854775808 : Int); omega),
      signed_small (Int.natCast_nonneg _) (by show _ < (9223372036854775808 : Int); omega), hJ']
  · rw [modInt_js h2, modInt_js h1, hJ']

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- `typedCtor`'s element branch: `new T(xs)` from an unframed array whose bigints convert alike. -/
theorem typedCtor_arr_sim {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    (k : EltK) (proto : Nat) {args : List Val} (hargs : Supp.vals (Present s) S.tab.length args)
    (hn : s.next + margin < Sim.bound) (hpl : proto < aFirst)
    (hp14 : Present s aArrayBufferProto) (hpp : Present s proto) (hpT : Present s aTypeErrorProto)
    {b : Nat} {o : Obj} {es : List Val} (harg : arg args 0 = .obj b) (hs : s.obj? b = some o)
    (hkd : o.kind = .array es) (hok : ElemsOK F K s S (arg args 0))
    (hcell : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → toCellBig k (M.big i) = (toCellBig k i).map M.cell) :
    MSim (StepPostB F FR W stk M ν K S C) S C (bufN.typedCtor F s args k proto)
    (bufN.typedCtor F t (M.vals args) k proto) := by
  have hI := h.intr
  have hn1 : s.next < Sim.bound := by have := margin2 hn; omega
  have hs0 := arg_supp hargs 0
  rw [harg] at hs0 hok hcell
  unfold bufN.typedCtor
  simp only [arg_vals, harg, Map.val]
  have hfb := (hok b rfl).1
  have ht := obj?_nofr h hs0 hfb
  rw [hs, Option.map_some] at ht
  obtain ⟨kd, pr, ps, pv, e⟩ := o
  simp only at hkd
  subst hkd
  simp only [hs, ht, Map.obj, Map.kind]
  refine MSim.bind (MSim.withRun (elemsOf_sim h hF hs0 hok) (elemsOf_lawful _ _ _)
    (elemsOf_lawful _ _ _)) ?_
  rintro M0 S0 C0 r r' ⟨⟨hM0, hS0, hC0, hr, hsupp⟩, hrun⟩
  subst M0 S0 C0
  cases r with
  | none => rw [hr]; exact MSim.fail _ _
  | some vs =>
    rw [hr]
    simp only [Option.map_some]
    refine MSim.bind (cellsOf_sim (A := Present s) k vs h.srv (hsupp vs rfl) (hcell vs S hrun)) ?_
    rintro M' S' C' r r' ⟨rfl, g, hsc⟩
    have h' := h.grow hFR g
    have hI' := hI_grow hI g.ext
    cases r with
    | none => exact StepPost_grow g (typeErr_sim h' _ hn1 hI' hpT)
    | some cs =>
      simp only [Option.map_some]
      rw [len_map, ← cellBytes_map]
      exact StepPost_grow g (newTyped_sim h' k proto (cellBytes k cs) (len cs) (margin2 hn) hpl
        hp14 hpp (cellBytes_supp k (hsc cs rfl)))

/-- **`new T(xs)` from an array** (`construct` of the native typed-array constructor with data
`[code, proto]`) whose bigints convert alike. -/
theorem _root_.Host.Ts.Sim.step_buf_typedCtor_arr {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack)
    {a : Nat} {args : List Val} {nt : Val} {o : Obj} {c p : F64} {ci proto : Nat}
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]))
    (hci : F64.toIndex? c = some ci) (hpi : F64.toIndex? p = some proto)
    (hn : s.next + margin < Sim.bound) (hpl : proto < aFirst)
    (hp14 : Present s aArrayBufferProto) (hpp : Present s proto) (hpT : Present s aTypeErrorProto)
    {b : Nat} {ob : Obj} {es : List Val} (harg : arg args 0 = .obj b) (hs : s.obj? b = some ob)
    (hkd : ob.kind = .array es) (hok : ElemsOK F K s S (arg args 0))
    (hcell : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → toCellBig (eltOfCode ci) (M.big i) = (toCellBig (eltOfCode ci) i).map M.cell) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [step_construct_native hc ho hk, step_construct_native_t h hc ho hk]
  have hd : M.vals [Val.num (.lit c), .num (.lit p)] = [.num (.lit c), .num (.lit p)] := rfl
  rw [hd]
  simp only [constructNative, bufN, hci, hpi]
  exact typedCtor_arr_sim h hFR hF (eltOfCode ci) proto (construct_supp h hc) hn hpl hp14 hpp hpT harg hs hkd
    hok hcell

end
end BufSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
  {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

/-- **`BigInt(p)` of a JS pointer** `p = ptr(b) + off`: the image of the source's integer is the
target's (`BigJs`). -/
theorem step_num_bigint_js (h : RelB F FR W stk M ν K s S t C) (hJ : BigJs M)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.num .bigint) data)) {b off : Nat} (hx : arg args 0 = .ptr (.js b) off)
    (hb : b < 2 ^ 29) (hoff : off < 2 ^ 32) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, numN, bi_arg_map, hx]
  have := bi_ret h (.big (ptrInt (.js b) off)) trivial
  rw [show M.val (.big (ptrInt (.js b) off)) = .big (M.big (ptrInt (.js b) off)) from rfl, hJ b off hb hoff] at this
  exact this

end
end Host.Ts.Sim
