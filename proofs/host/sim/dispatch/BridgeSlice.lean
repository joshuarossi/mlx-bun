import host.sim.dispatch.SpreadFramed
import host.sim.dispatch.SafeInt
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Bridge B-slice: `prompt.slice(start, end)` with symbolic bounds

`const chunk = prompt.slice(step.start, step.end)` (`generation/prefill.ts:23`) calls
`Array.prototype.slice` on the framed prompt with the step's bounds. The interpreter's
`relIdx` (`Builtins.lean`) needs literal bounds, so the template's step fails on its symbolic
bounds; the target's bounds are literals (they derive from the literal prompt length). The
bridge covers the one step `.call slice (.obj prompt) [start, end]` (`callNative` →
`arrN .slice`): the template is patched to allocate an empty array, and the new address is
framed with template prefix `[]` and target prefix the target's slice (`sliceL`). The bounds
are any numbers whose target images the target's server concretizes (`relIdx` concretizes a
number reference): with `Srv M ν S C`, a bound `.num (.ref i)` with table entry `e` has the
value `e.eval ν` (`Srv.num`), so the chain supplies the bounds through the valuation. -/

/-- `relIdx` of a number (`Builtins.lean`, `relIdxOf`). -/
abbrev relIdxL (n : Nat) (x : F64) : Nat := relIdxOf n x

theorem relIdx_lit (n : Nat) (x : F64) (d : Nat) : relIdx n (.num (.lit x)) d = Host.Ts.M.pure (relIdxL n x) :=
  relIdx_num n (.lit x) d

/-- A concretization the target's server answers. -/
theorem interpC_numConc_bind {α : Type} {v : NumV} {x : F64} {C : CSrv} (hv : C.val v = some x)
    (f : F64 → Host.Ts.M α) : interpC (Host.Ts.M.bind (numConc v) f).run C = interpC (f x).run C := by
  cases v with
  | lit y =>
    simp only [CSrv.val, Option.some.injEq] at hv
    subst hv
    rfl
  | ref i =>
    show interpC (.conc (.ref i) _) C = _
    rw [interpC_conc, hv]
    rfl

/-- `es.slice(xo, xe)` for literal bounds. -/
def sliceL (es : List Val) (xo xe : F64) : List Val :=
  (es.drop (relIdxL (len es) xo)).take (relIdxL (len es) xe - relIdxL (len es) xo)

/-- A natural number below `2 ^ 53` is exact. -/
theorem ofNat_small {n : Nat} (h : n < 2 ^ 53) : F64.ofNat n = if n = 0 then .zero false else .fin false n 0 := by
  unfold F64.ofNat F64.round
  have hl : Nat.log2 n < 1024 := by
    by_cases h0 : n = 0
    · subst h0; decide
    · have := (Nat.log2_lt h0).2 h; omega
  have hc : (Nat.beq 1 1 && Nat.blt n (Nat.pow 2 F64.b64.prec) && F64.ile F64.b64.unit 0 &&
      F64.ilt (Int.add (Nat.log2 n : Int) 0) F64.b64.top) = true := by
    simp only [Nat.beq_refl, Bool.true_and, Bool.and_eq_true, Nat.blt_eq, ile_eq, ilt_eq, decide_eq_true_eq,
      F64.b64, Nat.pow_eq]
    exact ⟨⟨h, by decide⟩, by show (Nat.log2 n : Int) + 0 < 1024; omega⟩
  rw [hc, Bool.cond_true]
  unfold F64.norm
  by_cases h0 : n = 0
  · subst h0; rfl
  · have hb : Nat.beq n 0 = false := by
      cases hb' : Nat.beq n 0
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true hb') h0
    have hs : Nat.blt n F64.small = true := by simpa [F64.small, Nat.blt_eq] using h
    rw [hb, Bool.cond_false]
    simp only [h0, ↓reduceIte]
    show (bif Nat.blt n F64.small then F64.fin false n 0 else F64.odd false n 0) = _
    rw [hs, Bool.cond_true]

theorem truncInt_ofNat {n : Nat} (h : n < 2 ^ 53) : F64.truncInt (F64.ofNat n) = some (n : Int) := by
  rw [ofNat_small h]
  by_cases h0 : n = 0
  · subst h0; rfl
  · simp only [h0, ↓reduceIte]
    simp [F64.truncInt]

theorem relIdxL_ofNat {n k : Nat} (hk : k ≤ n) (h : k < 2 ^ 53) : relIdxL n (F64.ofNat k) = k := by
  simp only [relIdxL, relIdxOf, truncInt_ofNat h]
  show (bif Nat.ble k n then k else n) = k
  rw [Nat.ble_eq_true_of_le hk, Bool.cond_true]

