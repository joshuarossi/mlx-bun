import host.sim.steps.Async
import host.sim.steps.Builtins
import host.sim.steps.Buf
namespace Host.Ts.Sim

/-! # Steps under wide frames, iterators, `Set`s and `new Promise`

* `yield*` under frames: `step_ret_ystarAResultW`, `step_ret_ystarAItW`, `step_ret_yield_delegateW` are
  `step_ret_ystarAResult`, `step_ret_ystarAIt`, `step_ret_yield_delegate` (`steps/Async.lean`) with the frame-free premise
  replaced by `LookupNoW` at the object they read (the inner result, the iterator).
* `%ArrayIteratorPrototype%.next` over an array snapshot in value mode (`step_iter_next`), the
  iterator's `[Symbol.iterator]` (`step_iter_self`).
* `Set.prototype.values` (`step_set_values`) and `has` (`step_set_has`); `new Set(xs)` from an
  array whose elements compare alike (`step_set_ctor`).
* `new Promise(executor)` (`step_construct_promise`); `Math.max` (`step_math_max`). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-! ## Local copies of `steps/Async.lean`'s private helpers -/

private theorem topRetE (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = f :: fs) :
    step F s = retStep F { s with stack := fs } f v ∧
    step F t = retStep F { t with stack := fs.map M.frame ++ stk } (M.frame f) (M.val v) ∧
    RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C ∧
    Supp.val (Present s) S.tab.length v ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepRet, hs], by simp only [step, htc, stepRet, hts], hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

private theorem fr_of_orE (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : W a = none ∨ K.fr a = none) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, xs, hk', _⟩ := h.obj?_framed ho hfr (h.w_none (.of_or hw) hfr)
    exact absurd hk' (hk _)

private theorem margin_takeE {n : Nat} (hn : n + margin < Sim.bound) (k : Nat) (hk : k ≤ 2 ^ 29) :
    n + k < Sim.bound := by
  unfold margin at hn; omega

private theorem dataOf_ownE (F : Ffi) {s : St F.S} {a : Nat} {o : Obj} {k : PKey} {dv : Val} {w e : Bool}
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hp : findProp k o.props = some (.data dv w e)) :
    dataOf F s (.obj a) k = Host.Ts.M.pure (some dv) := by
  unfold dataOf lookup
  rw [show (16 : Nat) = 15 + 1 from rfl]
  simp only [getChain, ho, ownGet, hk, hp]
  rfl

