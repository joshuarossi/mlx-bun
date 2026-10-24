import host.sim.steps.Props
import host.sim.Run
import host.sim.dispatch.SafeInt
import host.ts.MapLookup
namespace Host.Ts.Sim

/-! # Leaf builtins of the decode loop

One-step simulations of `.call f this args` where `f` is a native builtin
(`callNative`): `Array.prototype.push/slice/at/includes`, `Array.isArray`,
`Object.entries/hasOwn`, `Map.prototype.get`, `Math.ceil/min`, `Number`,
`BigInt`, `Number.isSafeInteger` and `FinalizationRegistry.prototype.register/
unregister`. Each `step_*` lemma takes the callee facts (`hc`, `ho`, `hk`) and
source-only side conditions:

* `PushOK`: pushing onto a framed array returns its new length, which agrees on
  both sides only when the two prefixes have equal lengths. Below a statement-list
  frame, which discards the length, `step_arr_push_framed` needs no such condition:
  the results are related by `RelD`.
* element reads (`ElemsOK` of `Props`, `PlainElemsOK`), own-property reads
  (`EntriesOK`, `HasOwnOK`): the object is unframed; typed arrays need `TypedOK`
  or are excluded.
* comparisons (`StrictOK` of `Props`, `InclOK`, `SvzOK`, `MapGetOK`): compared
  bigints are fixed by the map or equal, compared native pointers share their
  region, and SameValueZero (which tests `NaN` syntactically) never compares two
  numbers unless both are literals or one is a literal other than `NaN`.
* conversions (`NumberOK`, `BigIntOK`): bigint results and arguments are
  `BigFixed`; native pointers satisfy the range of `Rel.bigExt`; JavaScript-memory
  pointers are excluded.
* allocation counts: `Object.entries` allocates one array per own key
  (`EntriesOK` bounds the keys by `2 ^ 20`). -/

/-! ## Lists -/

theorem bi_lenL {α : Type} : ∀ (l : List α) (n : Nat), lenL l n = l.length + n
  | [], _ => by simp [lenL]
  | _ :: l, n => by simp only [lenL, bi_lenL l (Nat.succ n), List.length_cons]; omega

theorem bi_len {α : Type} (l : List α) : len l = l.length := by simp [len, bi_lenL]

theorem bi_len_vals (M : Map) (es : List Val) : len (M.vals es) = len es := len_map M.val es

