import host.sim.extract.Grow
namespace Host.Mlx.Ffi.FullKeep
open Host.Ts Host.Ts.Sim.BufSim

/-! # Objects stay: every mlx call keeps the model's objects

The observer relations of the full world (`host.sim.full.Rel`) key recorded handles by objects of
the mlx model. They stay valid along any run because every mlx call (`Host.Mlx.Ffi.call`), on any
server, symbolic or concrete (`AllX`), keeps the model's objects, creates objects only at or above
the handle counter, and does not decrease the counter (`Keep`): objects are only created by
`St.newObj` and replaced by `St.setObj` at a present object. The proof walks the dispatch as
`Host.Mlx.Ffi.NGrowCall.call_g` does. -/

/-- Every run of `m`, symbolic or concrete, ends in a result satisfying `Q`. -/
def AllX {α : Type} (Q : α → Prop) (m : Host.Ts.M α) : Prop :=
  (∀ S a S', interpS m.run S = some (a, S') → Q a) ∧ (∀ C a C', interpC m.run C = some (a, C') → Q a)

theorem AllX.pure {α : Type} {Q : α → Prop} {a : α} (h : Q a) : AllX Q (Host.Ts.M.pure a) :=
  ⟨fun S a' S' e => by
    have e' : some (a, S) = some (a', S') := e
    cases e'; exact h,
   fun C a' C' e => by
    have e' : some (a, C) = some (a', C') := e
    cases e'; exact h⟩

theorem AllX.bind {α β : Type} {P : α → Prop} {Q : β → Prop} {m : Host.Ts.M α} {f : α → Host.Ts.M β}
    (hm : Lawful m) (h : AllX P m) (hf : ∀ a, P a → AllX Q (f a)) : AllX Q (Host.Ts.M.bind m f) := by
  refine ⟨fun S b S' e => ?_, fun C b C' e => ?_⟩
  · have e' : interpS (m β fun a => (f a).run) S = some (b, S') := e
    rw [hm.1] at e'
    cases hr : interpS m.run S with
    | none => rw [hr] at e'; cases e'
    | some p =>
      rw [hr] at e'
      exact (hf p.1 (h.1 S p.1 p.2 hr)).1 p.2 b S' e'
  · have e' : interpC (m β fun a => (f a).run) C = some (b, C') := e
    rw [hm.2] at e'
    cases hr : interpC m.run C with
    | none => rw [hr] at e'; cases e'
    | some p =>
      rw [hr] at e'
      exact (hf p.1 (h.2 C p.1 p.2 hr)).2 p.2 b C' e'

theorem AllX.bind' {α β : Type} {Q : β → Prop} {m : Host.Ts.M α} {f : α → Host.Ts.M β}
    (hm : Lawful m) (hf : ∀ a, AllX Q (f a)) : AllX Q (Host.Ts.M.bind m f) :=
  AllX.bind (P := fun _ => True) hm ⟨fun _ _ _ _ => trivial, fun _ _ _ _ => trivial⟩ fun a _ => hf a

theorem AllX.cond {α : Type} {Q : α → Prop} (c : Bool) {m1 m2 : Host.Ts.M α} (h1 : AllX Q m1) (h2 : AllX Q m2) :
    AllX Q (bif c then m1 else m2) := by cases c <;> assumption

/-! ## Keeping objects -/

/-- `y` keeps `x`'s objects, has new objects only at or above `x`'s counter, a counter at least
`x`'s, and pending traces `x`'s (by id) or new ones with ids above `x`'s counter (a new trace's
tracer vector is allocated at or above it, just before the id) and below `y`'s; it keeps `x`'s
nodes below `x`'s node counter, and the nodes it adds are present (below `2 ^ 62`, where the node
table stores them). -/
structure Keep (x y : St) : Prop where
  objs : ∀ h, (x.objs.get h).isSome = true → (y.objs.get h).isSome = true
  fresh : ∀ h, (y.objs.get h).isSome = true → (x.objs.get h).isSome = true ∨ x.next ≤ h
  next : x.next ≤ y.next
  pend : ∀ p ∈ y.pending, (∃ q ∈ x.pending, q.id = p.id) ∨ (x.next < p.id ∧ p.id < y.next)
  nnext : x.nnext ≤ y.nnext
  nodes : ∀ i, i < x.nnext → y.nodes.get i = x.nodes.get i
  dense : ∀ i, x.nnext ≤ i → i < y.nnext → i < 2 ^ 62 → (y.nodes.get i).isSome = true