/-- The target slice of a literal prompt between natural bounds. -/
theorem sliceL_ofNat {π : List Nat} {o e : Nat} (hoe : o ≤ e) (he : e ≤ π.length) (h53 : π.length < 2 ^ 53) :
    sliceL (π.map natV) (F64.ofNat o) (F64.ofNat e) = ((π.drop o).take (e - o)).map natV := by
  have hl : len (π.map natV) = π.length := by rw [bi_len, List.length_map]
  simp only [sliceL, hl, relIdxL_ofNat (Nat.le_trans hoe he) (by omega), relIdxL_ofNat he (by omega),
    List.map_drop, List.map_take]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **B-slice.** `Array.prototype.slice` on a framed array whose bounds have literal target
images: the target slices its own array; the template, patched to allocate an empty array,
stays related under the context framing the new address with prefixes `([], slice)`. -/
theorem bridge_slice (h : RelB F FR W stk M ν K s S t C) {fa a : Nat} {fo o : Obj} {data args : List Val}
    {pre pre' xs : List Val} {xo xe : F64}
    (hc : s.ctl = .call (.obj fa) (.obj a) args) (hfo : s.obj? fa = some fo)
    (hk : fo.kind = .fn (.native (.arr .slice) data))
    (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o) (hko : o.kind = .array (pre ++ xs))
    {vo ve : NumV} (hvo : arg args 0 = .num vo) (hve : arg args 1 = .num ve)
    (hxo : C.val (M.nv vo) = some xo) (hxe : C.val (M.nv ve) = some xe)
    (hn : s.next + margin < Sim.bound) (hp : Present s aArrayProto) (hwn : W s.next = none) :
    interpC (step F t).run C =
        some ((newArray t (sliceL (pre' ++ M.vals xs) xo xe)).2.ret
          (.obj (newArray t (sliceL (pre' ++ M.vals xs) xo xe)).1), C) ∧
      RelB F FR W stk M ν (Ctx.frameAt K s.next ([], sliceL (pre' ++ M.vals xs) xo xe))
        ((newArray s []).2.ret (.obj (newArray s []).1)) S
        ((newArray t (sliceL (pre' ++ M.vals xs) xo xe)).2.ret
          (.obj (newArray t (sliceL (pre' ++ M.vals xs) xo xe)).1)) C := by
  obtain ⟨-, e2, -, -⟩ := h.bi_native hc hfo hk
  obtain ⟨o', ho', xs', hk', rfl⟩ := h.obj?_framed ho hfr (h.w_none (.of_array ho hko) hfr)
  have hxs : xs' = xs := by
    rw [hko] at hk'
    injection hk' with hk'
    exact (List.append_cancel_left hk').symm
  subst hxs
  -- the target's step
  have hstep : step F t = Host.Ts.M.bind (numConc (M.nv vo)) fun x => Host.Ts.M.bind (numConc (M.nv ve)) fun y =>
      Host.Ts.M.pure ((newArray t (sliceL (pre' ++ M.vals xs') x y)).2.ret
        (.obj (newArray t (sliceL (pre' ++ M.vals xs') x y)).1)) := by
    have hva : M.val (.obj a) = .obj (M.a a) := rfl
    rw [e2]
    simp only [callNative, arrN, hva, elemsOf, ho', bi_arg_map, hvo, hve, Map.val, relIdx_num]
    rfl
  refine ⟨by rw [hstep, interpC_numConc_bind hxo, interpC_numConc_bind hxe]; rfl, ?_⟩
  -- the new arrays
  have hn' : s.next < Sim.bound := Nat.lt_of_le_of_lt (Nat.le_add_right _ _) hn
  have hs64 : s.next < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  have hI : M.a aArrayProto = aArrayProto := h.intr _ (by decide)
  have hfo' : FramedObj M [] (sliceL (pre' ++ M.vals xs') xo xe) ⟨.array [], .obj aArrayProto, [], [], true⟩ ⟨.array (sliceL (pre' ++ M.vals xs') xo xe), .obj aArrayProto, [], [], true⟩ :=
    ⟨[], rfl, by simp only [Map.obj, Map.val, hI, Map.props, Map.kind, Map.vals, List.map_nil, List.append_nil]⟩
  have hP : ∀ x, Present s x → Present (s.alloc (.obj ⟨.array [], .obj aArrayProto, [], [], true⟩)).2 x :=
    fun x hx => Present.alloc _ hs64 hx
  obtain ⟨ea, hr⟩ := RelB.allocFramed h _ _ hn' hfo'
    ⟨fun _ hx => by simp at hx, hP _ hp, fun _ hx => by simp at hx, fun _ hx => by simp at hx⟩ hwn
  have hv : Supp.val (Present (s.alloc (.obj ⟨.array [], .obj aArrayProto, [], [], true⟩)).2) S.tab.length
      (.obj (s.alloc (.obj ⟨.array [], .obj aArrayProto, [], [], true⟩)).1) := Present.alloc_next s _ hs64
  have := hr.ret _ hv
  simp only [Map.val] at this
  rw [← ea] at this
  exact this

end
end Host.Ts.Sim.Disp