theorem bi_arg_map (M : Map) : ∀ (args : List Val) (i : Nat), arg (M.vals args) i = M.val (arg args i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: as, i + 1 => bi_arg_map M as i

theorem bi_nthD_map (M : Map) : ∀ (es : List Val) (i : Nat),
    nthD .undef (M.vals es) i = M.val (nthD .undef es i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: as, i + 1 => bi_nthD_map M as i

theorem bi_nthD_supp {A : Nat → Prop} {n : Nat} : ∀ {es : List Val} (i : Nat), Supp.vals A n es →
    Supp.val A n (nthD .undef es i)
  | [], _, _ => trivial
  | a :: _, 0, h => h a (List.mem_cons_self ..)
  | _ :: as, i + 1, h => bi_nthD_supp (es := as) i (fun v hv => h v (List.mem_cons_of_mem _ hv))

theorem bi_arg_supp {A : Nat → Prop} {n : Nat} {args : List Val} (i : Nat) (h : Supp.vals A n args) :
    Supp.val A n (arg args i) :=
  bi_nthD_supp i h

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Reading the callee -/

theorem RelB.bi_fr (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : ¬ Wideable o.kind) : K.fr a = none :=
  h.fr_none ho hk hw

theorem RelB.bi_obj (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : ¬ Wideable o.kind) :
    t.obj? (M.a a) = some (M.obj o) :=
  h.obj? ho (h.bi_fr ho hk hw)

theorem bi_step_call {f th : Val} {as : List Val} (hc : s.ctl = .call f th as) :
    step F s = callStep F s f th as := by
  unfold step; rw [hc]

/-- A call of a builtin reduces to `callNative` on both sides. -/
theorem RelB.bi_native (h : RelB F FR W stk M ν K s S t C) {fa : Nat} {this : Val} {args : List Val} {o : Obj}
    {n : Native} {data : List Val}
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native n data)) :
    step F s = callNative F s n data this args ∧
      step F t = callNative F t n (M.vals data) (M.val this) (M.vals args) ∧
      Supp.val (Present s) S.tab.length this ∧ Supp.vals (Present s) S.tab.length args := by
  have htc : t.ctl = .call (.obj (M.a fa)) (M.val this) (M.vals args) := by rw [h.ctl, hc]; rfl
  have ht : t.obj? (M.a fa) = some (M.obj o) :=
    h.bi_obj ho (by intro es he; rw [hk] at he; cases he) (by rw [hk]; exact id)
  have hs := h.ctlSupp
  rw [hc] at hs
  refine ⟨?_, ?_, hs.2.1, hs.2.2⟩
  · rw [bi_step_call hc]; simp only [callStep, ho, hk]
  · rw [bi_step_call htc]
    have hk' : (M.obj o).kind = .fn (.native n (M.vals data)) := by
      show M.kind o.kind = _; rw [hk]; rfl
    simp only [callStep, ht, hk']


/-! ## Simulation combinators -/

/-- A computation without server requests: same map and servers, related results (`ReadPost`). -/
abbrev ESim (M : Map) (S : SSrv) (C : CSrv) {α β : Type} (R : α → β → Prop) (m : Host.Ts.M α)
    (m' : Host.Ts.M β) : Prop :=
  MSim (ReadPost M S C R) S C m m'

theorem ESim.pure {α β : Type} {R : α → β → Prop} {a : α} {b : β} (hr : R a b) :
    ESim M S C R (Host.Ts.M.pure a) (Host.Ts.M.pure b) :=
  MSim.pure ⟨rfl, rfl, rfl, hr⟩

theorem ESim.fail {α β : Type} {R : α → β → Prop} (msg : String) (m' : Host.Ts.M β) :
    ESim M S C R (Host.Ts.M.fail (α := α) msg) m' :=
  MSim.fail _ _

theorem ESim.bind {α β α' β' : Type} {R : α → β → Prop} {P : Map → SSrv → CSrv → α' → β' → Prop}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} {f : α → Host.Ts.M α'} {f' : β → Host.Ts.M β'}
    (hm : ESim M S C R m m') (hf : ∀ a b, R a b → MSim P S C (f a) (f' b)) :
    MSim P S C (Host.Ts.M.bind m f) (Host.Ts.M.bind m' f') :=
  MSim.bind hm fun M' S' C' a b ⟨e1, e2, e3, hr⟩ => by subst e1 e2 e3; exact hf a b hr

/-- Binding a computation that grows the servers into a step. -/
theorem bi_bind {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {m : Host.Ts.M α}
    {m' : Host.Ts.M β} {f : α → RS F} {f' : β → RS F}
    (hm : MSim P S C m m') (hP : ∀ M' S' C' a b, P M' S' C' a b → Grow M ν S C M' S' C')
    (hf : ∀ M' S' C' a b, P M' S' C' a b → MSim (StepPostB F FR W stk M' ν K S' C') S' C' (f a) (f' b)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.bind m f) (Host.Ts.M.bind m' f') :=
  MSim.bind hm fun M' S' C' a b hp =>
    MSim.mono (hf M' S' C' a b hp) fun _ _ _ _ _ ⟨g, r⟩ => ⟨(hP _ _ _ _ _ hp).trans g, r⟩

theorem Grow.bi_val {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {v : Val} (hv : Supp.val A S.tab.length v) : M'.val v = M.val v :=
  (Map.val_agree g.ext.agree hv).symm

theorem Grow.bi_vals {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {vs : List Val} (hv : Supp.vals A S.tab.length vs) : M'.vals vs = M.vals vs :=
  (Map.vals_agree g.ext.agree hv).symm

theorem bi_supp_grow {A : Nat → Prop} {M' : Map} {S' : SSrv} {C' : CSrv} (g : Grow M ν S C M' S' C')
    {v : Val} (hv : Supp.val A S.tab.length v) : Supp.val A S'.tab.length v :=
  Supp.val_mono (fun _ h => h) g.len hv

theorem bi_supps_grow {A : Nat → Prop} {M' : Map} {S' : SSrv} {C' : CSrv} (g : Grow M ν S C M' S' C')
    {vs : List Val} (hv : Supp.vals A S.tab.length vs) : Supp.vals A S'.tab.length vs :=
  Supp.vals_mono (fun _ h => h) g.len hv

/-! ## Results -/

theorem bi_rel {s' t' : St F.S} (h : RelB F FR W stk M ν K s' S t' C) :
    MSim (StepPostB F FR W stk M ν K S C) S C (Host.Ts.M.pure s') (Host.Ts.M.pure t') :=
  MSim.pure ⟨Grow.refl h.srv, h⟩

theorem M_bind_pure {α β : Type} (a : α) (f : α → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

theorem bi_ret (h : RelB F FR W stk M ν K s S t C) (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retS F s v) (retS F t (M.val v)) :=
  bi_rel (h.ret v hv)

theorem RelB.bi_s64 (_h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

theorem bi_margin (hn : s.next + margin < Sim.bound) : s.next < Sim.bound := by
  have : 0 < margin := by decide
  omega

/-- Allocate an object with an intrinsic prototype and return it. -/
theorem bi_allocObj_ret (h : RelB F FR W stk M ν K s S t C) (k : Kind) (p : Nat) (ps : Props)
    (hn : s.next < Sim.bound) (hI : M.a p = p) (hp : Present s p)
    (hk : Supp.kind (Present s) S.tab.length k) (hps : Supp.props (Present s) S.tab.length ps) :
    MSim (StepPostB F FR W stk M ν K S C) S C
      (retS F (s.allocObj k (.obj p) ps).2 (.obj (s.allocObj k (.obj p) ps).1))
      (retS F (t.allocObj (M.kind k) (.obj p) (M.props ps)).2
        (.obj (t.allocObj (M.kind k) (.obj p) (M.props ps)).1)) := by
  have h64 := h.bi_s64 hn
  have hP : ∀ a, Present s a → Present (s.allocObj k (.obj p) ps).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  have hv : M.val (.obj p) = .obj p := by show Val.obj (M.a p) = .obj p; rw [hI]
  obtain ⟨ha, hr⟩ := h.allocObj k (.obj p) ps hn (Supp.kind_mono hP (Nat.le_refl _) hk) (hP p hp)
    (Supp.props_mono hP (Nat.le_refl _) hps)
  rw [hv] at ha hr
  have := bi_ret hr (.obj (s.allocObj k (.obj p) ps).1) (Present.alloc_next s _ h64)
  rw [show M.val (.obj (s.allocObj k (.obj p) ps).1) = .obj (M.a (s.allocObj k (.obj p) ps).1) from rfl,
    ← ha] at this
  exact this


/-! ## Numbers with the support of the result -/

private theorem bi_srv_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Srv (M.setNum S.tab.length x) ν { S with tab := S.tab ++ [e] } C1 := by
  refine ⟨?_, hs.good⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hle.val (hs.num i e' hi')
  · rw [M.setNum_self]
    exact hx

private theorem bi_push_val (C : CSrv) (x : F64) :
    (⟨C.tab ++ [x]⟩ : CSrv).val (.ref C.tab.length) = some x :=
  nth?_length_append C.tab x

private theorem bi_grow_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Grow M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C1 :=
  ⟨M.setNum_ext _ _, bi_srv_push hs hle e x hx, by simp⟩

private theorem bi_supp_push {A : Nat → Prop} (S : SSrv) (e : SymE) :
    Supp.nv A ({ S with tab := S.tab ++ [e] } : SSrv).tab.length (.ref S.tab.length) := by
  show S.tab.length < (S.tab ++ [e]).length
  simp

private theorem bi_numBin_req {δ : Type} (op : NBin) (x y : NumV) (k' : NumV → Free δ)
    (h : ∀ u v, x = .lit u → y = .lit v → False) :
    (numBin op x y) δ k' = .bin op x y fun j => k' (.ref j) := by
  cases x with
  | lit u =>
    cases y with
    | lit v => exact (h u v rfl rfl).elim
    | ref _ => rfl
  | ref _ => cases y <;> rfl

theorem bi_numBin_sim {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NBin)
    (a b : NumV) :
    MSim (fun M' S' C' r r' => r' = M'.nv r ∧ Supp.nv A S'.tab.length r ∧ Grow M ν S C M' S' C') S C
      (numBin op a b) (numBin op (M.nv a) (M.nv b)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.bin op a b K) ((numBin op (M.nv a) (M.nv b)) δ k') := by
    intro K hK r S' hu
    rw [interpS_bin] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      cases hvb : S.val b with
      | none => rw [hva, hvb] at hu; cases hu
      | some eb =>
        rw [hva, hvb] at hu
        simp only at hu
        rw [hK] at hu
        have ca := hs.num.val hva
        have cb := hs.num.val hvb
        by_cases lits : ∃ u v, M.nv a = .lit u ∧ M.nv b = .lit v
        · obtain ⟨u, v, hu', hv'⟩ := lits
          rw [hu'] at ca; rw [hv'] at cb
          simp only [CSrv.val, Option.some.injEq] at ca cb
          subst ca cb
          have hg := bi_grow_push hs (CSrv.Le.refl C) (.bin op ea eb)
            (.lit (F64.bin op (ea.eval ν) (eb.eval ν))) rfl
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length)
            (.lit (F64.bin op (ea.eval ν) (eb.eval ν)))
            ⟨(M.setNum_self _ _).symm, bi_supp_push S _, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [hu', hv']
          exact hv
        · have hnot : ∀ u v, M.nv a = .lit u → M.nv b = .lit v → False :=
            fun u v h1 h2 => lits ⟨u, v, h1, h2⟩
          have hg := bi_grow_push hs (C1 := ⟨C.tab ++ [F64.bin op (ea.eval ν) (eb.eval ν)]⟩) ⟨_, rfl⟩
            (.bin op ea eb) (.ref C.tab.length) (bi_push_val C _)
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
            ⟨(M.setNum_self _ _).symm, bi_supp_push S _, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [bi_numBin_req op _ _ k' hnot, interpC_bin, ca, cb]
          exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk M S C _ _ ⟨rfl, trivial, Grow.refl hs⟩
    | ref j => exact req _ (fun _ => rfl)
  | ref i =>
    cases b with
    | lit y => exact req _ (fun _ => rfl)
    | ref j => exact req _ (fun _ => rfl)


/-! ## Builtins without effects: `FinalizationRegistry`, `Number.isSafeInteger`, `Array.isArray` -/

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_fn_finRegister (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.fn .finRegister) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_ret h .undef trivial

theorem step_fn_finUnregister (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.fn .finUnregister) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_ret h (.bool false) trivial

/-- `Number.isSafeInteger`: a literal argument is tested on both sides; a reference asks the
server (`safeB`), and the target, holding its image, computes the same answer (`Disp.safeB_sim`). -/
theorem step_num_isSafeInteger (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.num .isSafeInteger) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, numN, numN.safeTest, bi_arg_map]
  have hsa := bi_arg_supp 0 hargs
  cases ha : arg args 0 with
  | num x =>
    cases x with
    | lit x => exact bi_ret h (.bool _) trivial
    | ref i =>
      rw [ha] at hsa
      have key : ∀ z, M.num i = z → MSim (StepPostB F FR W stk M ν K S C) S C
          (Host.Ts.M.bind (safeB (.ref i)) fun b => retS F s (.bool b))
          (Host.Ts.M.bind (safeB z) fun b => retS F t (.bool b)) := by
        intro z hz
        have hm := Disp.safeB_sim (A := Present s) h.srv (.ref i) hsa
        rw [show M.nv (.ref i) = z from hz] at hm
        refine bi_bind hm (fun _ _ _ _ _ hp => hp.2) ?_
        rintro M' S' C' b b' ⟨rfl, g⟩
        exact bi_ret (h.grow hFR g) (.bool b') trivial
      simp only [Map.val, Map.nv]
      cases hm : M.num i with
      | lit u =>
        have := key (.lit u) hm
        rw [Disp.safeB_lit] at this
        exact this
      | ref j => exact key (.ref j) hm
  | _ => exact bi_ret h (.bool false) trivial

end steps

theorem RelB.bi_arrayOf_isSome (h : RelB F FR W stk M ν K s S t C) {a : Nat} (hp : Present s a) :
    (Host.Ts.arrayOf F t (M.a a)).isSome = (Host.Ts.arrayOf F s a).isSome := by
  obtain ⟨ho, hg⟩ := hp.get
  cases ho with
  | cell v =>
    obtain ⟨v', hv'⟩ := h.cell_target hg
    have h1 : s.obj? a = none := by unfold St.obj?; rw [hg]
    have h2 : t.obj? (M.a a) = none := by unfold St.obj?; rw [hv']
    simp only [Host.Ts.arrayOf, h1, h2]
  | obj o =>
    have h1 : s.obj? a = some o := obj?_iff.2 hg
    cases hfr : K.fr a with
    | none =>
      have h2 := h.obj? h1 hfr
      simp only [Host.Ts.arrayOf, h1, h2]
      cases hk : o.kind <;> simp [Map.obj, Map.kind, hk]
    | some p =>
      cases hw : W a with
      | none =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', h2, xs, hk, rfl⟩ := h.obj?_framed h1 hfr hw
        simp only [Host.Ts.arrayOf, h1, h2, hk, Option.isSome_some]
      | some w =>
        obtain ⟨o', ht, hk, hk'⟩ := h.wide_obj hg hfr hw
        have h2 := obj?_iff.2 ht
        obtain ⟨kd, pr, ps, pv, ex⟩ := o
        obtain ⟨kd', pr', ps', pv', ex'⟩ := o'
        have e1 : (Host.Ts.arrayOf F s a).isSome = false := by
          cases kd <;> first | exact (hk : False).elim | simp only [Host.Ts.arrayOf, h1]; rfl
        have e2 : (Host.Ts.arrayOf F t (M.a a)).isSome = false := by
          rcases hk' with hk' | ⟨bs, hb⟩ | ⟨kk, b, off, n, hb⟩
          · cases kd' <;> first | exact (hk' : False).elim | simp only [Host.Ts.arrayOf, h2]; rfl
          · simp only at hb; subst hb; simp only [Host.Ts.arrayOf, h2]; rfl
          · simp only at hb; subst hb; simp only [Host.Ts.arrayOf, h2]; rfl
        rw [e1, e2]

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_arr_isArray (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.arr .isArray) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, arrN, bi_arg_map]
  have hv := bi_arg_supp 0 hargs
  cases hx : arg args 0 with
  | obj a =>
    rw [hx] at hv
    have := bi_ret h (.bool (Host.Ts.arrayOf F s a).isSome) trivial
    rw [show M.val (.bool (Host.Ts.arrayOf F s a).isSome) = .bool (Host.Ts.arrayOf F t (M.a a)).isSome by
      rw [h.bi_arrayOf_isSome hv]; rfl] at this
    exact this
  | _ => exact bi_ret h (.bool false) trivial

end steps


/-! ## `Array.prototype.push` -/

theorem bi_arrayOf_some {s : St F.S} {a : Nat} {o : Obj} {es : List Val}
    (h : Host.Ts.arrayOf F s a = some (o, es)) : s.obj? a = some o ∧ o.kind = .array es := by
  unfold Host.Ts.arrayOf at h
  split at h
  · rename_i o' ho
    split at h
    · rename_i es' hk
      cases h
      exact ⟨ho, hk⟩
    · cases h
  · cases h

theorem bi_obj_with_kind (M : Map) (o : Obj) (k : Kind) :
    M.obj { o with kind := k } = { M.obj o with kind := M.kind k } := by
  cases o; rfl

theorem bi_setArray {s : St F.S} {a : Nat} {o : Obj} (ho : s.obj? a = some o) (es : List Val) :
    setArray F s a es = s.setObj a { o with kind := .array es } := by
  simp only [setArray, ho]

/-- The object with a replaced kind keeps its support. -/
theorem bi_supp_kind {A : Nat → Prop} {n : Nat} {o : Obj} {k : Kind} (ho : Supp.obj A n o)
    (hk : Supp.kind A n k) : Supp.obj A n { o with kind := k } :=
  ⟨hk, ho.2.1, ho.2.2.1, ho.2.2.2⟩

theorem bi_supp_append {A : Nat → Prop} {n : Nat} {xs ys : List Val} (hx : Supp.vals A n xs)
    (hy : Supp.vals A n ys) : Supp.vals A n (xs ++ ys) := fun v hv => by
  rcases List.mem_append.1 hv with hv | hv
  · exact hx v hv
  · exact hy v hv

/-- Pushing onto an unframed array: both sides write the mapped elements. -/
theorem RelB.bi_push_plain (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj} {es ys : List Val}
    (hn : s.next < Sim.bound) (hfr : K.fr a = none) (ho : s.obj? a = some o) (hk : o.kind = .array es)
    (hys : Supp.vals (Present s) S.tab.length ys) :
    Host.Ts.arrayOf F t (M.a a) = some (M.obj o, M.vals es) ∧
      RelB F FR W stk M ν K (setArray F s a (es ++ ys)) S (setArray F t (M.a a) (M.vals es ++ M.vals ys)) C := by
  have hto := h.obj? ho hfr
  have hso := h.obj?_supp ho
  have hes : Supp.vals (Present s) S.tab.length es := by have := hso.1; rw [hk] at this; exact this
  refine ⟨by simp only [Host.Ts.arrayOf, hto, Map.obj, hk, Map.kind], ?_⟩
  rw [bi_setArray ho, bi_setArray hto]
  have := h.setObj { o with kind := .array (es ++ ys) } hn (Present.of_get (obj?_iff.1 ho)) hfr
    (bi_supp_kind hso (bi_supp_append hes hys))
  rw [bi_obj_with_kind] at this
  simpa only [Map.kind, Map.vals, List.map_append] using this

/-- Pushing onto a framed array: each side keeps its own prefix. -/
theorem RelB.bi_push_framed (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj} {pre pre' xs ys : List Val}
    (hn : s.next < Sim.bound) (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o)
    (hk : o.kind = .array (pre ++ xs)) (hys : Supp.vals (Present s) S.tab.length ys) :
    ∃ o', Host.Ts.arrayOf F t (M.a a) = some (o', pre' ++ M.vals xs) ∧ o'.extensible = o.extensible ∧
      RelB F FR W stk M ν K (setArray F s a (pre ++ xs ++ ys)) S
        (setArray F t (M.a a) (pre' ++ M.vals xs ++ M.vals ys)) C := by
  have hw : W a = none := h.w_none (.of_array ho hk) hfr
  obtain ⟨o', hto, hfo⟩ := h.obj?_framed ho hfr hw
  have hr := h.setFramed hn hfr hw ho hfo hk hys
  obtain ⟨xs', hk', ho'⟩ := hfo
  have hxs : xs' = xs := by
    have he := hk'.symm.trans hk
    injection he with he
    exact List.append_cancel_left he
  subst hxs ho'
  refine ⟨{ M.obj o with kind := .array (pre' ++ M.vals xs') }, by simp only [Host.Ts.arrayOf, hto], rfl, ?_⟩
  rw [bi_setArray ho, bi_setArray hto]
  simpa only [Map.vals, List.map_append, List.append_assoc] using hr

/-- A framed receiver's returned length agrees only when the two prefixes have equal lengths. -/
def PushOK (K : Ctx) (this : Val) : Prop :=
  ∀ a pre pre', this = .obj a → K.fr a = some (pre, pre') → pre.length = pre'.length

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_arr_push (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.arr .push) data))
    (hn : s.next + margin < Sim.bound) (hp : Present s aTypeErrorProto) (hok : PushOK K this) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  simp only [callNative, arrN, arrN.withArr]
  cases this with
  | obj a =>
    simp only [Map.val]
    cases har : Host.Ts.arrayOf F s a with
    | none => exact MSim.fail _ _
    | some p =>
      obtain ⟨ao, es⟩ := p
      obtain ⟨hao, hka⟩ := bi_arrayOf_some har
      cases hfr : K.fr a with
      | none =>
        obtain ⟨har', hr⟩ := h.bi_push_plain hn' hfr hao hka hargs
        rw [har']
        dsimp only
        rw [show (M.obj ao).extensible = ao.extensible from rfl]
        cases ao.extensible
        · exact typeErr_sim h h.intr hn' hp _
        · have e3 : len (M.vals es ++ M.vals args) = len (es ++ args) := by
            simp only [bi_len, List.length_append, Map.vals, List.length_map]
          rw [e3]
          exact bi_rel (hr.ret _ trivial)
      | some pp =>
        obtain ⟨pre, pre'⟩ := pp
        obtain ⟨_, _, xs, hxk, _⟩ := h.obj?_framed hao hfr (h.w_none (.of_array hao hka) hfr)
        have hes : es = pre ++ xs := by rw [hka] at hxk; injection hxk
        subst hes
        obtain ⟨o', har', hext, hr⟩ := h.bi_push_framed hn' hfr hao hka hargs
        rw [har']
        dsimp only
        rw [hext]
        cases ao.extensible
        · exact typeErr_sim h h.intr hn' hp _
        · have e3 : len (pre' ++ M.vals xs ++ M.vals args) = len (pre ++ xs ++ args) := by
            simp only [bi_len, List.length_append, Map.vals, List.length_map, hok a pre pre' rfl hfr]
          rw [e3]
          exact bi_rel (hr.ret _ trivial)
  | _ => exact MSim.fail _ _

/-- `push` onto a framed (extensible) array below a statement-list frame: the returned
lengths differ (each side keeps its own prefix), and the frame discards them (`RelD`). -/
theorem step_arr_push_framed (h : RelB F FR W stk M ν K s S t C) {a : Nat} {pre pre' : List Val}
    {r : List Stmt} {env : Env} {fs : List Frame}
    (hc : s.ctl = .call (.obj fa) (.obj a) args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.arr .push) data)) (hs : s.stack = .s (.block r env) :: fs)
    (hfr : K.fr a = some (pre, pre')) (hext : ∀ ao, s.obj? a = some ao → ao.extensible = true)
    (hn : s.next + margin < Sim.bound) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ RelDB F FR W stk M' ν K s1 S' t1 C') S C
      (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  simp only [callNative, arrN, arrN.withArr, Map.val]
  cases har : Host.Ts.arrayOf F s a with
  | none => exact MSim.fail _ _
  | some p =>
    obtain ⟨ao, es⟩ := p
    obtain ⟨hao, hka⟩ := bi_arrayOf_some har
    obtain ⟨_, _, xs, hxk, _⟩ := h.obj?_framed hao hfr (h.w_none (.of_array hao hka) hfr)
    have hes : es = pre ++ xs := by rw [hka] at hxk; injection hxk
    subst hes
    obtain ⟨o', har', hext', hr⟩ := h.bi_push_framed hn' hfr hao hka hargs
    rw [har']
    dsimp only
    rw [hext', hext ao hao]
    refine MSim.pure ⟨Grow.refl h.srv, ?_⟩
    unfold RelDB
    refine ⟨_, _, r, env, fs, rfl, rfl, ?_, hr.ret _ trivial⟩
    show (setArray F s a (pre ++ xs ++ args)).stack = _
    rw [bi_setArray hao]
    exact hs

end steps

/-! ## Element lists: `slice`, `at` -/

/-- The receiver's elements are read alike on both sides: it is neither a framed
array nor a typed array (typed-array element reads go through the buffers). -/
def PlainElemsOK {S' : Type} (K : Ctx) (s : St S') (v : Val) : Prop :=
  ∀ a, v = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o → ∀ k b off n, o.kind ≠ .typed k b off n

/-- Where an element list comes from: an array object's elements or a string's characters. -/
def ElemsFrom {S' : Type} (s : St S') (v : Val) (es : List Val) : Prop :=
  (∃ a o, v = .obj a ∧ s.obj? a = some o ∧ o.kind = .array es) ∨
    (∃ cs : List Char, v = .str cs ∧ es = cs.map fun c => .str [c])

theorem RelB.bi_elemsOf (h : RelB F FR W stk M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hok : PlainElemsOK K s v) :
    ESim M S C (fun r r' => r' = r.map M.vals ∧
        ∀ es, r = some es → Supp.vals (Present s) S.tab.length es ∧ ElemsFrom s v es)
      (elemsOf F s v) (elemsOf F t (M.val v)) := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    obtain ⟨hfr, hnt⟩ := hok a rfl
    obtain ⟨ho, hg⟩ := hp.get
    cases ho with
    | cell c =>
      have h1 : s.obj? a = none := by unfold St.obj?; rw [hg]
      have h2 : t.obj? (M.a a) = none := by unfold St.obj?; rw [h.get hg hfr]; rfl
      simp only [elemsOf, Map.val, h1, h2]
      exact ESim.pure ⟨rfl, fun _ h => nomatch h⟩
    | obj o =>
      have h1 : s.obj? a = some o := obj?_iff.2 hg
      have h2 := h.obj? h1 hfr
      have hso := h.obj?_supp h1
      have hnt' := hnt o h1
      simp only [elemsOf, Map.val, h1, h2]
      obtain ⟨k, pr, ps, pv, ex⟩ := o
      cases k with
      | array es =>
        exact ESim.pure ⟨rfl, fun _ he => by cases he; exact ⟨hso.1, .inl ⟨a, _, rfl, h1, rfl⟩⟩⟩
      | typed k b off n => exact absurd rfl (hnt' k b off n)
      | _ => exact ESim.pure ⟨rfl, fun _ h => nomatch h⟩
  | str cs =>
    simp only [elemsOf, Map.val]
    refine ESim.pure ⟨?_, fun _ he => by
      cases he
      refine ⟨fun x hx => ?_, .inr ⟨cs, rfl, rfl⟩⟩
      simp only [List.mem_map] at hx
      obtain ⟨_, _, rfl⟩ := hx
      trivial⟩
    simp [Map.vals, Map.val]
  | _ => exact ESim.pure ⟨rfl, fun _ h => nomatch h⟩

/-- `relIdx` of a number concretizes it (on a literal: at once). -/
theorem relIdx_num (n : Nat) (v : NumV) (d : Nat) :
    relIdx n (.num v) d = Host.Ts.M.bind (numConc v) fun x => Host.Ts.M.pure (relIdxOf n x) := by
  cases v with
  | lit x =>
    show _ = Host.Ts.M.pure (relIdxOf n x)
    simp only [relIdx, relIdxOf]
    split <;> simp_all
  | ref i => rfl

/-- `relIdx`: both sides get the same index (a number reference is concretized alike). -/
theorem bi_relIdx {ν : Nat → F64} (hs : Srv M ν S C) (n : Nat) (v : Val) (d : Nat) :
    ESim M S C (fun i j => j = i) (relIdx n v d) (relIdx n (M.val v) d) := by
  cases v with
  | undef => exact ESim.pure rfl
  | num x =>
    show ESim M S C _ (relIdx n (.num x) d) (relIdx n (.num (M.nv x)) d)
    rw [relIdx_num, relIdx_num]
    refine ESim.bind (numConc_read hs x) ?_
    intro a b hab
    subst hab
    exact ESim.pure rfl
  | _ => exact ESim.fail _ _

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_arr_slice (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.arr .slice) data))
    (hF : FfiSim F FR okCall okBack) (hn : s.next + margin < Sim.bound)
    (hp : Present s aArrayProto) (hok : ElemsOK F K s S this) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  simp only [callNative, arrN, bi_arg_map]
  refine ESim.bind (elemsOf_sim h hF hthis hok) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | none => exact MSim.fail _ _
  | some es =>
    have hes := hsupp es rfl
    simp only [Option.map_some, bi_len_vals]
    refine ESim.bind (bi_relIdx h.srv _ _ _) ?_
    intro i i' hi
    rw [hi]
    refine ESim.bind (bi_relIdx h.srv _ _ _) ?_
    intro j j' hj
    rw [hj]
    have e : ((M.vals es).drop i).take (j - i) = M.vals ((es.drop i).take (j - i)) := by
      simp [Map.vals]
    rw [e]
    exact bi_allocObj_ret h (.array ((es.drop i).take (j - i))) aArrayProto [] hn' (h.intr _ (by decide)) hp
      (fun v hv => hes v (List.mem_of_mem_drop (List.mem_of_mem_take hv))) (fun _ hx => nomatch hx)

theorem step_arr_at (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.arr .at) data)) (hF : FfiSim F FR okCall okBack)
    (hok : ElemsOK F K s S this) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, arrN, bi_arg_map]
  refine ESim.bind (elemsOf_sim h hF hthis hok) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | none => exact MSim.fail _ _
  | some es =>
    have hes := hsupp es rfl
    simp only [Option.map_some, bi_len_vals]
    cases arg args 0 with
    | num x =>
      cases x with
      | lit x =>
        simp only [Map.val, Map.nv]
        cases F64.truncInt x with
        | none =>
          dsimp only
          rw [bi_nthD_map]
          exact bi_ret h _ (bi_nthD_supp 0 hes)
        | some i =>
          cases i with
          | ofNat i =>
            dsimp only
            rw [bi_nthD_map]
            exact bi_ret h _ (bi_nthD_supp i hes)
          | negSucc i =>
            dsimp only
            cases Nat.ble (i + 1) (len es)
            · exact bi_ret h .undef trivial
            · rw [bi_nthD_map]
              exact bi_ret h _ (bi_nthD_supp _ hes)
      | ref _ => exact MSim.fail _ _
    | undef =>
      rw [bi_nthD_map]
      exact bi_ret h _ (bi_nthD_supp 0 hes)
    | _ => exact MSim.fail _ _

end steps


/-! ## Strict equality and `includes` -/

/-- Strict equality needs nothing of a value that is neither a bigint nor a pointer. -/
theorem bi_strictOK_left {K : Ctx} {x y : Val} (hb : ∀ i, x ≠ .big i) (hp : ∀ m o, x ≠ .ptr m o) :
    StrictOK K x y :=
  ⟨fun i _ hx _ => absurd hx (hb i), fun _ o _ _ hx _ => absurd hx (hp _ o)⟩

theorem bi_indexOfL (hFR : FRLaws FR) {v : Val} : ∀ (es : List Val) (i : Nat) {M : Map} {S : SSrv} {C : CSrv},
    RelB F FR W stk M ν K s S t C → Supp.val (Present s) S.tab.length v →
    (∀ x ∈ es, Supp.val (Present s) S.tab.length x ∧ StrictOK K x v) →
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (indexOfL F s v es i) (indexOfL F t (M.val v) (M.vals es) i)
  | [], _, _, _, _, h, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv⟩
  | x :: xs, i, M, S, C, h, hv, hes => by
    have hx := hes x (List.mem_cons_self ..)
    have hxs : ∀ y ∈ xs, Supp.val (Present s) S.tab.length y ∧ StrictOK K y v :=
      fun y hy => hes y (List.mem_cons_of_mem _ hy)
    refine MSim.bind (strictEq_sim h hx.1 hv hx.2) ?_
    intro M' S' C' b b' hbb
    obtain ⟨hb, g⟩ := hbb
    rw [hb]
    cases b
    · have ih := bi_indexOfL hFR xs (i + 1) (h.grow hFR g) (bi_supp_grow g hv)
        (fun y hy => ⟨bi_supp_grow g (hxs y hy).1, (hxs y hy).2⟩)
      rw [g.bi_val hv, g.bi_vals (fun y hy => (hxs y hy).1)] at ih
      exact MSim.mono ih fun _ _ _ _ _ ⟨e, g'⟩ => ⟨e, g.trans g'⟩
    · exact MSim.pure ⟨rfl, g⟩

/-- `includes` compares the argument with each element. -/
def InclOK {S' : Type} (K : Ctx) (s : St S') (this v : Val) : Prop :=
  ∀ a o es, this = .obj a → s.obj? a = some o → o.kind = .array es → ∀ x ∈ es, StrictOK K x v

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_arr_includes (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.arr .includes) data)) (hok : PlainElemsOK K s this)
    (hincl : InclOK K s this (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, arrN, bi_arg_map]
  refine ESim.bind (h.bi_elemsOf hthis hok) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | none => exact MSim.fail _ _
  | some es =>
    obtain ⟨hes, hfrom⟩ := hsupp es rfl
    have heq : ∀ x ∈ es, StrictOK K x (arg args 0) := by
      rcases hfrom with ⟨a, o', rfl, ho', hk'⟩ | ⟨cs, rfl, rfl⟩
      · exact hincl a o' es rfl ho' hk'
      · intro x hx
        simp only [List.mem_map] at hx
        obtain ⟨_, _, rfl⟩ := hx
        exact bi_strictOK_left (fun _ h => nomatch h) (fun _ _ h => nomatch h)
    simp only [Option.map_some]
    refine bi_bind (bi_indexOfL hFR es 0 h (bi_arg_supp 0 hargs) fun x hx => ⟨hes x hx, heq x hx⟩)
      (fun _ _ _ _ _ hp => hp.2) ?_
    intro M' S' C' r r' hp
    obtain ⟨e, g⟩ := hp
    rw [e]
    exact bi_ret (h.grow hFR g) (.bool _) trivial

end steps


/-! ## `Map.prototype.get` -/

/-- SameValueZero reads alike: it tests `NaN` syntactically, so numbers compared with
each other are both literals, or one is a literal other than `NaN` (a referenced number
may have the literal image `NaN` where the source asks the server). -/
def SvzOK (K : Ctx) : Val → Val → Prop
  | .num (.lit _), .num (.lit _) => True
  | .num (.lit x), .num (.ref _) => x ≠ .nan
  | .num (.ref _), .num (.lit y) => y ≠ .nan
  | .num (.ref _), .num (.ref _) => False
  | x, y => StrictOK K x y

theorem bi_svz_strictOK {K : Ctx} {x y : Val} (h : SvzOK K x y) : StrictOK K x y := by
  cases x <;> cases y <;> first
    | exact h
    | exact bi_strictOK_left (fun _ h => nomatch h) (fun _ _ h => nomatch h)

theorem bi_svz_eq (s : St F.S) (x y : Val) (hn : ¬ (x = .num (.lit .nan) ∧ y = .num (.lit .nan))) :
    findEntry.sameValueZero F s x y = strictEq F s x y := by
  unfold findEntry.sameValueZero
  split
  · exact absurd ⟨rfl, rfl⟩ hn
  · rfl

theorem RelB.bi_svz (h : RelB F FR W stk M ν K s S t C) {x y : Val}
    (hx : Supp.val (Present s) S.tab.length x) (hy : Supp.val (Present s) S.tab.length y)
    (hok : SvzOK K x y) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (findEntry.sameValueZero F s x y) (findEntry.sameValueZero F t (M.val x) (M.val y)) := by
  by_cases hn : x = .num (.lit .nan) ∧ y = .num (.lit .nan)
  · obtain ⟨rfl, rfl⟩ := hn
    exact MSim.pure ⟨rfl, Grow.refl h.srv⟩
  · have ht : ¬ (M.val x = .num (.lit .nan) ∧ M.val y = .num (.lit .nan)) := by
      rintro ⟨h1, h2⟩
      cases x <;> cases y <;> simp only [Map.val, reduceCtorEq] at h1 h2
      rename_i a b
      cases a <;> cases b <;> simp only [Map.nv, Val.num.injEq, NumV.lit.injEq] at h1 h2
      · exact hn ⟨by rw [h1], by rw [h2]⟩
      · exact hok h1
      · exact hok h2
      · exact hok
    rw [bi_svz_eq s x y hn, bi_svz_eq t _ _ ht]
    exact strictEq_sim h hx hy (bi_svz_strictOK hok)

theorem bi_findEntry (hFR : FRLaws FR) {k : Val} :
    ∀ (es : List (Val × Val)) (i : Nat) {M : Map} {S : SSrv} {C : CSrv},
    RelB F FR W stk M ν K s S t C → Supp.val (Present s) S.tab.length k →
    Supp.pairs (Present s) S.tab.length es → (∀ p ∈ es, SvzOK K p.1 k) →
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (findEntry F s k es i) (findEntry F t (M.val k) (M.pairs es) i)
  | [], _, _, _, _, h, _, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv⟩
  | (j, v) :: es, i, M, S, C, h, hk, hes, hok => by
    have hj := hes (j, v) (List.mem_cons_self ..)
    have hes' : Supp.pairs (Present s) S.tab.length es := fun p hp => hes p (List.mem_cons_of_mem _ hp)
    have hok' : ∀ p ∈ es, SvzOK K p.1 k := fun p hp => hok p (List.mem_cons_of_mem _ hp)
    show MSim _ S C (Host.Ts.M.bind (findEntry.sameValueZero F s j k) fun b =>
        bif b then .pure (some i) else findEntry F s k es (i + 1))
      (Host.Ts.M.bind (findEntry.sameValueZero F t (M.val j) (M.val k)) fun b =>
        bif b then .pure (some i) else findEntry F t (M.val k) (M.pairs es) (i + 1))
    refine MSim.bind (h.bi_svz hj.1 hk (hok (j, v) (List.mem_cons_self ..))) ?_
    intro M' S' C' b b' hbb
    obtain ⟨hb, g⟩ := hbb
    rw [hb]
    cases b
    · have ih := bi_findEntry hFR es (i + 1) (h.grow hFR g) (bi_supp_grow g hk)
        (Supp.pairs_mono (fun _ h => h) g.len hes') hok'
      rw [g.bi_val hk, ← Map.pairs_agree g.ext.agree hes'] at ih
      exact MSim.mono ih fun _ _ _ _ _ ⟨e, g'⟩ => ⟨e, g.trans g'⟩
    · exact MSim.pure ⟨rfl, g⟩


theorem bi_large_map {α β : Type} (f : α → β) : ∀ (xs : List α) (n : Nat),
    KeyIndex.large (xs.map f) n = KeyIndex.large xs n
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: xs, n + 1 => bi_large_map f xs n

theorem bi_firstValue (M : Map) (code : Nat) : ∀ es : List (Val × Val),
    StringIndex.firstValue code (M.pairs es) = (StringIndex.firstValue code es).map M.val
  | [] => rfl
  | (k, v) :: es => by
    have ih := bi_firstValue M code es
    cases k with
    | str cs =>
      show (bif Nat.beq (pack cs) code then some (M.val v) else StringIndex.firstValue code (M.pairs es)) =
        (bif Nat.beq (pack cs) code then some v else StringIndex.firstValue code es).map M.val
      cases Nat.beq (pack cs) code
      · exact ih
      · rfl
    | _ => exact ih

theorem bi_firstValue_mem {code : Nat} : ∀ {es : List (Val × Val)} {v : Val},
    StringIndex.firstValue code es = some v → ∃ k, (k, v) ∈ es
  | [], _, h => nomatch h
  | (k, w) :: es, v, h => by
    cases k with
    | str cs =>
      change (bif Nat.beq (pack cs) code then some w else StringIndex.firstValue code es) = some v at h
      cases hb : Nat.beq (pack cs) code
      · rw [hb] at h
        obtain ⟨k, hk⟩ := bi_firstValue_mem h
        exact ⟨k, List.mem_cons_of_mem _ hk⟩
      · rw [hb] at h
        cases h
        exact ⟨_, List.mem_cons_self ..⟩
    | _ =>
      obtain ⟨k, hk⟩ := bi_firstValue_mem (es := es) h
      exact ⟨k, List.mem_cons_of_mem _ hk⟩

theorem RelB.bi_mapEntryValueLinear (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {k : Val}
    {es : List (Val × Val)} (hk : Supp.val (Present s) S.tab.length k)
    (hes : Supp.pairs (Present s) S.tab.length es) (hok : ∀ p ∈ es, SvzOK K p.1 k) :
    MSim (fun M' S' C' r r' => r' = M'.val r ∧ Supp.val (Present s) S'.tab.length r ∧
        Grow M ν S C M' S' C') S C
      (mapEntryValueLinear F s k es) (mapEntryValueLinear F t (M.val k) (M.pairs es)) := by
  unfold mapEntryValueLinear
  refine MSim.bind (bi_findEntry hFR es 0 h hk hes hok) ?_
  intro M' S' C' r r' hp
  obtain ⟨e, g⟩ := hp
  rw [e]
  cases r with
  | none => exact MSim.pure ⟨rfl, trivial, g⟩
  | some i =>
    dsimp only
    rw [show M.pairs es = es.map fun p => (M.val p.1, M.val p.2) from rfl, nth?_map]
    cases hn : nth? es i with
    | none => exact MSim.pure ⟨rfl, trivial, g⟩
    | some p =>
      have hp2 := (hes p (nth?_mem hn)).2
      exact MSim.pure ⟨(g.bi_val hp2).symm, bi_supp_grow g hp2, g⟩

theorem RelB.bi_mapEntryValue (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {k : Val}
    {es : List (Val × Val)} (hk : Supp.val (Present s) S.tab.length k)
    (hes : Supp.pairs (Present s) S.tab.length es) (hok : ∀ p ∈ es, SvzOK K p.1 k) :
    MSim (fun M' S' C' r r' => r' = M'.val r ∧ Supp.val (Present s) S'.tab.length r ∧
        Grow M ν S C M' S' C') S C
      (mapEntryValue F s k es) (mapEntryValue F t (M.val k) (M.pairs es)) := by
  cases k with
  | str cs =>
    unfold mapEntryValue
    simp only [Map.val]
    rw [show M.pairs es = es.map fun p => (M.val p.1, M.val p.2) from rfl, bi_large_map]
    cases KeyIndex.large es 16
    · exact h.bi_mapEntryValueLinear hFR hk hes hok
    · show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
      rw [StringIndex.lookup_buildValues, StringIndex.lookup_buildValues,
        show es.map (fun p => (M.val p.1, M.val p.2)) = M.pairs es from rfl, bi_firstValue]
      cases hv : StringIndex.firstValue (pack cs) es with
      | none => exact MSim.pure ⟨rfl, trivial, Grow.refl h.srv⟩
      | some v =>
        obtain ⟨_, hm⟩ := bi_firstValue_mem hv
        exact MSim.pure ⟨rfl, (hes _ hm).2, Grow.refl h.srv⟩
  | _ => exact h.bi_mapEntryValueLinear hFR hk hes hok

theorem RelB.bi_mapOf (h : RelB F FR W stk M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hn : ∀ a, v = .obj a → NoW K W s a) :
    mapOf F t (M.val v) = (mapOf F s v).map fun x => (M.a x.1, M.obj x.2.1, M.pairs x.2.2) := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    obtain ⟨ho, hg⟩ := hp.get
    cases ho with
    | cell c =>
      obtain ⟨c', hc'⟩ := h.cell_target hg
      have h1 : s.obj? a = none := by unfold St.obj?; rw [hg]
      have h2 : t.obj? (M.a a) = none := by unfold St.obj?; rw [hc']
      simp only [mapOf, Map.val, h1, h2, Option.map_none]
    | obj o =>
      have h1 : s.obj? a = some o := obj?_iff.2 hg
      cases hfr : K.fr a with
      | none =>
        have h2 := h.obj? h1 hfr
        simp only [mapOf, Map.val, h1, h2]
        cases hk : o.kind <;> simp [Map.obj, Map.kind, hk]
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', h2, xs, hk, rfl⟩ := h.obj?_framed h1 hfr (h.w_none (hn a rfl) hfr)
        simp only [mapOf, Map.val, h1, h2, hk, Option.map_none]
  | _ => rfl

theorem bi_mapOf_some {s : St F.S} {v : Val} {a : Nat} {o : Obj} {es : List (Val × Val)}
    (h : mapOf F s v = some (a, o, es)) : v = .obj a ∧ s.obj? a = some o ∧ o.kind = .map es := by
  unfold mapOf at h
  split at h
  · split at h
    · rename_i o' ho
      split at h
      · rename_i es' hk
        cases h
        exact ⟨rfl, ho, hk⟩
      · cases h
    · cases h
  · cases h

/-- `get` compares the key with each entry key by SameValueZero. -/
def MapGetOK {S' : Type} (K : Ctx) (W : Nat → Option WFrame) (s : St S') (this k : Val) : Prop :=
  (∀ a o es, this = .obj a → s.obj? a = some o → o.kind = .map es → ∀ p ∈ es, SvzOK K p.1 k) ∧
    ∀ a, this = .obj a → NoW K W s a

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_map_get (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .get) data)) (hn : s.next + margin < Sim.bound)
    (hp : Present s aTypeErrorProto)
    (hok : MapGetOK K W s this (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  simp only [callNative, mapN, mapN.withMap, bi_arg_map, h.bi_mapOf hthis hok.2]
  cases hm : mapOf F s this with
  | none => exact typeErr_sim h h.intr hn' hp _
  | some x =>
    obtain ⟨a, mo, es⟩ := x
    obtain ⟨rfl, hmo, hmk⟩ := bi_mapOf_some hm
    have hes : Supp.pairs (Present s) S.tab.length es := by
      have := (h.obj?_supp hmo).1
      rw [hmk] at this
      exact this
    simp only [Option.map_some]
    refine bi_bind (h.bi_mapEntryValue hFR (bi_arg_supp 0 hargs) hes (hok.1 a mo es rfl hmo hmk))
      (fun _ _ _ _ _ hp => hp.2.2) ?_
    intro M' S' C' r r' hp
    obtain ⟨e, hs, g⟩ := hp
    rw [e]
    exact bi_ret (h.grow hFR g) r hs

end steps


/-! ## `Map.prototype.get` on a by-key `Map`

A string key the source map holds reads, on a `mapKeys`-framed map, the image of the source's
value unless the key code is a ghost (`MapW`). -/

theorem mapEntryValue_str (s : St F.S) (cs : List Char) (es : List (Val × Val)) :
    mapEntryValue F s (.str cs) es = Host.Ts.M.pure ((StringIndex.firstValue (pack cs) es).getD .undef) := by
  rw [mapEntryValue_eq_linear]
  change mapEntryValueLinear F s (.str cs) es = _
  unfold mapEntryValueLinear
  rw [findEntry_string, ← StringIndex.firstCode_value]
  generalize StringIndex.firstCode (pack cs) es 0 = found
  cases found with
  | none => rfl
  | some index =>
    change Host.Ts.M.pure ((nth? es index).elim .undef Prod.snd) =
      Host.Ts.M.pure (((nth? es index).map Prod.snd).getD .undef)
    cases nth? es index <;> rfl

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

/-- `m.get(k)` with `m` a `mapKeys`-framed map holding the string key `k` (not a ghost). -/
theorem step_map_get_keys (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .get) data))
    {a : Nat} {mo : Obj} {es : List (Val × Val)} {gs : List Nat} {cs : List Char}
    (hthis : this = .obj a) (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (hfr : K.fr a ≠ none)
    (hw : W a = some (.mapKeys gs)) (harg : arg args 0 = .str cs)
    (hhas : (StringIndex.firstValue (pack cs) es).isSome = true) (hng : pack cs ∉ gs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hfr
  have hs := (SlotW.of_wide hp hw).1 (h.heap a _ (obj?_iff.1 hmo))
  rcases hy : t.heap.get (M.a a) with _ | ⟨_ | mo'⟩ <;> rw [hy] at hs
  · exact hs.elim
  · exact hs.elim
  obtain ⟨es0, es', hk0, rfl, hmw⟩ := hs
  rw [hmk] at hk0
  cases hk0
  have hes : Supp.pairs (Present s) S.tab.length es := by
    have := (h.obj?_supp hmo).1; rw [hmk] at this; exact this
  obtain ⟨v, hv⟩ := Option.isSome_iff_exists.1 hhas
  obtain ⟨v', hv', hor⟩ := hmw _ v hv
  have hvv : v' = M.val v := hor.resolve_left hng
  have hms : mapOf F s (.obj a) = some (a, mo, es) := by simp only [mapOf, hmo, hmk]
  have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, { M.obj mo with kind := .map es' }, es') := by
    simp only [mapOf, obj?_iff.2 hy]
  have hva : arg (M.vals args) 0 = .str cs := by rw [bi_arg_map, harg]; rfl
  simp only [callNative, mapN, mapN.withMap, Map.val, hms, hmt, hva, harg, mapEntryValue_str, hv, hv',
    Option.getD_some, M_bind_pure]
  rw [hvv]
  obtain ⟨k0, hk0⟩ := firstValue_mem hv
  exact bi_ret h v (hes _ hk0).2

end steps

/-! ## `Math.ceil`, `Math.min`, `Number`, `BigInt` -/

theorem bi_toNum {A : Nat → Prop} {n : Nat} {v : Val} (hv : Supp.val A n v) :
    ESim M S C (fun r r' => r' = r.map M.nv ∧ ∀ x, r = some x → Supp.nv A n x)
      (toNum v) (toNum (M.val v)) := by
  cases v with
  | num x => exact ESim.pure ⟨rfl, fun _ he => by cases he; exact hv⟩
  | bool b => exact ESim.pure ⟨by cases b <;> rfl, fun _ he => by cases he; cases b <;> trivial⟩
  | undef => exact ESim.pure ⟨rfl, fun _ he => by cases he; trivial⟩
  | null => exact ESim.pure ⟨rfl, fun _ he => by cases he; trivial⟩
  | str cs => exact ESim.pure ⟨rfl, fun _ he => by cases he; trivial⟩
  | _ => exact ESim.pure ⟨rfl, fun _ he => nomatch he⟩

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_math_ceil (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.math .ceil) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, mathN, mathN.un, bi_arg_map]
  refine ESim.bind (bi_toNum (bi_arg_supp 0 hargs)) ?_
  rintro r r' ⟨rfl, hs⟩
  cases r with
  | none => exact MSim.fail _ _
  | some x =>
    simp only [Option.map_some]
    refine bi_bind (numUn_supp_sim (Present s) h.srv .ceil x) (fun _ _ _ _ _ hp => hp.2.1) ?_
    intro M' S' C' r r' hp
    obtain ⟨e, g, hs'⟩ := hp
    rw [e]
    exact bi_ret (h.grow hFR g) (.num r) hs'

end steps

theorem bi_fold (hFR : FRLaws FR) (op : NBin) : ∀ (vs : List Val) (acc : NumV) {M : Map} {S : SSrv} {C : CSrv},
    RelB F FR W stk M ν K s S t C → Supp.nv (Present s) S.tab.length acc → Supp.vals (Present s) S.tab.length vs →
    MSim (StepPostB F FR W stk M ν K S C) S C (mathN.fold F s op acc vs) (mathN.fold F t op (M.nv acc) (M.vals vs))
  | [], acc, _, _, _, h, hacc, _ => bi_ret h (.num acc) hacc
  | v :: vs, acc, M, S, C, h, hacc, hvs => by
    have hv := hvs v (List.mem_cons_self ..)
    have hvs' : Supp.vals (Present s) S.tab.length vs := fun w hw => hvs w (List.mem_cons_of_mem _ hw)
    simp only [mathN.fold, Map.vals, List.map_cons]
    refine ESim.bind (bi_toNum hv) ?_
    rintro r r' ⟨rfl, hs⟩
    cases r with
    | none => exact MSim.fail _ _
    | some x =>
      simp only [Option.map_some]
      refine bi_bind (bi_numBin_sim (A := Present s) h.srv op acc x) (fun _ _ _ _ _ hp => hp.2.2) ?_
      intro M' S' C' r r' hp
      obtain ⟨e, hs', g⟩ := hp
      rw [e]
      have ih := bi_fold hFR op vs r (h.grow hFR g) hs' (bi_supps_grow g hvs')
      rw [g.bi_vals hvs'] at ih
      exact ih

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_math_min (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.math .min) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_fold hFR .min args (.lit (.inf false)) h trivial hargs

/-- `Math.pow(x, y)`: both sides compute it on the same literals (symbolic arguments make the source fail). -/
theorem step_math_pow (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.math .pow) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, mathN, bi_arg_map]
  refine ESim.bind (bi_toNum (bi_arg_supp 0 hargs)) ?_
  rintro r r' ⟨rfl, -⟩
  refine ESim.bind (bi_toNum (bi_arg_supp 1 hargs)) ?_
  rintro q q' ⟨rfl, -⟩
  rcases r with _ | ⟨a | _⟩ <;> rcases q with _ | ⟨b | _⟩ <;> try exact MSim.fail _ _
  simp only [Option.map_some, Map.nv]
  cases hp : F64.pow a b with
  | none => exact MSim.fail _ _
  | some x => exact bi_ret h (.num (.lit x)) trivial

/-- `Number(x)` of a bigint: the bigint is fixed by the map, so both sides convert the same value. -/
def NumberOK (K : Ctx) (args : List Val) : Prop := ∀ i, arg args 0 = .big i → BigFixed K.lo K.hi i

theorem step_num_number (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.num .number) data)) (hok : NumberOK K args) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, numN]
  cases args with
  | nil => exact bi_ret h (.num zeroN) trivial
  | cons v rest =>
    have hv : Supp.val (Present s) S.tab.length v := hargs v (List.mem_cons_self ..)
    simp only [Map.vals, List.map_cons]
    cases v with
    | big i =>
      simp only [Map.val, h.bigFixed i (hok i rfl)]
      exact bi_ret h (intV i) trivial
    | ptr m off => exact bi_ret h (.ptr m off) hv
    | _ =>
      dsimp only
      refine ESim.bind (bi_toNum hv) ?_
      rintro r r' ⟨rfl, hs⟩
      cases r with
      | none => exact MSim.fail _ _
      | some x => exact bi_ret h (.num x) (hs x rfl)

/-- `BigInt(x)`: the result is fixed by the map (pointers follow their memory). -/
def BigIntOK (K : Ctx) (_next : Nat) : Val → Prop
  | .ptr (.js _) _ => False
  | .ptr (.ext _) off => off < 2 ^ 24
  | .num (.lit x) => ∀ i, F64.toInt? x = some i → BigFixed K.lo K.hi i
  | .bool b => BigFixed K.lo K.hi (bif b then 1 else 0)
  | .str cs => ∀ i, parseBig cs = some i → BigFixed K.lo K.hi i
  | _ => True

theorem step_num_bigint (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.num .bigint) data))
    (hn : s.next + margin < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hpR : Present s aRangeErrorProto) (hpE : Present s aErrorProto)
    (hok : BigIntOK K s.next (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  have hv := bi_arg_supp 0 hargs
  simp only [callNative, numN, bi_arg_map]
  cases hx : arg args 0 with
  | big i => exact bi_ret h (.big i) trivial
  | ptr m off =>
    rw [hx] at hok hv
    cases m with
    | js b => exact hok.elim
    | ext r =>
      have e := h.bigExt r off hok
      have := bi_ret h (.big (ptrInt (.ext r) off)) trivial
      rw [show M.val (.big (ptrInt (.ext r) off)) = .big (M.big (ptrInt (.ext r) off)) from rfl, e] at this
      exact this
  | num x =>
    rw [hx] at hok
    cases x with
    | lit x =>
      simp only [Map.val, Map.nv]
      cases hi : F64.toInt? x with
      | none => exact rangeErr_sim h h.intr hn' hpR _
      | some i =>
        have := bi_ret h (.big i) trivial
        rw [show M.val (.big i) = .big (M.big i) from rfl, h.bigFixed i (hok i hi)] at this
        exact this
    | ref _ => exact MSim.fail _ _
  | bool b =>
    rw [hx] at hok
    have := bi_ret h (.big (bif b then 1 else 0)) trivial
    rw [show M.val (.big (bif b then 1 else 0)) = .big (M.big (bif b then 1 else 0)) from rfl,
      h.bigFixed _ hok] at this
    exact this
  | str cs =>
    rw [hx] at hok
    simp only [Map.val]
    cases hi : parseBig cs with
    | none => exact throwErr_sim h hn' hpE (h.intr _ (by decide)) _
    | some i =>
      have := bi_ret h (.big i) trivial
      rw [show M.val (.big i) = .big (M.big i) from rfl, h.bigFixed i (hok i hi)] at this
      exact this
  | _ => exact typeErr_sim h h.intr hn' hpT _

end steps



/-! ## Own properties: `Object.entries`, `Object.hasOwn` -/

/-- `dataProps.go` with the length of its result. -/
theorem bi_dataPropsGo (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {o : Obj}
    (hso : Supp.obj (Present s) S.tab.length o) : ∀ ks : List PKey,
    (∀ k ∈ ks, Supp.key (Present s) S.tab.length k ∧ TypedOK F K s S o k ∧ NsOK K W s o k) →
    ESim M S C (fun r r' => KVR M (Present s) S.tab.length r r' ∧ ∀ kvs, r = some kvs → kvs.length = ks.length)
      (dataProps.go F s o ks) (dataProps.go F t (M.obj o) (ks.map M.key))
  | [], _ => ReadPost.pure ⟨⟨rfl, fun kvs h x hx => by cases h; cases hx⟩, fun kvs h => by cases h; rfl⟩
  | k :: ks, hks => by
    obtain ⟨hk, hty, hns⟩ := hks k (List.mem_cons_self ..)
    simp only [dataProps.go, List.map_cons]
    refine MSim.bind (ownGet_sim h hF hso hk hty hns) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
    rw [hS, hC]
    rcases r with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩
    · exact ReadPost.pure ⟨⟨rfl, fun kvs h => by cases h⟩, fun kvs h => by cases h⟩
    · refine MSim.bind (bi_dataPropsGo h hF hso ks fun k hk => hks k (List.mem_cons_of_mem _ hk)) ?_
      rintro M'' S'' C'' q q' ⟨-, hS', hC', ⟨rfl, hq⟩, hl⟩
      rw [hS', hC']
      refine ReadPost.pure ⟨⟨?_, ?_⟩, ?_⟩
      · cases q <;> rfl
      · intro kvs hkvs x hx
        cases q with
        | none => cases hkvs
        | some l =>
          cases hkvs
          rcases List.mem_cons.1 hx with rfl | hx
          · exact ⟨hk, hsupp⟩
          · exact hq l rfl x hx
      · intro kvs hkvs
        cases q with
        | none => cases hkvs
        | some l =>
          cases hkvs
          simp only [List.length_cons, hl l rfl]
    · exact ReadPost.pure ⟨⟨rfl, fun kvs h => by cases h⟩, fun kvs h => by cases h⟩

theorem bi_keyVal (M : Map) (k : PKey) : keyVal (M.key k) = M.val (keyVal k) := by
  cases k <;> rfl

/-- The entry arrays of `Object.entries`: one fresh array per entry. -/
theorem bi_mk : ∀ (kvs : List (PKey × Val)) {s t : St F.S}, RelB F FR W stk M ν K s S t C →
    Present s aArrayProto → s.next + kvs.length < Sim.bound →
    (∀ x ∈ kvs, Supp.key (Present s) S.tab.length x.1 ∧ Supp.val (Present s) S.tab.length x.2) →
    RelB F FR W stk M ν K (objN.mk F s kvs).2 S (objN.mk F t (M.kvs kvs)).2 C ∧
      (objN.mk F t (M.kvs kvs)).1 = M.vals (objN.mk F s kvs).1 ∧
      Supp.vals (Present (objN.mk F s kvs).2) S.tab.length (objN.mk F s kvs).1 ∧
      (objN.mk F s kvs).2.next = s.next + kvs.length ∧
      (∀ a, Present s a → Present (objN.mk F s kvs).2 a)
  | [], _, _, h, _, _, _ => by
    refine ⟨h, rfl, fun x hx => ?_, rfl, fun _ h => h⟩
    change x ∈ ([] : List Val) at hx
    cases hx
  | (k, v) :: r, s, t, h, hp, hn, hkvs => by
    obtain ⟨hk, hv⟩ := hkvs (k, v) (List.mem_cons_self ..)
    have hr : ∀ x ∈ r, Supp.key (Present s) S.tab.length x.1 ∧ Supp.val (Present s) S.tab.length x.2 :=
      fun x hx => hkvs x (List.mem_cons_of_mem _ hx)
    have hn1 : s.next < Sim.bound := by simp only [List.length_cons] at hn; omega
    have h64 := h.bi_s64 hn1
    let ar : Kind := .array [keyVal k, v]
    have hP : ∀ a, Present s a → Present (s.allocObj ar (.obj aArrayProto) []).2 a :=
      fun _ ha => Present.alloc _ h64 ha
    have hkv : Supp.val (Present s) S.tab.length (keyVal k) := by cases k <;> exact hk
    have hsk : Supp.kind (Present s) S.tab.length ar := fun x hx => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
      rcases hx with rfl | rfl
      · exact hkv
      · exact hv
    obtain ⟨ea, h1⟩ := h.allocObj ar (.obj aArrayProto) [] hn1 (Supp.kind_mono hP (Nat.le_refl _) hsk)
      (hP _ hp) (fun _ hx => nomatch hx)
    have et : newArray t [keyVal (M.key k), M.val v] =
        t.allocObj (M.kind ar) (M.val (.obj aArrayProto)) (M.props []) := by
      simp only [newArray, ar, Map.kind, Map.vals, List.map_cons, List.map_nil, bi_keyVal, Map.props]
      rw [show M.val (.obj aArrayProto) = .obj aArrayProto by
        show Val.obj (M.a aArrayProto) = _; rw [h.intr _ (by decide)]]
    have es : newArray s [keyVal k, v] = s.allocObj ar (.obj aArrayProto) [] := rfl
    have hn2 : (s.allocObj ar (.obj aArrayProto) []).2.next + r.length < Sim.bound := by
      show s.next + 1 + r.length < Sim.bound
      simp only [List.length_cons] at hn; omega
    obtain ⟨ih1, ih2, ih3, ih4, ih5⟩ := bi_mk r h1 (hP _ hp) hn2
      (fun x hx => ⟨Supp.key_mono hP (Nat.le_refl _) (hr x hx).1, Supp.val_mono hP (Nat.le_refl _) (hr x hx).2⟩)
    show RelB F FR W stk M ν K (objN.mk F (newArray s [keyVal k, v]).2 r).2 S
        (objN.mk F (newArray t [keyVal (M.key k), M.val v]).2 (M.kvs r)).2 C ∧
      (Val.obj (newArray t [keyVal (M.key k), M.val v]).1 ::
          (objN.mk F (newArray t [keyVal (M.key k), M.val v]).2 (M.kvs r)).1) =
        M.vals (.obj (newArray s [keyVal k, v]).1 :: (objN.mk F (newArray s [keyVal k, v]).2 r).1) ∧
      Supp.vals (Present (objN.mk F (newArray s [keyVal k, v]).2 r).2) S.tab.length
        (.obj (newArray s [keyVal k, v]).1 :: (objN.mk F (newArray s [keyVal k, v]).2 r).1) ∧
      (objN.mk F (newArray s [keyVal k, v]).2 r).2.next = s.next + (r.length + 1) ∧
      (∀ a, Present s a → Present (objN.mk F (newArray s [keyVal k, v]).2 r).2 a)
    rw [et, es, ea]
    refine ⟨ih1, ?_, ?_, ?_, fun a ha => ih5 a (hP a ha)⟩
    · show Val.obj (M.a _) :: _ = Val.obj (M.a _) :: M.vals _
      rw [ih2]
    · intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact ih5 _ (Present.alloc_next s _ h64)
      · exact ih3 x hx
    · rw [ih4]
      show s.next + 1 + r.length = _
      omega

/-- `Object.entries(o)`: `o` unframed, its typed-array element reads `TypedOK`, and at
most `2 ^ 20` own keys (one entry array is allocated per key). -/
def EntriesOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (v : Val) : Prop :=
  ∀ a, v = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o →
    (∀ k ∈ ownKeys F s o, TypedOK F K s S o k ∧ NsOK K W s o k) ∧ (ownKeys F s o).length ≤ 2 ^ 20

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_obj_entries (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.obj .entries) data)) (hn : s.next + margin < Sim.bound)
    (hpA : Present s aArrayProto) (hpT : Present s aTypeErrorProto) (hok : EntriesOK F K W s S (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn' := bi_margin hn
  have hv := bi_arg_supp 0 hargs
  simp only [callNative, objN, bi_arg_map]
  cases hx : arg args 0 with
  | obj a =>
    rw [hx] at hok hv
    obtain ⟨hfr, hok'⟩ := hok a rfl
    simp only [Map.val]
    cases hoa : s.obj? a with
    | none => exact MSim.fail _ _
    | some ob =>
      rw [h.obj? hoa hfr]
      obtain ⟨hty, hlen⟩ := hok' ob hoa
      have hso := h.obj?_supp hoa
      dsimp only
      have hd := bi_dataPropsGo h hF hso (ownKeys F s ob)
        (fun k hk => ⟨ownKeys_supp hso.2.2.1 k hk, (hty k hk).1, (hty k hk).2⟩)
      rw [← ownKeys_map (s := s) (t := t)] at hd
      refine ESim.bind hd ?_
      rintro r r' ⟨⟨rfl, hsupp⟩, hl⟩
      cases r with
      | none => exact MSim.fail _ _
      | some kvs =>
        have hkl := hl kvs rfl
        simp only [Option.map_some]
        have hb : s.next + kvs.length < Sim.bound := by
          have : (2 : Nat) ^ 20 + 1 < margin := by decide
          omega
        obtain ⟨hr, e, hsp, hnext, hpres⟩ := bi_mk kvs h hpA hb (hsupp kvs rfl)
        rcases hP : objN.mk F s kvs with ⟨ps, s1⟩
        rcases hQ : objN.mk F t (M.kvs kvs) with ⟨ps', t1⟩
        rw [hP, hQ] at hr e
        rw [hP] at hsp hnext hpres
        simp only at e hr hsp hnext
        subst e
        dsimp only
        have hb1 : s1.next < Sim.bound := by
          have : (2 : Nat) ^ 20 + 1 < margin := by decide
          omega
        exact bi_allocObj_ret hr (.array ps) aArrayProto [] hb1 (h.intr _ (by decide)) (hpres _ hpA) hsp
          (fun _ hx => nomatch hx)
  | _ => exact typeErr_sim h h.intr hn' hpT _

end steps

theorem bi_primStr (h : RelB F FR W stk M ν K s S t C) {v : Val} (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (primStr v) (primStr (M.val v)) := by
  cases v with
  | num x =>
    simp only [primStr, Map.val]
    refine MSim.bind (numConc_sim h.srv x) ?_
    intro M' S' C' f f' hp
    obtain ⟨e, g⟩ := hp
    rw [e]
    cases F64.toStr f with
    | none => exact MSim.fail _ _
    | some cs => exact MSim.pure ⟨rfl, g⟩
  | big i =>
    show MSim _ S C (Host.Ts.M.pure (some (bigStr i))) (Host.Ts.M.pure (some (bigStr (M.big i))))
    rw [h.bigFixed i (hb i rfl)]
    exact MSim.pure ⟨rfl, Grow.refl h.srv⟩
  | ptr m off => cases m <;> exact MSim.pure ⟨rfl, Grow.refl h.srv⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl h.srv⟩

theorem bi_toKey (h : RelB F FR W stk M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    MSim (fun M' S' C' r r' => r' = r.map M.key ∧ (∀ k, r = some k → Supp.key (Present s) S.tab.length k) ∧
        Grow M ν S C M' S' C') S C (toKey v) (toKey (M.val v)) := by
  have gen : (∀ i, v ≠ .sym i) →
      MSim (fun M' S' C' r r' => r' = r.map M.key ∧ (∀ k, r = some k → Supp.key (Present s) S.tab.length k) ∧
        Grow M ν S C M' S' C') S C
        (Host.Ts.M.bind (primStr v) fun o => Host.Ts.M.pure (o.map PKey.str))
        (Host.Ts.M.bind (primStr (M.val v)) fun o => Host.Ts.M.pure (o.map PKey.str)) := fun _ => by
    refine MSim.bind (bi_primStr h hb) ?_
    intro M' S' C' r r' hp
    obtain ⟨e, g⟩ := hp
    rw [e]
    refine MSim.pure ⟨by cases r <;> rfl, fun k hk => ?_, g⟩
    cases r with
    | none => cases hk
    | some cs => cases hk; trivial
  cases v with
  | sym i => exact MSim.pure ⟨rfl, fun k hk => by cases hk; exact hv, Grow.refl h.srv⟩
  | ptr m off => cases m <;> exact gen (fun _ h => nomatch h)
  | _ => exact gen (fun _ h => nomatch h)

/-- `Object.hasOwn(o, k)`: `o` unframed and not a typed array; a bigint key is fixed by the map. -/
def HasOwnOK {S' : Type} (K : Ctx) (W : Nat → Option WFrame) (s : St S') (o k : Val) : Prop :=
  (∀ a, o = .obj a → K.fr a = none ∧ ∀ ob, s.obj? a = some ob → (∀ kk b off n, ob.kind ≠ .typed kk b off n) ∧
    ∀ ex, ob.kind = .ns ex → ∀ p ∈ ex, W p.2 = none ∨ K.fr p.2 = none) ∧
    ∀ i, k = .big i → BigFixed K.lo K.hi i

section steps
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_obj_hasOwn (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.obj .hasOwn) data)) (hok : HasOwnOK K W s (arg args 0) (arg args 1)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hv := bi_arg_supp 0 hargs
  have hkv := bi_arg_supp 1 hargs
  simp only [callNative, objN, objN.hasOwn, bi_arg_map]
  cases hx : arg args 0 with
  | obj a =>
    rw [hx] at hok hv
    obtain ⟨hfr, hnt⟩ := hok.1 a rfl
    simp only [Map.val]
    cases hoa : s.obj? a with
    | none => exact MSim.fail _ _
    | some ob =>
      rw [h.obj? hoa hfr]
      have hso := h.obj?_supp hoa
      dsimp only
      refine bi_bind (bi_toKey h hkv hok.2) (fun _ _ _ _ _ hp => hp.2.2) ?_
      intro M' S' C' r r' hp
      obtain ⟨e, hks, g⟩ := hp
      rw [e]
      cases r with
      | none => exact MSim.fail _ _
      | some key =>
        have h' := h.grow hFR g
        have hk' := Supp.key_mono (fun _ h => h) g.len (hks key rfl)
        have hso' := Supp.obj_mono (fun _ h => h) g.len hso
        have hown := ownGet_sim h' hF hso' hk' (fun kk b off n i hk _ => absurd hk ((hnt ob hoa).1 kk b off n))
          (fun ex nm c hex _ hc => by
            obtain ⟨m, hm⟩ := findExport_mem hc
            exact .of_or ((hnt ob hoa).2 ex hex _ hm))
        rw [← Map.obj_agree g.ext.agree hso, ← Map.key_agree g.ext.agree (hks key rfl)] at hown
        simp only [Option.map_some]
        refine ESim.bind hown ?_
        rintro p p' ⟨rfl, -⟩
        cases p <;> exact bi_ret h' (.bool _) trivial
  | _ => exact MSim.fail _ _

end steps

end
end Host.Ts.Sim
