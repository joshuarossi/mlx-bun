import host.sim.dispatch.DecideBuiltins
import host.sim.dispatch.FfiAdapt
import host.sim.dispatch.DecideFn
import host.sim.dispatch.Ret1
import host.sim.dispatch.BuiltinAdapt
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Dispatch of `.call f this args` and `.construct f args nt`

Closures, classes, bound functions, non-callable objects and primitives are
covered completely. Builtins covered: `Array.prototype.push` (a framed receiver
only directly below a statement list: `step_arr_push_framed`), `slice`, `at`,
`includes`, `Array.isArray`, `Object.entries/hasOwn`, `Map.prototype.get`,
`Math.ceil/floor/min`, `Number`, `Number.isSafeInteger`, `BigInt` (not of JS-memory
pointers), `Buffer.from`, DataView `get/set` of `u32/i32/f32/u64` (get) and
`f32/u32/i32/u64` (set), `FinalizationRegistry.prototype.register/unregister`, `performance.now()`,
generator and async-generator methods, promise and `AsyncLocalStorage` builtins,
and `bun:ffi` `ptr`, `read.*`, `toArrayBuffer` and `dlopen` symbols. Constructions
of builtins: typed arrays only. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

def blockTopB : List Frame → Bool
  | .s (.block _ _) :: _ => true
  | _ => false

def extB {S' : Type} (s : St S') (a : Nat) : Bool :=
  match s.obj? a with
  | some ao => ao.extensible
  | none => true

/-- A push onto a framed array needs a statement-list frame below (which discards the length). -/
def pushB (P : JSP F) (s : St F.S) (this : Val) : Bool :=
  match this with
  | .obj a => frB P a || (blockTopB s.stack && extB s a)
  | _ => true

/-- A generator about to start its body: `StartOK`. -/
def genStartB (P : JSP F) (s : St F.S) (this : Val) : Bool :=
  match this with
  | .obj g => match genOf s g with
    | some (.start body env, _) => startB P body env
    | _ => true
  | _ => true

theorem Kp.genStart (hK : Kp P K) {s : St F.S} {this : Val} (h : genStartB P s this = true) (b : Bool) :
    ∀ g body env, this = .obj g → genOf s g = some (.start body env, b) → StartOK K body env := by
  rintro g body env rfl hg
  simp only [genStartB, hg] at h
  exact hK.start h

/-- A `dlopen` symbol call. -/
def symCallB (P : JSP F) (s : St F.S) (S : SSrv) (n : Nat) (data args : List Val) : Bool :=
  match data with
  | [.str name, .obj ta, .str _] => match s.obj? ta with
    | some oa => match oa.kind with
      | .array tys => frB P ta && allB (argBufB P s n) args && boolsPB P tys args && symOKB P s S name tys args
      | _ => false
    | none => false
  | _ => false

theorem symCallB_spec {s : St F.S} {S : SSrv} {n : Nat} {data args : List Val}
    (h : symCallB P s S n data args = true) :
    ∃ name rt ta oa tys, data = [.str name, .obj ta, .str rt] ∧ s.obj? ta = some oa ∧ oa.kind = .array tys ∧
      frB P ta = true ∧ allB (argBufB P s n) args = true ∧ boolsPB P tys args = true ∧
      symOKB P s S name tys args = true := by
  unfold symCallB at h
  split at h
  · rename_i name ta rt
    split at h
    · rename_i oa hoa
      split at h
      · rename_i tys htys
        simp only [Bool.and_eq_true] at h
        exact ⟨name, rt, ta, oa, tys, rfl, hoa, htys, h.1.1.1, h.1.1.2, h.1.2, h.2⟩
      · cases h
    · cases h
  · cases h

/-- `Map` builtins: `get`, and with a string key `has` and `set` (`steps/MapMemo.lean`). -/
def okMap (P : JSP F) (s : St F.S) (this : Val) (args : List Val) : MapN → Bool
  | .get => presB s aTypeErrorProto && (mapGetKeysB P s this (arg args 0) || mapGetB P s this (arg args 0) ||
      mapGetMemoB P s this (arg args 0))
  | .has => mapHasB P s this (arg args 0)
  | .set => mapSetB P s this (arg args 0) || mapSetSvzB P s this (arg args 0)
  | _ => false