variable {s₀ s s₁ : St}

theorem Keep.refl (x : St) : Keep x x :=
  ⟨fun _ h => h, fun _ h => .inl h, Nat.le_refl _, fun p hp => .inl ⟨p, hp, rfl⟩, Nat.le_refl _,
    fun _ _ => rfl, fun _ h1 h2 => absurd h2 (Nat.not_lt.mpr h1)⟩

theorem Keep.trans {x y z : St} (h : Keep x y) (h' : Keep y z) : Keep x z where
  objs k hk := h'.objs k (h.objs k hk)
  fresh k hk := by
    rcases h'.fresh k hk with e | e
    · rcases h.fresh k e with e' | e'
      · exact .inl e'
      · exact .inr e'
    · exact .inr (Nat.le_trans h.next e)
  next := Nat.le_trans h.next h'.next
  pend p hp := by
    rcases h'.pend p hp with ⟨q, hq, e⟩ | ⟨e1, e2⟩
    · rcases h.pend q hq with ⟨q0, hq0, e0⟩ | ⟨f1, f2⟩
      · exact .inl ⟨q0, hq0, e0.trans e⟩
      · exact .inr ⟨e ▸ f1, by rw [← e]; exact Nat.lt_of_lt_of_le f2 h'.next⟩
    · exact .inr ⟨Nat.lt_of_le_of_lt h.next e1, e2⟩
  nnext := Nat.le_trans h.nnext h'.nnext
  nodes i hi := (h'.nodes i (Nat.lt_of_lt_of_le hi h.nnext)).trans (h.nodes i hi)
  dense i h1 h2 h3 := by
    by_cases e : i < y.nnext
    · rw [h'.nodes i e]; exact h.dense i h1 e h3
    · exact h'.dense i (Nat.not_lt.mp e) h2 h3

/-- A step: same objects, pending traces and nodes, a counter at least the old one. -/
theorem keep_same {x y : St} (ho : y.objs = x.objs) (hx : x.next ≤ y.next) (hp : y.pending = x.pending)
    (hno : y.nodes = x.nodes) (hnn : y.nnext = x.nnext) : Keep x y :=
  ⟨fun k hk => by rw [ho]; exact hk, fun k hk => by rw [ho] at hk; exact .inl hk, hx,
    fun p h => .inl ⟨p, by rw [← hp]; exact h, rfl⟩, Nat.le_of_eq hnn.symm, fun _ _ => by rw [hno],
    fun _ h1 h2 => absurd h2 (by rw [hnn]; exact Nat.not_lt.mpr h1)⟩

/-- Pending traces `ps` of a state with counter `n` after `s₁`: `s₁`'s by id or new above its counter and below `n`. -/
abbrev PendSub (s₁ : St) (n : Nat) (ps : List Pending) : Prop :=
  ∀ p ∈ ps, (∃ q ∈ s₁.pending, q.id = p.id) ∨ (s₁.next < p.id ∧ p.id < n)

theorem pendSub_tail {s₁ : St} {n : Nat} {p : Pending} {rest : List Pending} (h : s₁.pending = p :: rest) :
    PendSub s₁ n rest :=
  fun q hq => .inl ⟨q, by rw [h]; exact List.mem_cons_of_mem _ hq, rfl⟩

theorem pendSub_res {s₁ : St} {n : Nat} {q : Pending} {rest : List Pending} (h : s₁.pending = q :: rest)
    (r : Option (List Nat)) : PendSub s₁ n ({ q with res := r } :: rest) := by
  intro p hp
  rcases List.mem_cons.mp hp with rfl | hp
  · exact .inl ⟨q, by rw [h]; exact List.mem_cons_self .., rfl⟩
  · exact .inl ⟨p, by rw [h]; exact List.mem_cons_of_mem _ hp, rfl⟩

theorem isSome_set {α : Type} (t : PTrie α) (n : Nat) (v : α) (m : Nat) (h : (t.get m).isSome = true) :
    ((t.set n v).get m).isSome = true := by
  rcases PTrie.get_set_cases t n v m with e | ⟨_, e⟩
  · rw [e]; exact h
  · rw [e]; rfl

theorem isSome_set_inv {α : Type} (t : PTrie α) (n : Nat) (v : α) (m : Nat) (h : ((t.set n v).get m).isSome = true) :
    (t.get m).isSome = true ∨ m = n := by
  rcases PTrie.get_set_cases t n v m with e | ⟨e1, _⟩
  · rw [e] at h; exact .inl h
  · exact .inr e1

theorem Keep.addNode (h : Keep s₀ s₁) (nd : Node) : Keep s₀ (s₁.addNode nd).2 :=
  h.trans ⟨fun k hk => hk, fun k hk => .inl hk, Nat.le_refl _, fun p hp => .inl ⟨p, hp, rfl⟩, Nat.le_succ _,
    fun i hi => PTrie.get_set_ne' _ _ _ _ (Nat.ne_of_lt hi),
    fun i h1 h2 h3 => by
      have e : i = s₁.nnext := by show i = s₁.nnext; have : i < s₁.nnext + 1 := h2; omega
      subst e
      show ((s₁.nodes.set s₁.nnext nd).get s₁.nnext).isSome = true
      rw [PTrie.get_set_self _ _ _ (Nat.lt_of_le_of_lt (Nat.div_le_self _ 4096)
        (by rw [show (4 : Nat) ^ 31 = 2 ^ 62 from rfl]; exact h3))]; rfl⟩

theorem Keep.newObj (h : Keep s₀ s₁) (o : Obj) : Keep s₀ (s₁.newObj o).2 :=
  h.trans ⟨fun k hk => isSome_set _ _ _ _ hk,
    fun k hk => by
      rcases isSome_set_inv _ _ _ _ hk with e | e
      · exact .inl e
      · exact .inr (Nat.le_of_eq e.symm),
    Nat.le_succ _, fun p hp => .inl ⟨p, hp, rfl⟩, Nat.le_refl _, fun _ _ => rfl,
    fun _ h1 h2 => absurd h2 (Nat.not_lt.mpr h1)⟩

theorem Keep.setObj (h : Keep s₀ s₁) {k : Nat} {o0 : Obj} (hg : s₁.obj? k = some o0) (o : Obj) :
    Keep s₀ (s₁.setObj k o) :=
  h.trans ⟨fun k' hk => isSome_set _ _ _ _ hk,
    fun k' hk => by
      rcases isSome_set_inv _ _ _ _ hk with e | e
      · exact .inl e
      · subst e; left; show (s₁.objs.get k').isSome = true; rw [show s₁.objs.get k' = s₁.obj? k' from rfl, hg]; rfl,
    Nat.le_refl _, fun p hp => .inl ⟨p, hp, rfl⟩, Nat.le_refl _, fun _ _ => rfl,
    fun _ h1 h2 => absurd h2 (Nat.not_lt.mpr h1)⟩

theorem Keep.setArr (h : Keep s₀ s₁) (slot n : Nat) : Keep s₀ (s₁.setArr slot n).2 := by
  refine h.trans ?_
  unfold St.setArr
  cases Nat.beq slot 0
  · exact keep_same rfl (Nat.le_refl _) rfl rfl rfl
  · exact keep_same rfl (Nat.le_succ _) rfl rfl rfl

theorem Keep.freeArr (h : Keep s₀ s₁) (k : Nat) : Keep s₀ (s₁.freeArr k) := by
  refine h.trans ?_
  unfold St.freeArr
  cases Nat.beq k 0
  · exact keep_same rfl (Nat.le_refl _) rfl rfl rfl
  · exact keep_same rfl (Nat.le_refl _) rfl rfl rfl

theorem Keep.setVec (h : Keep s₀ s₁) (slot : Nat) (ns : List Nat) : Keep s₀ (Host.Mlx.Ffi.setVec s₁ slot ns).2 := by
  unfold Host.Mlx.Ffi.setVec
  split
  · rename_i heq
    exact h.setObj heq _
  · exact h.newObj _

theorem Keep.pop (h : Keep s₀ s₁) {k : Nat} {t : NumV} {ts : List NumV} :
    Keep s₀ { s₁ with tokens := ts, items := s₁.items.set k t } :=
  h.trans (keep_same rfl (Nat.le_refl _) rfl rfl rfl)

theorem Keep.lit (h : Keep s₀ s₁) {n nn wired : Nat} {nodes : PTrie Node} {arrs : PTrie Nat} {objs : PTrie Obj}
    {toks : List NumV} {files : List (List Char × Header)} {pend : List Pending} {errh : Option Arg}
    {arch : List Char} {ds : List (List Char × Nat)} {items : PTrie NumV}
    (ho : objs = s₁.objs) (hno : nodes = s₁.nodes) (hnn : nn = s₁.nnext) (hx : s₁.next ≤ n) (hp : PendSub s₁ n pend) :
    Keep s₀ ⟨n, nodes, nn, arrs, objs, toks, files, pend, errh, arch, ds, wired, items⟩ :=
  h.trans ⟨fun k hk => by rw [ho]; exact hk, fun k hk => by rw [ho] at hk; exact .inl hk, hx, hp,
    Nat.le_of_eq hnn.symm, fun _ _ => by rw [hno], fun _ h1 h2 => absurd h2 (by rw [hnn]; exact Nat.not_lt.mpr h1)⟩

theorem Keep.tracers : ∀ (s : St) (i : Nat) (sh : List (List Dim × Nat)), Keep s₀ s →
    Keep s₀ (closureApply.tracers s i sh).1
  | _, _, [], h => h
  | _, i, (shape, dt) :: r, h => Keep.tracers _ (i + 1) r (h.addNode ⟨.tracer i, [], shape, dt⟩)

/-- A new pending trace (`closureApply`'s recording path): its tracer vector allocated at `s₁`'s counter, its id
the next. -/
theorem Keep.record (h : Keep s₀ s₁) (o : Obj) (p : Pending) (hid : p.id = (s₁.newObj o).2.next) :
    Keep s₀ { (s₁.newObj o).2 with next := (s₁.newObj o).2.next + 1, pending := p :: (s₁.newObj o).2.pending } := by
  have h1 := h.newObj o
  have e : (s₁.newObj o).2.next = s₁.next + 1 := rfl
  refine ⟨h1.objs, h1.fresh, Nat.le_succ_of_le h1.next, fun q hq => ?_, h1.nnext, h1.nodes, h1.dense⟩
  rcases List.mem_cons.mp hq with rfl | hq
  · exact .inr ⟨by have := h.next; omega, by show q.id < (s₁.newObj o).2.next + 1; omega⟩
  · rcases h1.pend q hq with e1 | ⟨e1, e2⟩
    · exact .inl e1
    · exact .inr ⟨e1, Nat.lt_succ_of_lt e2⟩

theorem Keep.outs (kh : Nat) (xs : List Nat) (c : Cfg) : ∀ (s : St) (i : Nat) (os : List (List Dim × Nat)),
    Keep s₀ s → Keep s₀ (kernelApply.outs kh xs c s i os).1
  | _, _, [], h => h
  | _, i, (shape, dt) :: r, h => Keep.outs kh xs c _ (i + 1) r (h.addNode ⟨.kernel kh c i, xs, shape, dt⟩)

/-! ## Results -/

/-- Optional results whose state keeps `s₀`'s objects. -/
def OKeep {β : Type} (s₀ : St) (f : β → St) : Option β → Prop := fun o => ∀ b, o = some b → Keep s₀ (f b)

/-- Results of a native call whose state keeps `s₀`'s objects. -/
abbrev KRes (s₀ : St) := OKeep (β := St × Ret × List (Nat × Nat × List Byte)) s₀ Prod.fst

theorem AllX_none {β : Type} {f : β → St} : AllX (OKeep s₀ f) (Host.Ts.M.pure none) :=
  AllX.pure fun _ e => by cases e

theorem AllX_some {β : Type} {f : β → St} {b : β} (h : Keep s₀ (f b)) :
    AllX (OKeep s₀ f) (Host.Ts.M.pure (some b)) :=
  AllX.pure fun _ e => by cases e; exact h

theorem AllX_ok {r : Ret} (h : Keep s₀ s) : AllX (KRes s₀) (ok s r) := AllX_some h
theorem AllX_okW {r : Ret} {ws : List (Nat × Nat × List Byte)} (h : Keep s₀ s) : AllX (KRes s₀) (okW s r ws) :=
  AllX_some h
theorem AllX_stuck : AllX (KRes s₀) stuck := AllX_none

/-! ## Tactics (`host.sim.extract.Grow`'s, for `Keep`) -/

/-- The pending traces of a literal state. -/
macro "pend_tac" : tactic => `(tactic| first
  | exact fun p hp => .inl ⟨p, hp, rfl⟩
  | exact pendSub_tail (by assumption)
  | exact pendSub_res (by assumption) _
  | with_unfolding_all exact pendSub_tail (by assumption)
  | with_unfolding_all exact pendSub_res (by assumption) _)

open Lean Meta Elab Tactic in
/-- `Keep.lit` on a goal `Keep s₀ ⟨…⟩` whose state is a structure literal. -/
elab "keep_lit" : tactic => do
  let t := (← instantiateMVars (← getMainTarget)).consumeMData
  unless t.isAppOfArity ``Keep 2 && t.appArg!.consumeMData.isAppOf ``St.mk do throwError "not a literal state"
  evalTactic (← `(tactic| with_reducible refine Keep.lit ?_ rfl rfl rfl (by omega) (by pend_tac)))

/-- One step of a state expression. -/
macro "keep_step" : tactic => `(tactic| first
  | with_reducible exact Keep.refl _
  | with_reducible exact ‹Keep _ _›
  | with_reducible refine Keep.addNode ?_ _
  | with_reducible refine Keep.newObj ?_ _
  | with_reducible refine Keep.setArr ?_ _ _
  | with_reducible refine Keep.freeArr ?_ _
  | with_reducible refine Keep.setVec ?_ _ _
  | with_reducible refine Keep.tracers _ _ _ ?_
  | with_reducible refine Keep.outs _ _ _ _ _ _ ?_
  | keep_lit
  | with_reducible refine Keep.pop ?_
  | with_reducible refine Keep.setObj ?_ (by with_reducible assumption) _)

/-- One step of a keeping proof, other than case splits. -/
macro "keep_head" : tactic => `(tactic| first
  | subst_pairs
  | with_reducible exact AllX_stuck
  | with_reducible exact AllX_none
  | with_reducible refine AllX_okW ?_
  | with_reducible refine AllX_ok ?_
  | with_reducible refine AllX_some ?_
  | with_reducible refine AllX.cond _ ?_ ?_
  | with_reducible assumption
  | keep_step)

macro "keep_base" : tactic => `(tactic| first
  | keep_head
  | split
  | dsimp only)

open Lean Meta Elab Tactic in
/-- Fails unless the goal is an `AllX` goal; drops its annotations. -/
elab "allx_goal" : tactic => do
  let g ← getMainGoal
  let t := (← instantiateMVars (← g.getType)).consumeMData
  unless t.isAppOf ``AllX do throwError "not an AllX goal"
  replaceMainGoal [← g.replaceTargetDefEq t]

/-! ## The native computations -/

theorem opOut_k (h : Keep s₀ s) (o : Arg) (p : Prim) (ins : List Nat) : AllX (KRes s₀) (opOut s o p ins) := by
  unfold opOut
  repeat' (first
    | with_reducible refine AllX.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun _ => ?_
    | keep_base)

theorem leafOut_k (h : Keep s₀ s) (o : Arg) (p : Prim) (sh : List Dim) (d : Nat) :
    AllX (KRes s₀) (leafOut s o p sh d) := by
  unfold leafOut
  repeat' keep_base

theorem replayOrder_k (cls : Nat) : ∀ (s : St) (m : List (Nat × Nat)) (ns : List Nat), Keep s₀ s →
    AllX (OKeep s₀ Prod.fst) (replayOrder s cls m ns)
  | _, _, [], h => AllX_some h
  | s, m, n :: ns, h => by
    unfold replayOrder
    repeat' (first
      | with_reducible refine replayOrder_k cls _ _ ns ?_
      | with_reducible refine AllX.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun _ => ?_
      | keep_base)

theorem replay_k (h : Keep s₀ s) (cls : Nat) (t : Trace) (xs : List Nat) :
    AllX (OKeep s₀ Prod.fst) (replay s cls t xs) := by
  unfold replay
  refine AllX.bind (Host.Ts.Sim.NativeLawful.replayOrder_l _ _ _ _) (replayOrder_k cls s _ _ h) fun r hr => ?_
  rcases r with _ | ⟨s', m'⟩
  · exact AllX_none
  · exact AllX_some (hr _ rfl)

theorem applyDone_k (h : Keep s₀ s) (cls b off slot : Nat) (t : Trace) (xs : List Nat) :
    AllX (KRes s₀) (applyDone s cls b off slot t xs) := by
  unfold applyDone
  refine AllX.bind (Host.Ts.Sim.NativeLawful.replay_l _ _ _ _) (replay_k h cls t xs) fun r hr => ?_
  rcases r with _ | ⟨s', outs⟩
  · exact AllX_stuck
  · have h' : Keep s₀ s' := hr _ rfl
    dsimp only
    repeat' keep_base

theorem closureApply_k (h : Keep s₀ s) (o c v : Arg) : AllX (KRes s₀) (closureApply s o c v) := by
  unfold closureApply
  repeat' (first
    | with_reducible refine AllX.bind' (Host.Ts.Sim.NativeLawful.findTrace_l _ _ _ _) fun _ => ?_
    | with_reducible refine applyDone_k ?_ _ _ _ _ _ _
    | with_reducible refine Keep.record ?_ _ _ rfl
    | keep_base)

theorem kernelApply_k (h : Keep s₀ s) (o k v c : Arg) : AllX (KRes s₀) (kernelApply s o k v c) := by
  unfold kernelApply
  repeat' keep_base

theorem obj_of_bind {s : St} {a : Option Nat} {k : Nat} {o : Obj}
    (e : (a.bind fun h => (s.obj? h).map (h, ·)) = some (k, o)) : s.obj? k = some o :=
  NGrowCall.obj_of_bind e

theorem cfgUpdate_k (h : Keep s₀ s) (c : Arg) (f : Cfg → Option Cfg) : AllX (KRes s₀) (cfgUpdate s c f) := by
  unfold cfgUpdate
  split
  · rename_i heq
    have hg := obj_of_bind heq
    repeat' keep_base
  · exact AllX_stuck

theorem mapGet_k (h : Keep s₀ s) (o m k : Arg) : AllX (KRes s₀) (mapGet s o m k) := by
  unfold mapGet
  repeat' keep_base

theorem loadSafetensors_k (h : Keep s₀ s) (a b c : Arg) : AllX (KRes s₀) (loadSafetensors s a b c) := by
  unfold loadSafetensors
  repeat' keep_base

theorem traceBack_k (h : Keep s₀ s) (a : Arg) : AllX (KRes s₀) (traceBack s a) := by
  unfold traceBack
  repeat' (first
    | with_reducible refine applyDone_k ?_ _ _ _ _ _ _
    | keep_base)

set_option maxHeartbeats 4000000 in
/-- **Every mlx call keeps the model's objects** (on every server). -/
theorem call_k (s : St) (name : Name) (args : List Arg) : AllX (KRes s) (call s name args) := by
  have h0 : Keep s s := Keep.refl s
  unfold call
  cases Host.Mlx.Ffi.symOf name with
  | none => exact AllX_stuck
  | some x =>
    dsimp only
    induction x <;> repeat' (first
      | (allx_goal; reduce_call)
      | (allx_goal; case_call)
      | contradiction
      | with_reducible exact closureApply_k h0 _ _ _
      | with_reducible exact cfgUpdate_k h0 _ _
      | with_reducible exact kernelApply_k h0 _ _ _ _
      | with_reducible exact mapGet_k h0 _ _ _
      | with_reducible exact loadSafetensors_k h0 _ _ _
      | with_reducible exact opOut_k h0 _ _ _
      | with_reducible exact leafOut_k h0 _ _ _ _
      | keep_head
      | split_small
      | dsimp only)

/-- Every trace continuation keeps the model's objects. -/
theorem back_k (s : St) (a : Arg) : AllX (KRes s) (back s a) := traceBack_k (Keep.refl s) a

end Host.Mlx.Ffi.FullKeep