private theorem sim_truthyE {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (v : Val)
    (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

private theorem pair_etaE {α β : Type} (p : α × β) : p = (p.1, p.2) := rfl

/-- The address `LookupNoW` reads first carries no frame of `W` or is unframed. -/
theorem LookupNoW.head {F' : Ffi} {K : Ctx} {W : Nat → Option WFrame} {s : St F'.S} {a : Nat} {o : Obj}
    (h : LookupNoW F' K W s (.obj a)) (ho : s.obj? a = some o) : W a = none ∨ K.fr a = none :=
  (h o ho).1

/-! ## `yield*` in an async generator under frames -/

/-- `step_ret_ystarAResult` where no frame of `W` matters along the result's chain. -/
theorem step_ret_ystarAResultW (h : RelB F FR W stk M ν K s S t C) {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    {a : Nat} {o : Obj} {dv it nx : Val} {w e : Bool} {fs : List Frame}
    (hc : s.ctl = .ret (.obj a)) (hs : s.stack = .k (.ystarAResult it nx) :: fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hd : findProp kDone o.props = some (.data dv w e))
    (hbig : ∀ i, dv = .big i → BigFixed K.lo K.hi i) (hn : s.next + margin < Sim.bound)
    (hnw : LookupNoW F K W s (.obj a)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := topRetE h hc hs
  rw [e1, e2]
  have hfr : K.fr a = none := fr_of_orE h ho (by intro es he; rw [hk] at he; cases he) (hnw.head ho)
  have ho' : t.obj? (M.a a) = some (M.obj o) := h.obj? ho hfr
  have hso := h.obj?_supp ho
  have hd' : findProp kDone (M.obj o).props = some (.data (M.val dv) w e) := by
    show findProp (M.key kDone) (M.props o.props) = _
    rw [findProp_map (k := kDone) h.inj (show Supp.key (Present s) S.tab.length kDone from trivial) hso.2.2.1, hd]
    rfl
  have hk' : (M.obj o).kind = .ordinary := by show M.kind o.kind = _; rw [hk]; rfl
  show MSim _ S C (retK F { s with stack := fs } (.ystarAResult it nx) (.obj a))
    (retK F { t with stack := fs.map M.frame ++ stk } (.ystarAResult (M.val it) (M.val nx)) (.obj (M.a a)))
  simp only [retK]
  rw [dataOf_ownE F (s := { s with stack := fs }) ho hk hd,
    dataOf_ownE F (s := { t with stack := fs.map M.frame ++ stk }) ho' hk' hd']
  show MSim _ S C (Host.Ts.M.bind (truthy dv) _) (Host.Ts.M.bind (truthy (M.val dv)) _)
  refine MSim.bind (sim_truthyE h.srv dv fun i hi => h.bigFixed i (hbig i hi)) ?_
  rintro M' S' C' r r' ⟨rfl, hg⟩
  have h2 := h1.grow hFR hg
  have hI' : ∀ a, a < aFirst → M'.a a = a := h2.intr
  have hva : Val.obj (M.a a) = M'.val (.obj a) := by show _ = Val.obj (M'.a a); rw [hg.ext.a]
  rw [hva]
  refine MSim.bind (dataOf_sim h2 hF hI' (recv := .obj a) (k := kValue) hv trivial
    (LookupOK.of_noW (by decide) (by decide) (LookupNoW.congr (fun _ => rfl) hnw))) ?_
  rintro M'' S'' C'' x x' ⟨-, hS, hC, hxx, hx⟩
  rw [hS, hC, hxx]
  have hit : M'.val it = M.val it := Map.val_agree hg.ext.agree' hf.1
  have hnx : M'.val nx = M.val nx := Map.val_agree hg.ext.agree' hf.2
  rw [← hit, ← hnx]
  cases x with
  | none => exact MSim.fail _ _
  | some x =>
    have hxs : Supp.val (Present s) S'.tab.length x := hx x rfl
    cases r'
    · have hy := sim_agenYield (h2.push (.k (.ystarAResume it nx)) (Supp.frame_mono (fun _ h => h) hg.len hf))
        hpo hfp (margin_takeE hn _ (by decide)) hxs
      exact StepPost.after hg hy
    · exact StepPost.after hg (MSim.pure ⟨Grow.refl h2.srv, h2.ret x hxs⟩)

/-- `step_ret_ystarAIt` where no frame of `W` matters along the iterator's chain. -/
theorem step_ret_ystarAItW (h : RelB F FR W stk M ν K s S t C) {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (hF : FfiSim F FR okCall okBack) {v : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k .ystarAIt :: fs) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := topRetE h hc hs
  rw [e1, e2]
  show MSim _ S C (retK F { s with stack := fs } .ystarAIt v) (retK F { t with stack := fs.map M.frame ++ stk } .ystarAIt (M.val v))
  simp only [retK]
  refine MSim.bind (dataOf_sim h1 hF h1.intr hv (k := kNext) trivial
    (LookupOK.of_noW (by decide) (by decide) (LookupNoW.congr (fun _ => rfl) hnw))) ?_
  rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
  rw [hS, hC, hxx]
  cases x with
  | none => exact MSim.fail _ _
  | some nx =>
    exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.k (.ystarAResult v nx)) ⟨hv, hx nx rfl⟩).push (.k .await) trivial).go
      (.call nx v [.undef]) ⟨hx nx rfl, hv, fun y hy => by rw [List.mem_singleton.1 hy]; trivial⟩⟩


/-! ## `yield*` start under frames

The helpers below duplicate private declarations of `steps/Async.lean` (named with an `E` suffix so they
cannot clash); replace them by the originals, made public, the next time `Async.lean` is rebuilt anyway. -/

/-- Duplicates `St.obj?_none_of_cell` (`steps/Async.lean`). -/
private theorem obj?_none_of_cellE {S' : Type} {s : St S'} {a : Nat} {v : Option Val}
    (hg : s.heap.get a = some (.cell v)) : s.obj? a = none := by
  unfold St.obj?; rw [hg]

/-- Duplicates `RelB.objCases` (`steps/Async.lean`). -/
private theorem objCasesE (h : RelB F FR W stk M ν K s S t C) {a : Nat} (hp : Present s a) :
    (s.obj? a = none ∧ t.obj? (M.a a) = none) ∨
    (∃ o, s.obj? a = some o ∧ K.fr a = none ∧ t.obj? (M.a a) = some (M.obj o)) ∨
    (∃ o o' xs ys, s.obj? a = some o ∧ t.obj? (M.a a) = some o' ∧ o.kind = .array xs ∧
      o'.kind = .array ys) ∨
    (∃ o o', s.obj? a = some o ∧ t.obj? (M.a a) = some o' ∧ Wideable o.kind ∧ WTarget o'.kind ∧ W a ≠ none) := by
  obtain ⟨ho, hg⟩ := hp.get
  cases ho with
  | cell v =>
    obtain ⟨v', hv'⟩ := h.cell_target hg
    exact .inl ⟨obj?_none_of_cellE hg, obj?_none_of_cellE hv'⟩
  | obj o =>
    cases hfr : K.fr a with
    | none => exact .inr (.inl ⟨o, obj?_iff.2 hg, rfl, h.obj? (obj?_iff.2 hg) hfr⟩)
    | some p =>
      cases hw : W a with
      | none =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', ht, xs, hk, rfl⟩ := h.obj?_framed (obj?_iff.2 hg) hfr hw
        exact .inr (.inr (.inl ⟨o, _, _, _, obj?_iff.2 hg, ht, hk, rfl⟩))
      | some w =>
        obtain ⟨o', ht, hk, hk'⟩ := h.wide_obj hg hfr hw
        exact .inr (.inr (.inr ⟨o, o', obj?_iff.2 hg, obj?_iff.2 ht, hk, hk', by simp⟩))

/-- Duplicates `Wideable.not_gen` (`steps/Async.lean`). -/
private theorem Wideable.not_genE {k : Kind} (hk : Wideable k) (st : GenState) (b : Bool) (q : List (Nat × Comp)) :
    k ≠ .gen st b q := by
  intro he; rw [he] at hk; exact hk

/-- Duplicates `WTarget.not_gen` (`steps/Async.lean`). -/
private theorem WTarget.not_genE {k : Kind} (hk : WTarget k) (st : GenState) (b : Bool) (q : List (Nat × Comp)) :
    k ≠ .gen st b q := by
  rcases hk with hk | ⟨bs, rfl⟩ | ⟨kk, b', off, n, rfl⟩
  · exact Wideable.not_genE hk st b q
  · intro he; cases he
  · intro he; cases he

/-- Duplicates `genOf_none_of` (`steps/Async.lean`). -/
private theorem genOf_none_ofE {S' : Type} {s : St S'} {g : Nat} {o : Obj} (h1 : s.obj? g = some o)
    (hk : ∀ st b q, o.kind ≠ .gen st b q) : genOf s g = none := by
  unfold genOf; rw [h1]
  cases hko : o.kind <;> simp_all

/-- Duplicates `RelB.genOf_map` (`steps/Async.lean`). -/
private theorem genOf_mapE (h : RelB F FR W stk M ν K s S t C) {g : Nat} (hp : Present s g) :
    genOf t (M.a g) = (genOf s g).map fun x => (M.gen x.1, x.2) := by
  rcases objCasesE h hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  · simp only [Host.Ts.genOf, h1, h2, Option.map_none]
  · simp only [Host.Ts.genOf, h1, h2]
    cases hk : o.kind <;> simp [Map.obj, Map.kind, hk]
  · simp only [Host.Ts.genOf, h1, h2, k1, k2, Option.map_none]
  · rw [genOf_none_ofE h1 w1.not_genE, genOf_none_ofE h2 w2.not_genE]; rfl

/-- Duplicates `nearestGen_map` (`steps/Async.lean`). -/
private theorem nearestGen_mapE (M : Map) : ∀ fs : List Frame,
    nearestGen (fs.map M.frame) = (nearestGen fs).map fun x => (M.a x.1, x.2)
  | [] => rfl
  | f :: fs => by
    cases f with
    | k f =>
      cases f with
      | fn b => cases b <;> rfl
      | _ => simp only [List.map_cons, Map.frame, Map.fnF, nearestGen]; exact nearestGen_mapE M fs
    | _ => simp only [List.map_cons, Map.frame, nearestGen]; exact nearestGen_mapE M fs

/-- Duplicates `nearestGen_mem` (`steps/Async.lean`). -/
private theorem nearestGen_memE : ∀ {fs : List Frame} {g : Nat} {b : Bool},
    nearestGen fs = some (g, b) → Frame.k (.fn (.gen g)) ∈ fs
  | [], _, _, h => by cases h
  | f :: fs, g, b, h => by
    cases f with
    | k f =>
      cases f with
      | fn bd =>
        cases bd with
        | gen g' =>
          simp only [nearestGen, Option.some.injEq, Prod.mk.injEq] at h
          rw [h.1]; exact List.mem_cons_self ..
        | _ => cases h
      | _ => exact List.mem_cons_of_mem _ (nearestGen_memE (fs := fs) (by simpa [nearestGen] using h))
    | _ => exact List.mem_cons_of_mem _ (nearestGen_memE (fs := fs) (by simpa [nearestGen] using h))

/-- `isIndexable_map` (`steps/Async.lean`) where no frame of `W` matters at the operand. -/
private theorem isIndexable_mapW (h : RelB F FR W stk M ν K s S t C) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (hnw : LookupNoW F K W s v) :
    isIndexable F t (M.val v) = isIndexable F s v := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    rcases objCasesE h hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
      ⟨o, o', h1, h2, -, -, hwn⟩
    · simp only [Map.val, isIndexable, h1, h2]
    · obtain ⟨k, pr, ps, pv, ex⟩ := o
      simp only [Map.val, isIndexable, h1, h2, Map.obj]
      cases k <;> rfl
    · obtain ⟨k, pr, ps, pv, ex⟩ := o
      obtain ⟨k', pr', ps', pv', ex'⟩ := o'
      cases k1; cases k2
      simp only [Map.val, isIndexable, h1, h2]
    · rcases hnw.head h1 with hw | hfr
      · exact absurd hw hwn
      · have h2' := h.obj? h1 hfr
        obtain ⟨k, pr, ps, pv, ex⟩ := o
        simp only [Map.val, isIndexable, h1, h2', Map.obj]
        cases k <;> rfl
  | _ => rfl

/-- `step_ret_yield_delegate` (`steps/Async.lean`) where no frame of `W` matters along the operand's
chain (`LookupNoW`). -/
theorem step_ret_yield_delegateW (h : RelB F FR W stk M ν K s S t C) {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (hF : FfiSim F FR okCall okBack) (htp : Present s aTypeErrorProto)
    (hai : Present s aArrayIterProto)
    {v : Val} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.yield true) :: fs)
    (hn : s.next + margin < Sim.bound) (hnw : LookupNoW F K W s v) (hfn : stk = [] ∨ fnB fs = true) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := topRetE h hc hs
  rw [e1, e2]
  have hs0 := margin_takeE hn 0 (by decide)
  have hnw1 : LookupNoW F K W { s with stack := fs } v := LookupNoW.congr (fun _ => rfl) hnw
  show MSim _ S C (retK F { s with stack := fs } (.yield true) v) (retK F { t with stack := fs.map M.frame ++ stk } (.yield true) (M.val v))
  simp only [retK, Bool.cond_true]
  have hng : nearestGen (fs.map M.frame ++ stk) = nearestGen (fs.map M.frame) := by
    rcases hfn with rfl | hfn
    · rw [List.append_nil]
    · exact nearestGen_append_fn stk (by rw [fnB_map]; exact hfn)
  rw [hng, nearestGen_mapE]
  have sync : MSim (StepPostB F FR W stk M ν K S C) S C
      (bif isIndexable F { s with stack := fs } v then
        (Host.Ts.M.pure ((({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).2.push (.k .ystarIt)).ret
          (.obj ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).1)))
       else startIter F ({ s with stack := fs }.push (.k .ystarIt)) v)
      (bif isIndexable F { t with stack := fs.map M.frame ++ stk } (M.val v) then
        (Host.Ts.M.pure ((({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).2.push
          (.k .ystarIt)).ret (.obj ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0)
            (.obj aArrayIterProto) []).1)))
       else startIter F ({ t with stack := fs.map M.frame ++ stk }.push (.k .ystarIt)) (M.val v)) := by
    rw [isIndexable_mapW h1 hv hnw1]
    cases isIndexable F { s with stack := fs } v
    · exact getV_sim ((h1.push (.k .ystarIt) trivial).push (.c (.method v [] [] false)) ⟨hv, fun _ hx => nomatch hx⟩)
        hF h1.intr hs0 htp hv (k := .sym symIterator) (fun h => absurd h (by decide))
        (LookupOK.of_noW (by decide) (by decide) (LookupNoW.congr (fun _ => rfl) hnw))
    · obtain ⟨ea, -, hp, u⟩ := upd_allocObj h1 (k := .iter v 0 0) (proto := .obj aArrayIterProto) (props := [])
        hs0 hv hai (fun _ hx => nomatch hx)
      have ep : M.val (.obj aArrayIterProto) = .obj aArrayIterProto := by
        show Val.obj (M.a aArrayIterProto) = _; rw [h.intr _ (by decide)]
      rw [ep] at ea u
      have ea' : ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).1 =
          M.a ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).1 := ea
      have u' : Upd F FR W stk M ν K S C { s with stack := fs } ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).2
          ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).2 1 := u
      rw [ea']
      exact MSim.pure ⟨Grow.refl h.srv, (u'.rel.push (.k .ystarIt) trivial).ret (.obj _) hp⟩
  cases hng : nearestGen fs with
  | none => exact sync
  | some x =>
    obtain ⟨g, b⟩ := x
    have hg : Present s g := h1.stackSupp _ (nearestGen_memE hng)
    simp only [Option.map]
    rw [genOf_mapE h1 hg]
    cases hgo : genOf { s with stack := fs } g with
    | none => exact sync
    | some y =>
      obtain ⟨st, a⟩ := y
      cases a with
      | false => exact sync
      | true =>
        simp only [Option.map, Option.elim, Bool.cond_true]
        cases v with
        | obj o =>
          exact getV_sim ((h1.push (.k .ystarAIt) trivial).push (.c (.method (.obj o) [] [] false))
            ⟨hv, fun _ hx => nomatch hx⟩) hF h1.intr hs0 htp hv (k := .sym symAsyncIterator)
            (fun h => absurd h (by decide)) (LookupOK.of_noW (by decide) (by decide) (LookupNoW.congr (fun _ => rfl) hnw))
        | _ => exact typeErr_sim h1 h1.intr hs0 htp _


/-! ## Native iterators, `Set`s, `Math.max` -/

section natives
variable {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

/-- `Math.max(...xs)`: as `Math.min` (`bi_fold`). -/
theorem step_math_max (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.math .max) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_fold hFR .max args (.lit (.inf true)) h trivial hargs

/-- An iterator's `[Symbol.iterator]()`: itself. -/
theorem step_iter_self (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.iter .self) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, -⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_ret h this hthis

/-- `next()` of an unframed value-mode iterator over an array snapshot (`ElemsOK` source). -/
theorem step_iter_next (h : RelB F FR W stk M ν K s S t C) {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.iter .next) data)) (hn : s.next + margin < Sim.bound)
    (hpo : Present s aObjectProto) {a : Nat} {io : Obj} {src : Val} {i : Nat} (hthis : this = .obj a)
    (hio : s.obj? a = some io) (hik : io.kind = .iter src i 0) (hfr : K.fr a = none) (hel : ElemsOK F K s S src) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, -⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hio' : t.obj? (M.a a) = some (M.obj io) := h.obj? hio hfr
  have hso := h.obj?_supp hio
  have hn1 : s.next < Sim.bound := by unfold margin at hn; omega
  have ha : Present s a := Present.of_get (obj?_iff.1 hio)
  obtain ⟨kd, pr, ps, pv, ex⟩ := io
  simp only at hik
  subst hik
  have hsrc : Supp.val (Present s) S.tab.length src := hso.1
  show MSim _ S C (iterN F s (.obj a) .next) (iterN F t (.obj (M.a a)) .next)
  simp only [iterN, hio, hio', Map.obj, Map.kind]
  refine MSim.bind (elemsOf_sim h hF hsrc hel) ?_
  rintro M0 S0 C0 r r' ⟨hM0, hS0, hC0, hr, hsupp⟩
  subst M0 S0 C0
  cases r with
  | none => rw [hr]; exact MSim.fail _ _
  | some es =>
    rw [hr]
    simp only [Option.map_some]
    rw [show M.vals es = es.map M.val from rfl, nth?_map]
    cases hv : nth? es i with
    | none =>
      simp only [Option.map_none]
      obtain ⟨e, hp, u⟩ := upd_iterResult h hpo hn1 (v := .undef) trivial true
      have e' : (iterResult t .undef true).1 = M.a (iterResult s .undef true).1 := e
      rw [e']
      exact bi_ret u.rel (.obj _) hp
    | some v =>
      simp only [Option.map_some]
      have hvs : Supp.val (Present s) S.tab.length v := hsupp es rfl v (nth?_mem hv)
      let o1 : Obj := ⟨.iter src (i + 1) 0, pr, ps, pv, ex⟩
      have hso1 : Supp.obj (Present s) S.tab.length o1 := ⟨hsrc, hso.2.1, hso.2.2.1, hso.2.2.2⟩
      have u1 := upd_setObj h hn1 ha hfr hso1
      obtain ⟨e, hp, u2⟩ := upd_iterResult u1.rel (u1.pres _ hpo) (u1.bound (j := 0) (by omega))
        (Supp.val_mono u1.pres (Nat.le_refl _) hvs) false
      show MSim _ S C (retS F (iterResult (s.setObj a o1) v false).2 (.obj (iterResult (s.setObj a o1) v false).1))
        (retS F (iterResult (t.setObj (M.a a) (M.obj o1)) (M.val v) false).2
          (.obj (iterResult (t.setObj (M.a a) (M.obj o1)) (M.val v) false).1))
      rw [e]
      exact bi_ret u2.rel (.obj _) hp

/-- `Set.prototype.values()` of an unframed `Set`: a snapshot array and a value-mode iterator. -/
theorem step_set_values (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.set .values) data)) (hn : s.next + margin < Sim.bound)
    (hpa : Present s aArrayProto) (hpi : Present s aArrayIterProto) {a : Nat} {so : Obj} {es : List Val}
    (hthis : this = .obj a) (hso : s.obj? a = some so) (hsk : so.kind = .set es) (hfr : K.fr a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, -⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hso' : t.obj? (M.a a) = some (M.obj so) := h.obj? hso hfr
  have hss := h.obj?_supp hso
  have hes : Supp.vals (Present s) S.tab.length es := by have := hss.1; rw [hsk] at this; exact this
  have hn1 : s.next < Sim.bound := by unfold margin at hn; omega
  have hst : setOf F s (.obj a) = some (a, so, es) := by simp only [setOf, hso, hsk]
  have hst' : setOf F t (.obj (M.a a)) = some (M.a a, M.obj so, M.vals es) := by
    simp only [setOf, hso', Map.obj, Map.kind, hsk]
  show MSim _ S C (setN F s (.obj a) args .values) (setN F t (.obj (M.a a)) (M.vals args) .values)
  simp only [setN, setN.withSet, hst, hst']
  have ea : M.val (.obj aArrayProto) = .obj aArrayProto := by
    show Val.obj (M.a aArrayProto) = _; rw [h.intr _ (by decide)]
  have ei : M.val (.obj aArrayIterProto) = .obj aArrayIterProto := by
    show Val.obj (M.a aArrayIterProto) = _; rw [h.intr _ (by decide)]
  obtain ⟨f1, -, hp1, u1⟩ := upd_allocObj h (k := .array es) (proto := .obj aArrayProto) (props := []) hn1 hes hpa
    (fun _ hx => nomatch hx)
  rw [ea] at f1 u1
  have hn2 : (newArray s es).2.next < Sim.bound := u1.bound (j := 0) (by unfold margin at hn; omega)
  obtain ⟨f2, -, hp2, u2⟩ := upd_allocObj u1.rel (k := .iter (.obj (newArray s es).1) 0 0)
    (proto := .obj aArrayIterProto) (props := []) hn2 hp1 (u1.pres _ hpi) (fun _ hx => nomatch hx)
  rw [ei] at f2 u2
  show MSim _ S C
    (retS F ((newArray s es).2.allocObj (.iter (.obj (newArray s es).1) 0 0) (.obj aArrayIterProto) []).2
      (.obj ((newArray s es).2.allocObj (.iter (.obj (newArray s es).1) 0 0) (.obj aArrayIterProto) []).1))
    (retS F ((newArray t (M.vals es)).2.allocObj (.iter (.obj (newArray t (M.vals es)).1) 0 0) (.obj aArrayIterProto) []).2
      (.obj ((newArray t (M.vals es)).2.allocObj (.iter (.obj (newArray t (M.vals es)).1) 0 0) (.obj aArrayIterProto) []).1))
  have f1' : (newArray t (M.vals es)).1 = M.a (newArray s es).1 := f1
  rw [f1']
  have f2' : ((newArray t (M.vals es)).2.allocObj (.iter (.obj (M.a (newArray s es).1)) 0 0) (.obj aArrayIterProto) []).1 =
      M.a ((newArray s es).2.allocObj (.iter (.obj (newArray s es).1) 0 0) (.obj aArrayIterProto) []).1 := f2
  rw [f2']
  exact bi_ret u2.rel (.obj _) hp2

/-- `Set.prototype.has(k)` of an unframed `Set` whose elements compare with `k` alike. -/
theorem step_set_has (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.set .has) data)) {a : Nat} {so : Obj} {es : List Val}
    (hthis : this = .obj a) (hso : s.obj? a = some so) (hsk : so.kind = .set es) (hfr : K.fr a = none)
    (hok : ∀ x ∈ es, SvzOK K x (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hso' : t.obj? (M.a a) = some (M.obj so) := h.obj? hso hfr
  have hss := h.obj?_supp hso
  have hes : Supp.vals (Present s) S.tab.length es := by have := hss.1; rw [hsk] at this; exact this
  have hst : setOf F s (.obj a) = some (a, so, es) := by simp only [setOf, hso, hsk]
  have hst' : setOf F t (.obj (M.a a)) = some (M.a a, M.obj so, M.vals es) := by
    simp only [setOf, hso', Map.obj, Map.kind, hsk]
  show MSim _ S C (setN F s (.obj a) args .has) (setN F t (.obj (M.a a)) (M.vals args) .has)
  simp only [setN, setN.withSet, hst, hst', bi_arg_map]
  have hpairs : Supp.pairs (Present s) S.tab.length (es.map fun x => (x, x)) := by
    intro p hp
    obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hp
    exact ⟨hes x hx, hes x hx⟩
  have hok' : ∀ p ∈ es.map (fun x => (x, x)), SvzOK K p.1 (arg args 0) := by
    intro p hp
    obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hp
    exact hok x hx
  have em : (M.vals es).map (fun x => (x, x)) = M.pairs (es.map fun x => (x, x)) := by
    simp only [Map.vals, Map.pairs, List.map_map]; rfl
  rw [em]
  refine bi_bind (bi_findEntry hFR _ 0 h (bi_arg_supp 0 hargs) hpairs hok') (fun _ _ _ _ _ hp => hp.2) ?_
  rintro M' S' C' r r' ⟨hr, g⟩
  rw [hr]
  exact bi_ret (h.grow hFR g) (.bool r.isSome) trivial

/-- `f.bind(this, ...args)`: a bound function over the call's values. -/
theorem step_fn_bind (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.fn .bind) data)) (hn : s.next + margin < Sim.bound)
    (hfp : Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  have hn1 : s.next < Sim.bound := by unfold margin at hn; omega
  have htl : Supp.vals (Present s) S.tab.length args.tail := fun x hx => hargs x (List.mem_of_mem_tail hx)
  have hr0 := bi_allocObj_ret h (.fn (.bound this (arg args 0) args.tail)) aFunctionProto [] hn1
    (h.intr _ (by decide)) hfp ⟨hthis, BufSim.arg_supp hargs 0, htl⟩ (fun _ hx => nomatch hx)
  have et : (M.vals args).tail = M.vals args.tail := by
    cases args <;> rfl
  show MSim _ S C (fnN F s this args .bind) (fnN F t (M.val this) (M.vals args) .bind)
  simp only [fnN]
  rw [bi_arg_map, et]
  exact hr0

end natives


/-! ## `new Set(xs)` and `new Promise(executor)` -/

/-- `Set`'s de-duplication (`setN.dedup`) when every element compares alike with the others. -/
theorem dedup_sim (hFR : FRLaws FR) : ∀ (vs acc : List Val) {M : Map} {S : SSrv} {C : CSrv},
    RelB F FR W stk M ν K s S t C → Supp.vals (Present s) S.tab.length vs → Supp.vals (Present s) S.tab.length acc →
    (∀ x ∈ vs, ∀ y ∈ acc ++ vs, SvzOK K y x) →
    MSim (fun M' S' C' r r' => r' = M'.vals r ∧ Supp.vals (Present s) S'.tab.length r ∧ Grow M ν S C M' S' C') S C
      (setN.dedup F s acc vs) (setN.dedup F t (M.vals acc) (M.vals vs))
  | [], acc, M, S, C, h, _, hacc, _ => by
    simp only [Map.vals, List.map_nil, setN.dedup]
    exact MSim.pure ⟨by simp only [List.map_reverse],
      fun x hx => hacc x (List.mem_reverse.1 hx), Grow.refl h.srv⟩
  | v :: vs, acc, M, S, C, h, hvs, hacc, hok => by
    have hv := hvs v (List.mem_cons_self ..)
    have hvs' : Supp.vals (Present s) S.tab.length vs := fun x hx => hvs x (List.mem_cons_of_mem _ hx)
    have hpairs : Supp.pairs (Present s) S.tab.length (acc.map fun x => (x, x)) := by
      intro p hp
      obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hp
      exact ⟨hacc x hx, hacc x hx⟩
    have hok1 : ∀ p ∈ acc.map (fun x => (x, x)), SvzOK K p.1 v := by
      intro p hp
      obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hp
      exact hok v (List.mem_cons_self ..) x (List.mem_append_left _ hx)
    have em : (M.vals acc).map (fun x => (x, x)) = M.pairs (acc.map fun x => (x, x)) := by
      simp only [Map.vals, Map.pairs, List.map_map]; rfl
    show MSim _ S C (Host.Ts.M.bind (findEntry F s v (acc.map fun x => (x, x)) 0) _)
      (Host.Ts.M.bind (findEntry F t (M.val v) ((M.vals acc).map fun x => (x, x)) 0) _)
    rw [em]
    refine MSim.bind (bi_findEntry hFR _ 0 h hv hpairs hok1) ?_
    rintro M' S' C' r r' ⟨hr, g⟩
    rw [hr]
    have h' := h.grow hFR g
    have hvs'' := bi_supps_grow g hvs'
    have hacc' := bi_supps_grow g hacc
    have hv' := bi_supp_grow g hv
    have ev : M'.vals vs = M.vals vs := g.bi_vals hvs'
    have ea : M'.vals acc = M.vals acc := g.bi_vals hacc
    have ex : M'.val v = M.val v := g.bi_val hv
    cases r with
    | some _ =>
      have ih := dedup_sim hFR vs acc h' hvs'' hacc'
        (fun x hx y hy => hok x (List.mem_cons_of_mem _ hx) y (by
          rcases List.mem_append.1 hy with hy | hy
          · exact List.mem_append_left _ hy
          · exact List.mem_append_right _ (List.mem_cons_of_mem _ hy)))
      rw [ev, ea] at ih
      exact MSim.mono ih fun _ _ _ _ _ ⟨e, hs, g'⟩ => ⟨e, hs, g.trans g'⟩
    | none =>
      have ih := dedup_sim hFR vs (v :: acc) h' hvs''
        (fun x hx => by
          rcases List.mem_cons.1 hx with rfl | hx
          · exact hv'
          · exact hacc' x hx)
        (fun x hx y hy => hok x (List.mem_cons_of_mem _ hx) y (by
          rcases List.mem_append.1 hy with hy | hy
          · rcases List.mem_cons.1 hy with rfl | hy
            · exact List.mem_append_right _ (List.mem_cons_self ..)
            · exact List.mem_append_left _ hy
          · exact List.mem_append_right _ (List.mem_cons_of_mem _ hy)))
      have evs : M'.vals (v :: acc) = M.val v :: M.vals acc := by
        show M'.val v :: M'.vals acc = _; rw [ex, ea]
      rw [ev, evs] at ih
      exact MSim.mono ih fun _ _ _ _ _ ⟨e, hs, g'⟩ => ⟨e, hs, g.trans g'⟩

section ctors
variable {a : Nat} {args : List Val} {nt : Val} {o : Obj} {data : List Val}

/-- **`new Set(xs)`** from an array whose elements compare alike with each other. -/
theorem step_set_ctor (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (hF : FfiSim F FR okCall okBack)
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.set .ctor) data)) (hn : s.next + margin < Sim.bound)
    (hps : Present s aSetProto) {b : Nat} (harg : arg args 0 = .obj b) (hel : ElemsOK F K s S (arg args 0))
    (hsvz : ∀ vs S1, interpS (elemsOf F s (arg args 0)).run S = some (some vs, S1) →
      ∀ x ∈ vs, ∀ y ∈ vs, SvzOK K y x) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [BufSim.step_construct_native hc ho hk, BufSim.step_construct_native_t h hc ho hk]
  have hargs := BufSim.construct_supp h hc
  have hb : Supp.val (Present s) S.tab.length (arg args 0) := BufSim.arg_supp hargs 0
  have hn1 : s.next < Sim.bound := by unfold margin at hn; omega
  have hma : arg (M.vals args) 0 = M.val (arg args 0) := bi_arg_map M args 0
  show MSim _ S C (setN F s .undef args .ctor) (setN F t .undef (M.vals args) .ctor)
  simp only [setN, hma]
  rw [harg] at hb hel hsvz ⊢
  simp only [Map.val]
  refine MSim.bind (BufSim.MSim.withRun (elemsOf_sim h hF hb hel) (BufSim.elemsOf_lawful _ _ _)
    (BufSim.elemsOf_lawful _ _ _)) ?_
  rintro M0 S0 C0 r r' ⟨⟨hM0, hS0, hC0, hr, hsupp⟩, hrun⟩
  subst M0 S0 C0
  cases r with
  | none => rw [hr]; exact MSim.fail _ _
  | some vs =>
    rw [hr]
    simp only [Option.map_some]
    have hvs := hsupp vs rfl
    refine MSim.bind (dedup_sim hFR vs [] h hvs (fun _ hx => nomatch hx)
      (fun x hx y hy => hsvz vs S hrun x hx y (by simpa using hy))) ?_
    rintro M' S' C' r r' ⟨hr', hsr, g⟩
    rw [hr']
    have h' := h.grow hFR g
    exact StepPost.after g (bi_allocObj_ret h' (.set r) aSetProto [] hn1 (h'.intr _ (by decide)) hps hsr
      (fun _ hx => nomatch hx))

/-- **`new Promise(executor)`**: a pending promise, its resolving functions, and the executor's call
under the promise constructor's frame. -/
theorem step_construct_promise (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .construct (.obj a) args nt) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .promiseCtor) data)) (hn : s.next + margin < Sim.bound)
    (hpp : Present s aPromiseProto) (hfp : Present s aFunctionProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  rw [BufSim.step_construct_native hc ho hk, BufSim.step_construct_native_t h hc ho hk]
  have hargs := BufSim.construct_supp h hc
  have hn1 : s.next < Sim.bound := by unfold margin at hn; omega
  obtain ⟨e1, -, hp, u1⟩ := upd_newPromise h hpp hn1
  have ef : M.val (.obj aFunctionProto) = .obj aFunctionProto := by
    show Val.obj (M.a aFunctionProto) = _; rw [h.intr _ (by decide)]
  have hn2 : (newPromise s).2.next < Sim.bound := u1.bound (j := 0) (by unfold margin at hn; omega)
  obtain ⟨f1, -, hr, u2⟩ := upd_allocObj u1.rel (k := .fn (.native (.ctl .resolveFn) [.obj (newPromise s).1]))
    (proto := .obj aFunctionProto) (props := []) hn2 (fun x hx => by
      rw [List.mem_singleton.1 hx]; exact hp) (u1.pres _ hfp) (fun _ hx => nomatch hx)
  rw [ef] at f1 u2
  have hn3 : ((newPromise s).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise s).1]))
      (.obj aFunctionProto) []).2.next < Sim.bound := (u1.trans u2).bound (j := 0) (by unfold margin at hn; omega)
  obtain ⟨f2, -, hj, u3⟩ := upd_allocObj u2.rel (k := .fn (.native (.ctl .rejectFn) [.obj (newPromise s).1]))
    (proto := .obj aFunctionProto) (props := []) hn3 (fun x hx => by
      rw [List.mem_singleton.1 hx]; exact u2.pres _ hp) (u2.pres _ (u1.pres _ hfp)) (fun _ hx => nomatch hx)
  rw [ef] at f2 u3
  have r1 := (u3.rel.push (.k (.native (.ctl .promiseCtor) [.obj (newPromise s).1])) (fun x hx => by
      rw [List.mem_singleton.1 hx]; exact u3.pres _ (u2.pres _ hp))).go
    (.call (arg args 0) .undef
      [.obj ((newPromise s).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise s).1]))
          (.obj aFunctionProto) []).1,
       .obj (((newPromise s).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise s).1]))
          (.obj aFunctionProto) []).2.allocObj (.fn (.native (.ctl .rejectFn) [.obj (newPromise s).1]))
          (.obj aFunctionProto) []).1])
    ⟨Supp.val_mono (fun _ h => u3.pres _ (u2.pres _ (u1.pres _ h))) (Nat.le_refl _) (BufSim.arg_supp hargs 0),
      trivial, fun y hy => by
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hy
        rcases hy with rfl | rfl
        · exact u3.pres _ hr
        · exact hj⟩
  refine MSim.pure ⟨Grow.refl h.srv, ?_⟩
  have e1' : (newPromise t).1 = M.a (newPromise s).1 := e1
  show RelB F FR W stk M ν K _ S
    ((((((newPromise t).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise t).1])) (.obj aFunctionProto) []).2.allocObj
        (.fn (.native (.ctl .rejectFn) [.obj (newPromise t).1])) (.obj aFunctionProto) []).2).push
      (.k (.native (.ctl .promiseCtor) [.obj (newPromise t).1]))).go
      (.call (arg (M.vals args) 0) .undef
        [.obj ((newPromise t).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise t).1])) (.obj aFunctionProto) []).1,
         .obj (((newPromise t).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise t).1])) (.obj aFunctionProto) []).2.allocObj
          (.fn (.native (.ctl .rejectFn) [.obj (newPromise t).1])) (.obj aFunctionProto) []).1])) C
  rw [e1']
  have f1' : ((newPromise t).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (M.a (newPromise s).1)]))
      (.obj aFunctionProto) []).1 =
      M.a ((newPromise s).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise s).1])) (.obj aFunctionProto) []).1 := f1
  have f2' : (((newPromise t).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (M.a (newPromise s).1)]))
      (.obj aFunctionProto) []).2.allocObj (.fn (.native (.ctl .rejectFn) [.obj (M.a (newPromise s).1)]))
      (.obj aFunctionProto) []).1 =
      M.a (((newPromise s).2.allocObj (.fn (.native (.ctl .resolveFn) [.obj (newPromise s).1]))
          (.obj aFunctionProto) []).2.allocObj (.fn (.native (.ctl .rejectFn) [.obj (newPromise s).1]))
          (.obj aFunctionProto) []).1 := f2
  rw [f1', f2', bi_arg_map]
  exact r1

end ctors

end
end Host.Ts.Sim