/-- The acceptance of `Map` builtins before `has`, `set` and `get` on a memo. -/
def okMapOld (P : JSP F) (s : St F.S) (this : Val) (args : List Val) : MapN → Bool
  | .get => presB s aTypeErrorProto && (mapGetKeysB P s this (arg args 0) || mapGetB P s this (arg args 0))
  | _ => false

/-- **Agreement**: every `Map` call accepted before is accepted now (with the same simulation:
`dispatch`'s `get` cases are the previous ones). -/
theorem okMap_old {P : JSP F} {s : St F.S} {this : Val} {args : List Val} {f : MapN}
    (h : okMapOld P s this args f = true) : okMap P s this args f = true := by
  cases f <;> simp_all [okMapOld, okMap]

/-- `Math` builtins (`step_math_ceil`, `step_math_min`, `step_math_pow`). -/
def okMath : MathN → Bool
  | .ceil => true
  | .floor => true
  | .min => true
  | .pow => true
  | _ => false

/-- The acceptance of `Math` builtins before `pow`. -/
def okMathOld : MathN → Bool
  | .ceil => true
  | .floor => true
  | .min => true
  | _ => false

/-- **Agreement**: every `Math` call accepted before is accepted now. -/
theorem okMath_old {f : MathN} (h : okMathOld f = true) : okMath f = true := by
  cases f <;> simp_all [okMathOld, okMath]

def okNat (P : JSP F) (s : St F.S) (S : SSrv) (n : Nat) (nt : Native) (data : List Val) (this : Val)
    (args : List Val) : Bool :=
  match nt with
  | .arr f => match f with
    | .push => presB s aTypeErrorProto && pushB P s this
    | .slice => presB s aArrayProto && elemsB P s n this
    | .at => elemsB P s n this
    | .includes => plainElemsB P s this && inclB P s this (arg args 0)
    | .isArray => true
    | _ => false
  | .obj f => match f with
    | .entries => presB s aArrayProto && presB s aTypeErrorProto && entriesB P s n (arg args 0)
    | .hasOwn => hasOwnB P s (arg args 0) (arg args 1)
    | _ => false
  | .map f => okMap P s this args f
  | .math f => okMath f
  | .num f => match f with
    | .number => bfVB P (arg args 0)
    | .isSafeInteger => true
    | .bigint => presB s aTypeErrorProto && presB s aRangeErrorProto && presB s aErrorProto && bigIntB P (arg args 0)
    | _ => false
  | .buf f => match f with
    | .bufferFrom => presB s aArrayBufferProto && presB s aBufferProto
    | .getU32 => presB s aTypeErrorProto && getSideB P s n .u32 this args
    | .getI32 => presB s aTypeErrorProto && getSideB P s n .i32 this args
    | .getF32 => presB s aTypeErrorProto && getSideB P s n .f32 this args
    | .getBigU64 => presB s aTypeErrorProto && getSideB P s n .u64 this args
    | .setF32 => presB s aTypeErrorProto && setSideB P s .f32 args
    | .setU32 => presB s aTypeErrorProto && setSideB P s .u32 args
    | .setI32 => presB s aTypeErrorProto && setSideB P s .i32 args
    | .setBigU64 => presB s aTypeErrorProto && setSideB P s .u64 args
    | _ => false
  | .fn f => match f with
    | .finRegister => true
    | .finUnregister => true
    | .perfNow => true
    | _ => false
  | .ctl f => match f with
    | .agenNext | .agenReturn | .agenThrow => presB s aPromiseProto && presB s aObjectProto &&
        presB s aFunctionProto && presB s aTypeErrorProto && genStartB P s this
    | .genNext | .genReturn | .genThrow => presB s aObjectProto && presB s aFunctionProto &&
        presB s aTypeErrorProto && genStartB P s this
    | .alsGetStore => presB s aTypeErrorProto
    | .alsRun => presB s aTypeErrorProto
    | .promiseResolve => presB s aPromiseProto
    | .promiseReject => presB s aPromiseProto
    | .promiseThen | .promiseCatch => presB s aPromiseProto && presB s aTypeErrorProto
    | .setImmediate => presB s aPromiseProto && presB s aTypeErrorProto
    | .resolveFn | .rejectFn => true
    | .promiseCtor | .alsCtor => true
  | .ffi f => match f with
    | .ptr => presB s aTypeErrorProto && (match arg args 0 with
      | .obj p => nwoB P s p
      | _ => true)
    | .readU64 => rdB P s n args .u64
    | .readU32 => rdB P s n args .u32
    | .readI32 => rdB P s n args .i32
    | .readF32 => rdB P s n args .f32
    | .toArrayBuffer => presB s aArrayBufferProto && hostB args
    | .symbol => symCallB P s S n data args
    | _ => false
  | _ => false

def okCallB (P : JSP F) (s : St F.S) (S : SSrv) (n : Nat) (f this : Val) (args : List Val) : Bool :=
  match f with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .fn c => match c with
        | .closure fn _ _ _ => Nat.ble (paramNames fn).length two20
        | .klass _ _ _ _ => presB s aTypeErrorProto
        | .native nt data => okNat P s S n nt data this args
        | .bound _ _ _ => true
      | _ => presB s aTypeErrorProto && nwoB P s a
    | none => true
  | _ => presB s aTypeErrorProto

variable {okBack : F.S → Arg → Bool}

/-- The frame of a framed source `Map` is the one the parameters declare (a framed address
without one would hold an array). -/
theorem _root_.Host.Ts.Sim.RelB.w_of_wide (h : RelB F FR W stk M ν K s S t C) (hW : Wp P W) {a : Nat} {mo : Obj}
    {es : List (Val × Val)} {w : WFrame} (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es)
    (hfr : K.fr a ≠ none) (hwa : wideAt P a = some w) : W a = some w := by
  cases hwb : W a with
  | none =>
    exfalso
    obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hfr
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, xs, hk', _⟩ := h.obj?_framed hmo hp hwb
    rw [hmk] at hk'
    cases hk'
  | some w' => rw [hW.some_of hwa hwb]

theorem simNative {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack)
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args) (hFR : FRLaws FR) (hL : FfiLawful F) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {a : Nat} {this : Val} {args : List Val} {o : Obj}
    {nt : Native} {data : List Val} (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native nt data)) (hn : s.next + margin < Sim.bound)
    (hok : okNat P s S S.tab.length nt data this args = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hn' := lt_bound_of_margin hn
  cases nt with
  | arr f =>
    cases f with
    | push =>
      simp only [okNat, Bool.and_eq_true] at hok
      obtain ⟨hp, hpush⟩ := hok
      cases this with
      | obj b =>
        cases hfr : frB P b with
        | true =>
          refine MSim.toX (step_arr_push h hc ho hk hn hp ?_)
          rintro b' pre pre' hb hfr'
          cases hb
          rw [hK.fr_none hfr] at hfr'
          cases hfr'
        | false =>
          simp only [pushB, hfr, Bool.false_or, Bool.and_eq_true] at hpush
          obtain ⟨hbt, hext⟩ := hpush
          obtain ⟨⟨pre, pre'⟩, hfr'⟩ := Option.ne_none_iff_exists'.1 (hK.fr_some hfr)
          cases hs : s.stack with
          | nil => rw [hs] at hbt; cases hbt
          | cons f fs =>
            rw [hs] at hbt
            rcases f with _ | _ | _ | _ | ⟨r, env⟩ | _ | _ | _ <;> try cases hbt
            all_goals first
              | (refine MSim.toXD (step_arr_push_framed h hc ho hk hs hfr' ?_ hn)
                 intro ao hao
                 simp only [extB, hao] at hext
                 exact hext)
              | cases hbt
      | _ =>
        refine MSim.toX (step_arr_push h hc ho hk hn hp ?_)
        rintro b' pre pre' hb
        cases hb
    | slice =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_arr_slice h hc ho hk hF hn hok.1 (hK.elems hok.2))
    | «at» => exact MSim.toX (step_arr_at h hc ho hk hF (hK.elems hok))
    | includes =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_arr_includes h hFR hc ho hk (hK.plainElems hok.1) (hK.incl hok.2))
    | isArray => exact MSim.toX (step_arr_isArray h hc ho hk)
    | _ => simp [okNat] at hok
  | obj f =>
    cases f with
    | entries =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_obj_entries h hF hc ho hk hn hok.1.1 hok.1.2 (hK.entries hW hok.2))
    | hasOwn => exact MSim.toX (step_obj_hasOwn h hF hFR hc ho hk (hK.hasOwn hW hok))
    | _ => simp [okNat] at hok
  | map f =>
    cases f with
    | get =>
      simp only [okNat, okMap, Bool.and_eq_true, Bool.or_eq_true] at hok
      obtain ⟨hp, (hk2 | hg) | hm⟩ := hok
      · obtain ⟨b, cs, mo, es, gs, rfl, hcs, hwa, hmo, hmk, hfr, hhas, hng⟩ := mapGetKeysB_sound hk2
        have hfr' := hK.fr_some hfr
        have hw : W b = some (.mapKeys gs) := by
          cases hwb : W b with
          | none =>
            exfalso
            obtain ⟨p, hp'⟩ := Option.ne_none_iff_exists'.1 hfr'
            obtain ⟨pre, pre'⟩ := p
            obtain ⟨_, _, xs, hk', _⟩ := h.obj?_framed hmo hp' hwb
            rw [hmk] at hk'
            cases hk'
          | some w => rw [hW.some_of hwa hwb]
        exact MSim.toX (step_map_get_keys h hc ho hk rfl hmo hmk hfr' hw hcs hhas hng)
      · exact MSim.toX (step_map_get h hFR hc ho hk hn hp (hK.mapGet hW hg))
      · obtain ⟨b, cs, es, mo, gs, rfl, hcs, hmo, hmk, hfr, hwa, hng⟩ := mapGetMemoB_sound hm
        have hfr' := hK.fr_some hfr
        exact MSim.toX (step_map_get_memo h hc ho hk rfl hmo hmk hfr' (h.w_of_wide hW hmo hmk hfr' hwa) hcs hng)
    | has =>
      simp only [okNat, okMap] at hok
      obtain ⟨b, cs, es, mo, rfl, hcs, hmo, hmk, hfr⟩ := mapHasB_sound hok
      refine MSim.toX (step_map_has h hc ho hk rfl hmo hmk hcs ?_)
      rcases hfr with hfr | ⟨hfr, gs, ⟨hwa, hs⟩ | ⟨hwa, hg⟩⟩
      · exact .inl (hK.fr_none hfr)
      · have hfr' := hK.fr_some hfr
        exact .inr ⟨gs, hfr', .inl ⟨h.w_of_wide hW hmo hmk hfr' hwa, hs⟩⟩
      · have hfr' := hK.fr_some hfr
        exact .inr ⟨gs, hfr', .inr ⟨h.w_of_wide hW hmo hmk hfr' hwa, hg⟩⟩
    | set =>
      simp only [okNat, okMap, Bool.or_eq_true] at hok
      rcases hok with hok | hok
      · obtain ⟨b, cs, es, mo, rfl, hcs, hmo, hmk, hfr⟩ := mapSetB_sound hok
        refine MSim.toX (step_map_set h hc ho hk (bi_margin hn) rfl hmo hmk hcs ?_)
        rcases hfr with hfr | ⟨hfr, gs, hwa | hwa⟩
        · exact .inl (hK.fr_none hfr)
        · have hfr' := hK.fr_some hfr
          exact .inr ⟨gs, hfr', .inl (h.w_of_wide hW hmo hmk hfr' hwa)⟩
        · have hfr' := hK.fr_some hfr
          exact .inr ⟨gs, hfr', .inr (h.w_of_wide hW hmo hmk hfr' hwa)⟩
      · obtain ⟨b, mo, es, rfl, hmo, hmk, hfr, hsv⟩ := hK.mapSetSvz hok
        exact MSim.toX (step_map_set_svz h hFR hc ho hk (bi_margin hn) rfl hmo hmk hfr hsv)
    | _ => simp [okNat, okMap] at hok
  | math f =>
    cases f with
    | ceil => exact MSim.toX (step_math_ceil h hFR hc ho hk)
    | floor => exact MSim.toX (step_math_floor h hFR hc ho hk)
    | min => exact MSim.toX (step_math_min h hFR hc ho hk)
    | pow => exact MSim.toX (step_math_pow h hc ho hk)
    | _ => simp [okNat, okMath] at hok
  | num f =>
    cases f with
    | number => exact MSim.toX (step_num_number h hc ho hk (hK.number hok))
    | isSafeInteger => exact MSim.toX (step_num_isSafeInteger h hFR hc ho hk)
    | bigint =>
      simp only [okNat, Bool.and_eq_true] at hok
      obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
      exact MSim.toX (step_num_bigint h hc ho hk hn h1 h2 h3 (hK.bigInt h4))
    | _ => simp [okNat] at hok
  | buf f =>
    cases f with
    | bufferFrom =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_bufferFrom h hc ho hk hn hok.1 hok.2)
    | getU32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_getU32 h hFR hF hc ho hk hn' hok.1 (hK.getSide hok.2))
    | getI32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_getI32 h hFR hF hc ho hk hn' hok.1 (hK.getSide hok.2))
    | getF32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_getF32 h hFR hF hc ho hk hn' hok.1 (hK.getSide hok.2))
    | getBigU64 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_getBigU64 h hFR hF hc ho hk hn' hok.1 (hK.getSide hok.2))
    | setF32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_setF32 h hFR hc ho hk hn' hok.1 (hK.setSide hok.2) (setSideB_range hK hN h hok.2))
    | setU32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_setU32 h hFR hc ho hk hn' hok.1 (hK.setSide hok.2) (setSideB_range hK hN h hok.2))
    | setI32 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_setI32 h hFR hc ho hk hn' hok.1 (hK.setSide hok.2) (setSideB_range hK hN h hok.2))
    | setBigU64 =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_buf_setBigU64 h hFR hc ho hk hn' hok.1 (hK.setSide hok.2)
        (setSideB_range hK hN h hok.2))
    | _ => simp [okNat] at hok
  | fn f =>
    cases f with
    | finRegister => exact MSim.toX (step_fn_finRegister h hc ho hk)
    | finUnregister => exact MSim.toX (step_fn_finUnregister h hc ho hk)
    | perfNow => exact MSim.toX (step_fn_perfNow h hc ho hk)
    | _ => simp [okNat] at hok
  | ctl f =>
    cases f with
    | agenNext | agenReturn | agenThrow =>
      simp only [okNat, Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hok
      exact MSim.toX (step_call_agen h h1 h2 h3 h4 hc ho hk (by simp) (hK.genStart h5 true) hn)
    | genNext | genReturn | genThrow =>
      simp only [okNat, Bool.and_eq_true] at hok
      obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
      exact MSim.toX (step_call_gen h h1 h2 h3 hc ho hk (by simp) (hK.genStart h4 false) hn)
    | alsGetStore => exact MSim.toX (step_call_alsGetStore h hok hc ho hk hn)
    | alsRun => exact MSim.toX (step_call_alsRun h hok hc ho hk hn)
    | promiseResolve => exact MSim.toX (step_call_promiseResolve h hok hc ho hk hn)
    | promiseReject => exact MSim.toX (step_call_promiseReject h hok hc ho hk hn)
    | promiseThen | promiseCatch =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_call_promiseThen h hok.1 hok.2 hc ho hk (by simp) hn)
    | resolveFn | rejectFn => exact MSim.toX (step_call_resolveFn h hc ho hk (by simp) hn)
    | setImmediate =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_call_setImmediate h hok.1 hok.2 hc ho hk hn)
    | promiseCtor | alsCtor => exact MSim.toX (step_call_ctl_ctor h hc ho hk (by simp))
  | ffi f =>
    cases f with
    | ptr =>
      simp only [okNat, Bool.and_eq_true] at hok
      refine MSim.toX (step_ffi_ptr h hc ho hk hn' hok.1 fun p hp => ?_)
      have h2 := hok.2
      rw [hp] at h2
      exact hK.noW hW h2
    | readU64 => exact MSim.toX (step_ffi_readU64 h hF hc ho hk (hK.rd hok))
    | readU32 => exact MSim.toX (step_ffi_readU32 h hF hc ho hk (hK.rd hok))
    | readI32 => exact MSim.toX (step_ffi_readI32 h hF hc ho hk (hK.rd hok))
    | readF32 => exact MSim.toX (step_ffi_readF32 h hF hc ho hk (hK.rd hok))
    | toArrayBuffer =>
      simp only [okNat, Bool.and_eq_true] at hok
      exact MSim.toX (step_ffi_toArrayBuffer h hc ho hk hn' hok.1 (hostB_sound hN h hok.2))
    | symbol =>
      simp only [okNat] at hok
      obtain ⟨name, rt, ta, oa, tys, rfl, hoa, htys, h1, h2, h3, h4⟩ := symCallB_spec hok
      exact MSim.toX (step_ffi_symbolP h hFR hF hC hL hc ho hk hoa htys hn' (hK.fr_none h1)
        (fun v hv => hK.argBuf hW (allB_sound h2 v hv)) (hK.boolsP h3) (symOKB_sound hK h4)
        (fun as S1 hr => hsm _ _ _ _ (symOKB_small h4 as S1 hr))
        (fun f hf _ => hN.cb M _ _ _ h.ffi f hf))
    | _ => simp [okNat] at hok
  | _ => simp [okNat] at hok

theorem simCall {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack)
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} (hC : FfiCallSim F FR P.okCall small)
    (hsm : ∀ S x name args, P.smallB S x name args = true → small ν S x name args) (hFR : FRLaws FR) (hL : FfiLawful F) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {f this : Val} {args : List Val}
    (hc : s.ctl = .call f this args) (hn : s.next + margin < Sim.bound)
    (hok : okCallB P s S S.tab.length f this args = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | obj a =>
    cases ho : s.obj? a with
    | none => exact MSim.toX (step_call_dangling h hc ho)
    | some o =>
      simp only [okCallB, ho] at hok
      cases hk : o.kind with
      | fn c =>
        simp only [hk] at hok
        cases c with
        | closure fn cenv arrow home => exact MSim.toX (step_call_closure h hc ho hk (le20 hok) hn)
        | klass ctor cenv par inst => exact MSim.toX (step_call_klass h hc ho hk hok hn)
        | bound tg th0 as => exact MSim.toX (step_call_bound h hc ho hk)
        | native nt data => exact simNative hF hC hsm hFR hL hK hW hN h hc ho hk hn hok
      | _ =>
        simp only [hk, Bool.and_eq_true] at hok
        exact MSim.toX (step_call_nonFn h hc ho (fun c hc' => by rw [hk] at hc'; cases hc') hok.1 hn
          (hK.noW hW hok.2))
  | _ => exact MSim.toX (step_call_prim h hc (fun a ha => by cases ha) hok hn)

/-- `new <TypedArray>(x)`. -/
def typedCtorB (P : JSP F) (s : St F.S) (S : SSrv) (n : Nat) (data args : List Val) : Bool :=
  match data with
  | [.num (.lit c), .num (.lit p)] => match F64.toIndex? c, F64.toIndex? p with
    | some ci, some proto => Nat.blt proto aFirst && presB s aArrayBufferProto && presB s proto &&
        presB s aRangeErrorProto && presB s aTypeErrorProto && elemsB P s n (arg args 0) &&
        ctorElemsB P s S (eltOfCode ci) (arg args 0)
    | _, _ => false
  | _ => false

theorem typedCtorB_spec {s : St F.S} {S : SSrv} {n : Nat} {data args : List Val}
    (h : typedCtorB P s S n data args = true) :
    ∃ c p ci proto, data = [.num (.lit c), .num (.lit p)] ∧ F64.toIndex? c = some ci ∧
      F64.toIndex? p = some proto ∧ proto < aFirst ∧ Present s aArrayBufferProto ∧ Present s proto ∧
      Present s aRangeErrorProto ∧ Present s aTypeErrorProto ∧ elemsB P s n (arg args 0) = true ∧
      ctorElemsB P s S (eltOfCode ci) (arg args 0) = true := by
  unfold typedCtorB at h
  split at h
  · rename_i c p
    split at h
    · rename_i ci proto hci hpi
      simp only [Bool.and_eq_true, Nat.blt_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩ := h
      exact ⟨c, p, ci, proto, rfl, hci, hpi, h1, h2, h3, h4, h5, h6, h7⟩
    · cases h
  · cases h

def okConsB (P : JSP F) (s : St F.S) (S : SSrv) (n : Nat) (f : Val) (args : List Val) (nt : Val) : Bool :=
  match f with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .fn c => match c with
        | .klass ctor _ par _ => match par with
          | .null => presB s aObjectProto && lookupNoWB P s nt
          | _ => match ctor with
            | some fn => Nat.ble (paramNames fn).length two20
            | none => true
        | .native nt data => match nt with
          | .buf .typedCtor => typedCtorB P s S n data args
          | _ => false
        | .bound _ _ _ => true
        | .closure fn _ arrow _ => match arrow with
          | false => Nat.ble (paramNames fn).length two20 && presB s aObjectProto
          | true => presB s aTypeErrorProto
      | _ => presB s aTypeErrorProto && nwoB P s a
    | none => true
  | _ => presB s aTypeErrorProto

theorem simCons {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {f : Val} {args : List Val} {nt : Val}
    (hc : s.ctl = .construct f args nt) (hn : s.next + margin < Sim.bound)
    (hok : okConsB P s S S.tab.length f args nt = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | obj a =>
    cases ho : s.obj? a with
    | none => exact MSim.toX (step_construct_dangling h hc ho)
    | some o =>
      simp only [okConsB, ho] at hok
      cases hk : o.kind with
      | fn c =>
        simp only [hk] at hok
        cases c with
        | closure fn cenv arrow home =>
          cases arrow with
          | false =>
            simp only [Bool.and_eq_true] at hok
            exact MSim.toX (step_construct_closure h hc ho hk (le20 hok.1) hok.2 hn)
          | true => exact MSim.toX (step_construct_arrow h hc ho hk hok hn)
        | klass ctor cenv par inst =>
          cases par with
          | null =>
            simp only [Bool.and_eq_true] at hok
            exact MSim.toX (step_construct_base h hF hc ho hk hok.1 hn (hK.lookupNoW hW hok.2))
          | _ =>
            refine MSim.toX (step_construct_derived h hc ho hk (fun he => by cases he) ?_ hn)
            rintro fn rfl
            exact le20 hok
        | bound tg th0 as => exact MSim.toX (step_construct_bound h hc ho hk)
        | native n data =>
          rcases n with _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | bf | _ | _ | _ | _ <;> try simp at hok
          cases bf with
          | typedCtor =>
            simp only at hok
            obtain ⟨c, p, ci, proto, rfl, hci, hpi, h1, h2, h3, h4, h5, h6, h7⟩ := typedCtorB_spec hok
            exact MSim.toX (step_buf_typedCtor h hFR hF hc ho hk hci hpi hn h1 h2 h3 h4 h5 (hK.elems h6)
              (hK.ctorElems h7) (ctorElemsB_range hK hN h h7))
          | _ => simp at hok
      | _ =>
        simp only [hk, Bool.and_eq_true] at hok
        exact MSim.toX (step_construct_nonFn h hc ho (fun c hc' => by rw [hk] at hc'; cases hc') hok.1 hn
          (hK.noW hW hok.2))
  | _ => exact MSim.toX (step_construct_prim h hc (fun a ha => by cases ha) hok hn)

end
end Host.Ts.Sim.Disp
