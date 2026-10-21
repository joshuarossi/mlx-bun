import host.sim.native.Lawful
import host.simgraph.Grow

/-! # The native target state only grows

Every native call and trace continuation of the load world grows the mlx
model's state (`Host.Mlx.Ffi.NGrow`): nodes are added at the node counter,
kernel objects are never replaced, and readbacks pop the token list into
empty item slots in order. The facts are unconditional for the slot store
(`PTrie.get_set_cases` needs no address bound); they need only that object
slots from the handle counter on are empty (`NGrowCall.NInv`), which the
native relation provides. -/

namespace Host.Ts.Trie
variable {α : Type}

/-- A fuelled write changes at most the written address (with any fuel). -/
theorem get_setF_cases (f : Nat) (t : Trie α) (n : Nat) (x : α) (m : Nat) :
    (setF f t n x).get m = t.get m ∨ (m = n ∧ (setF f t n x).get m = some x) := by
  induction f generalizing t n m with
  | zero => left; rfl
  | succ f ih =>
    by_cases hn : n = 0
    · subst n
      by_cases hm : m = 0
      · subst m; right; cases t <;> simp [setF_nil, setF_node, get_node]
      · left; cases t <;> simp [setF_nil, setF_node, get_node, hm]
    · cases t with
      | nil =>
        rw [setF_nil, ite_eq_right hn, get_put _ (Nat.mod_lt _ (by decide))]
        by_cases hm : m = 0
        · left; simp [hm]
        · by_cases hd : m % 4 = n % 4
          · simp only [ite_eq_right hm, ite_eq_left hd]
            rcases ih nil (n / 4) (m / 4) with h | ⟨h1, h2⟩
            · left; rw [h]; simp
            · right; exact ⟨by omega, h2⟩
          · left; simp [hm, hd]
      | node v a b c e =>
        rw [setF_node, ite_eq_right hn, get_put _ (Nat.mod_lt _ (by decide))]
        by_cases hm : m = 0
        · left; simp [hm, get_node]
        · by_cases hd : m % 4 = n % 4
          · simp only [ite_eq_right hm, ite_eq_left hd]
            rcases ih (pick (n % 4) a b c e) (n / 4) (m / 4) with h | ⟨h1, h2⟩
            · left; rw [h, get_node, ite_eq_right hm, hd]
            · right; exact ⟨by omega, h2⟩
          · left; simp [hm, hd, get_node]

theorem get_set_cases (t : Trie α) (n : Nat) (x : α) (m : Nat) :
    (t.set n x).get m = t.get m ∨ (m = n ∧ (t.set n x).get m = some x) :=
  get_setF_cases 32 t n x m

end Host.Ts.Trie

namespace Host.Ts.PTrie
variable {α : Type}

/-- A paged write changes at most the written address, for every address. -/
theorem get_set_cases (t : PTrie α) (n : Nat) (x : α) (m : Nat) :
    (t.set n x).get m = t.get m ∨ (m = n ∧ (t.set n x).get m = some x) := by
  have e : (t.set n x).get m =
      (orNil ((orNil ((t.root.set (n / 4096)
        ((orNil (t.root.get (n / 4096))).set ((n / 64) % 64)
          ((orNil ((orNil (t.root.get (n / 4096))).get ((n / 64) % 64))).set (n % 64) x))).get
        (m / 4096))).get ((m / 64) % 64))).get (m % 64) := by rw [get_eq]; rfl
  rw [e, get_eq t m]
  generalize hG : orNil (t.root.get (n / 4096)) = G
  generalize hP : orNil (G.get ((n / 64) % 64)) = P
  rcases Trie.get_set_cases t.root (n / 4096) (G.set ((n / 64) % 64) (P.set (n % 64) x)) (m / 4096) with
    h1 | ⟨h1, h1'⟩
  · left; rw [h1]
  · rw [h1', orNil_some, h1, hG]
    rcases Trie.get_set_cases G ((n / 64) % 64) (P.set (n % 64) x) ((m / 64) % 64) with h2 | ⟨h2, h2'⟩
    · left; rw [h2]
    · rw [h2', orNil_some, h2, hP]
      rcases Trie.get_set_cases P (n % 64) x (m % 64) with h3 | ⟨h3, h3'⟩
      · left; exact h3
      · right; exact ⟨by omega, h3'⟩

theorem get_set_ne' (t : PTrie α) (n : Nat) (x : α) (m : Nat) (h : m ≠ n) : (t.set n x).get m = t.get m :=
  (get_set_cases t n x m).resolve_right fun h' => h h'.1

theorem get_set_some {t : PTrie α} {n : Nat} {x : α} {m : Nat} {v : α} (h : (t.set n x).get m = some v) :
    t.get m = some v ∨ (m = n ∧ v = x) := by
  rcases get_set_cases t n x m with e | ⟨e1, e2⟩
  · left; rw [← e]; exact h
  · right; rw [h] at e2; exact ⟨e1, Option.some.inj e2⟩

end Host.Ts.PTrie

namespace Host.Mlx.Ffi
open Host.Ts

/-- Readbacks recorded in order, each into a slot that was empty. -/
def Pops : PTrie NumV → List (Nat × NumV) → PTrie NumV → Prop
  | it, [], it' => it' = it
  | it, p :: ps, it' => it.get p.1 = none ∧ Pops (it.set p.1 p.2) ps it'

theorem Pops.append : ∀ {it it' it'' : PTrie NumV} {ps qs : List (Nat × NumV)},
    Pops it ps it' → Pops it' qs it'' → Pops it (ps ++ qs) it''
  | _, _, _, [], _, h1, h2 => by simp only [Pops] at h1; subst h1; exact h2
  | _, _, _, _ :: _, _, ⟨h0, h1⟩, h2 => ⟨h0, Pops.append h1 h2⟩

/-- Every recorded item was there before or is a popped value at a popped slot. -/
theorem Pops.frame : ∀ {it it' : PTrie NumV} {ps : List (Nat × NumV)}, Pops it ps it' →
    ∀ k v, it'.get k = some v → it.get k = some v ∨ (it.get k = none ∧ k ∈ ps.map Prod.fst ∧ v ∈ ps.map Prod.snd)
  | _, _, [], h, k, v, hv => by simp only [Pops] at h; subst h; exact .inl hv
  | it, _, (k0, v0) :: ps, ⟨h0, h1⟩, k, v, hv => by
    rcases Pops.frame h1 k v hv with h | ⟨h, hk, hv'⟩
    · rcases PTrie.get_set_some h with h' | ⟨rfl, rfl⟩
      · exact .inl h'
      · exact .inr ⟨h0, List.mem_cons_self .., List.mem_cons_self ..⟩
    · rcases PTrie.get_set_cases it k0 v0 k with e | ⟨rfl, e⟩
      · rw [e] at h
        exact .inr ⟨h, List.mem_cons_of_mem _ hk, List.mem_cons_of_mem _ hv'⟩
      · rw [e] at h; cases h

/-- Growth of a native state: the nodes below its counter and its kernel objects are kept,
and readbacks pop the token list into empty item slots in order. -/
structure NGrow (x y : St) : Prop where
  nnext : x.nnext ≤ y.nnext
  nodes : ∀ j, j < x.nnext → y.nodes.get j = x.nodes.get j
  kernels : ∀ h o, x.objs.get h = some o → (∃ nm sc hd a b, o = .kernel nm sc hd a b) → y.objs.get h = some o
  pops : ∃ ps : List (Nat × NumV), x.tokens = ps.map Prod.snd ++ y.tokens ∧ Pops x.items ps y.items

namespace NGrow
variable {x y z : St}

theorem refl (x : St) : NGrow x x :=
  ⟨Nat.le_refl _, fun _ _ => rfl, fun _ _ h _ => h, ⟨[], rfl, rfl⟩⟩

theorem trans (h : NGrow x y) (h' : NGrow y z) : NGrow x z where
  nnext := Nat.le_trans h.nnext h'.nnext
  nodes j hj := (h'.nodes j (Nat.lt_of_lt_of_le hj h.nnext)).trans (h.nodes j hj)
  kernels k o ho hk := h'.kernels k o (h.kernels k o ho hk) hk
  pops := by
    obtain ⟨ps, h1, h2⟩ := h.pops
    obtain ⟨qs, h3, h4⟩ := h'.pops
    exact ⟨ps ++ qs, by rw [h1, h3, List.map_append, List.append_assoc], h2.append h4⟩

/-- Resolved kernel names are kept. -/
theorem kernelName (h : NGrow x y) (Ks : Host.Mlx.FfiEval.KernelSources) (k : Nat) (name : List Char)
    (hk : Host.Mlx.FfiEval.kernelName? Ks x k = some name) : Host.Mlx.FfiEval.kernelName? Ks y k = some name := by
  unfold Host.Mlx.FfiEval.kernelName? at hk ⊢
  cases ho : x.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    rw [ho] at hk
    cases o with
    | kernel nm sc hd a b =>
      rw [show y.obj? k = some (.kernel nm sc hd a b) from h.kernels k _ ho ⟨nm, sc, hd, a, b, rfl⟩]
      exact hk
    | _ => cases hk

theorem grows (h : NGrow x y) (Ks : Host.Mlx.FfiEval.KernelSources) : Host.Mlx.SimGraph.Grows Ks x y :=
  ⟨h.nodes, h.kernelName Ks⟩

/-- The item frame: every item of `y` was an item of `x` or a popped value at one of at most
as many fresh slots as values were popped. -/
theorem frame (h : NGrow x y) :
    ∃ popped, x.tokens = popped ++ y.tokens ∧ ∃ ks : List Nat, ks.length ≤ popped.length ∧
      ∀ k v, y.items.get k = some v → x.items.get k = some v ∨ (x.items.get k = none ∧ k ∈ ks ∧ v ∈ popped) := by
  obtain ⟨ps, h1, h2⟩ := h.pops
  exact ⟨ps.map Prod.snd, h1, ps.map Prod.fst, by simp, h2.frame⟩

/-- One pop: the empty slot that was filled is the only change of the items. -/
theorem single (h : NGrow x y) (hlen : x.tokens.length = y.tokens.length + 1) {k : Nat} {v : NumV}
    (hx : x.items.get k = none) (hy : y.items.get k = some v) : y.items = x.items.set k v := by
  obtain ⟨ps, h1, h2⟩ := h.pops
  have hl : ps.length = 1 := by
    have := congrArg List.length h1
    simp only [List.length_append, List.length_map] at this
    omega
  match ps, hl, h2 with
  | [(k', t)], _, ⟨_, h3⟩ =>
    have e : y.items = x.items.set k' t := h3
    rw [e] at hy ⊢
    rcases PTrie.get_set_some hy with h' | ⟨rfl, rfl⟩
    · rw [hx] at h'; cases h'
    · rfl

end NGrow

namespace NGrowCall

/-- Kernel objects (never replaced). -/
def isKernelObj : Obj → Bool
  | .kernel .. => true
  | _ => false

/-- Object slots from the handle counter on are empty. -/
def NInv (s : St) : Prop := ∀ h, s.next ≤ h → s.objs.get h = none

/-- Growth from `s` to an invariant state. -/
def Good (s s' : St) : Prop := NInv s' ∧ NGrow s s'

/-- One update: from an invariant state, an invariant state it grows to. -/
def Step1 (s s' : St) : Prop := NInv s → NInv s' ∧ NGrow s s'

variable {s₀ s s' s₁ s₂ : St}

theorem Good.refl (h : NInv s) : Good s s := ⟨h, NGrow.refl s⟩

theorem Good.snoc (h : Good s₀ s₁) (h1 : Step1 s₁ s₂) : Good s₀ s₂ :=
  let ⟨i, g⟩ := h1 h.1
  ⟨i, h.2.trans g⟩

theorem step_same (hn : s'.nnext = s.nnext) (hno : s'.nodes = s.nodes) (ho : s'.objs = s.objs)
    (ht : s'.tokens = s.tokens) (hi : s'.items = s.items) (hx : s.next ≤ s'.next) : Step1 s s' := fun hinv =>
  ⟨fun h hh => by rw [ho]; exact hinv h (Nat.le_trans hx hh),
    ⟨by omega, fun j _ => by rw [hno], fun k o hk _ => by rw [ho]; exact hk,
      ⟨[], by rw [ht]; rfl, by show s'.items = s.items; exact hi⟩⟩⟩

theorem step_addNode (nd : Node) : Step1 s (s.addNode nd).2 := fun hinv =>
  ⟨hinv, ⟨Nat.le_succ _, fun j hj => PTrie.get_set_ne' _ _ _ _ (by omega), fun _ _ hk _ => hk, ⟨[], rfl, rfl⟩⟩⟩

theorem step_newObj (o : Obj) : Step1 s (s.newObj o).2 := fun hinv =>
  ⟨fun h hh => by
      change s.next + 1 ≤ h at hh
      show (s.objs.set s.next o).get h = none
      rw [PTrie.get_set_ne' _ _ _ _ (by show h ≠ s.next; omega)]
      exact hinv h (by show s.next ≤ h; omega),
    ⟨Nat.le_refl _, fun _ _ => rfl, fun k o' hk _ => by
      have hne : k ≠ s.next := fun e => by rw [e, hinv s.next (Nat.le_refl _)] at hk; cases hk
      show (s.objs.set s.next o).get k = some o'
      rw [PTrie.get_set_ne' _ _ _ _ hne]; exact hk,
    ⟨[], rfl, rfl⟩⟩⟩

theorem step_setObj {k : Nat} {o0 : Obj} (hg : s.obj? k = some o0)
    (hk : isKernelObj o0 = false) (o : Obj) : Step1 s (s.setObj k o) := fun hinv =>
  have hlt : ¬ s.next ≤ k := fun hle => by
    have := hinv k hle
    rw [show s.obj? k = s.objs.get k from rfl, this] at hg; cases hg
  ⟨fun h hh => by
      show (s.objs.set k o).get h = none
      rw [PTrie.get_set_ne' _ _ _ _ (by intro e; subst e; exact hlt hh)]
      exact hinv h hh,
    ⟨Nat.le_refl _, fun _ _ => rfl, fun k' o' hk' hkk => by
      have hne : k' ≠ k := by
        rintro rfl
        rw [show s.obj? k' = s.objs.get k' from rfl, hk'] at hg
        cases hg
        obtain ⟨nm, sc, hd, a, b, rfl⟩ := hkk
        cases hk
      show (s.objs.set k o).get k' = some o'
      rw [PTrie.get_set_ne' _ _ _ _ hne]; exact hk',
    ⟨[], rfl, rfl⟩⟩⟩

theorem step_setArr (slot n : Nat) : Step1 s (s.setArr slot n).2 := by
  unfold St.setArr
  cases Nat.beq slot 0
  · exact step_same rfl rfl rfl rfl rfl (Nat.le_refl _)
  · exact step_same rfl rfl rfl rfl rfl (Nat.le_succ _)

theorem step_freeArr (h : Nat) : Step1 s (s.freeArr h) := by
  unfold St.freeArr
  cases Nat.beq h 0
  · exact step_same rfl rfl rfl rfl rfl (Nat.le_refl _)
  · exact step_same rfl rfl rfl rfl rfl (Nat.le_refl _)

theorem step_pop {k : Nat} {t : NumV} {ts : List NumV} (hk : s.items.get k = none) (ht : s.tokens = t :: ts) :
    Step1 s { s with tokens := ts, items := s.items.set k t } := fun hinv =>
  ⟨hinv, ⟨Nat.le_refl _, fun _ _ => rfl, fun _ _ h _ => h, ⟨[(k, t)], by rw [ht]; rfl, ⟨hk, rfl⟩⟩⟩⟩

theorem step_setVec (slot : Nat) (ns : List Nat) : Step1 s (setVec s slot ns).2 := by
  unfold setVec
  split
  · rename_i heq
    exact step_setObj heq rfl _
  · exact step_newObj _

/-! ## Updates after a growth -/

theorem Good.addNode (h : Good s₀ s₁) (nd : Node) : Good s₀ (s₁.addNode nd).2 := h.snoc (step_addNode nd)
theorem Good.newObj (h : Good s₀ s₁) (o : Obj) : Good s₀ (s₁.newObj o).2 := h.snoc (step_newObj o)
theorem Good.setObj (h : Good s₀ s₁) {k : Nat} {o0 : Obj} (hg : s₁.obj? k = some o0)
    (hk : isKernelObj o0 = false) (o : Obj) : Good s₀ (s₁.setObj k o) :=
  h.snoc (step_setObj hg hk o)
theorem Good.setArr (h : Good s₀ s₁) (slot n : Nat) : Good s₀ (s₁.setArr slot n).2 := h.snoc (step_setArr slot n)
theorem Good.freeArr (h : Good s₀ s₁) (k : Nat) : Good s₀ (s₁.freeArr k) := h.snoc (step_freeArr k)
theorem Good.setVec (h : Good s₀ s₁) (slot : Nat) (ns : List Nat) : Good s₀ (setVec s₁ slot ns).2 :=
  h.snoc (step_setVec slot ns)
theorem Good.pop (h : Good s₀ s₁) {k : Nat} {t : NumV} {ts : List NumV} (hk : s₁.items.get k = none)
    (ht : s₁.tokens = t :: ts) : Good s₀ { s₁ with tokens := ts, items := s₁.items.set k t } :=
  h.snoc (step_pop hk ht)
theorem Good.lit (h : Good s₀ s₁) {n nn wired : Nat} {nodes : PTrie Node} {arrs : PTrie Nat} {objs : PTrie Obj}
    {toks : List NumV} {files : List (List Char × Header)} {pend : List Pending} {errh : Option Arg}
    {arch : List Char} {ds : List (List Char × Nat)} {items : PTrie NumV}
    (hn : nn = s₁.nnext) (hno : nodes = s₁.nodes) (ho : objs = s₁.objs) (ht : toks = s₁.tokens)
    (hi : items = s₁.items) (hx : s₁.next ≤ n) :
    Good s₀ ⟨n, nodes, nn, arrs, objs, toks, files, pend, errh, arch, ds, wired, items⟩ :=
  h.snoc (step_same hn hno ho ht hi hx)

theorem Good.tracers : ∀ (s : St) (i : Nat) (sh : List (List Dim × Nat)), Good s₀ s →
    Good s₀ (closureApply.tracers s i sh).1
  | _, _, [], h => h
  | _, i, (shape, dt) :: r, h => Good.tracers _ (i + 1) r (h.addNode ⟨.tracer i, [], shape, dt⟩)

theorem Good.outs (kh : Nat) (xs : List Nat) (c : Cfg) : ∀ (s : St) (i : Nat) (os : List (List Dim × Nat)),
    Good s₀ s → Good s₀ (kernelApply.outs kh xs c s i os).1
  | _, _, [], h => h
  | _, i, (shape, dt) :: r, h => Good.outs kh xs c _ (i + 1) r (h.addNode ⟨.kernel kh c i, xs, shape, dt⟩)

/-! ## Concrete runs of machine computations -/

/-- Every concrete run of `m` ends in a result satisfying `Q`. -/
def AllC {α : Type} (Q : α → Prop) (m : Host.Ts.M α) : Prop :=
  ∀ C a C', interpC m.run C = some (a, C') → Q a

theorem AllC.pure {α : Type} {Q : α → Prop} {a : α} (h : Q a) : AllC Q (Host.Ts.M.pure a) := by
  intro C a' C' e
  have e' : some (a, C) = some (a', C') := e
  cases e'
  exact h

theorem AllC.bind {α β : Type} {P : α → Prop} {Q : β → Prop} {m : Host.Ts.M α} {f : α → Host.Ts.M β}
    (hm : Host.Ts.Sim.BufSim.Lawful m) (h : AllC P m) (hf : ∀ a, P a → AllC Q (f a)) :
    AllC Q (Host.Ts.M.bind m f) := by
  intro C b C' e
  have e' : interpC (m β fun a => (f a).run) C = some (b, C') := e
  rw [hm.2] at e'
  cases hr : interpC m.run C with
  | none => rw [hr] at e'; cases e'
  | some p =>
    rw [hr] at e'
    exact hf p.1 (h C p.1 p.2 hr) p.2 b C' e'

theorem AllC.bind' {α β : Type} {Q : β → Prop} {m : Host.Ts.M α} {f : α → Host.Ts.M β}
    (hm : Host.Ts.Sim.BufSim.Lawful m) (hf : ∀ a, AllC Q (f a)) : AllC Q (Host.Ts.M.bind m f) :=
  AllC.bind (P := fun _ => True) hm (fun _ _ _ _ => trivial) fun a _ => hf a

theorem AllC.cond {α : Type} {Q : α → Prop} (c : Bool) {m1 m2 : Host.Ts.M α} (h1 : AllC Q m1) (h2 : AllC Q m2) :
    AllC Q (bif c then m1 else m2) := by cases c <;> assumption

/-- Optional results whose state grew from `s₀`. -/
def OGood {β : Type} (s₀ : St) (f : β → St) : Option β → Prop := fun o => ∀ b, o = some b → Good s₀ (f b)

/-- Results of a native call whose state grew from `s₀`. -/
abbrev Res (s₀ : St) := OGood (β := St × Ret × List (Nat × Nat × List Byte)) s₀ Prod.fst

theorem AllC_none {β : Type} {f : β → St} : AllC (OGood s₀ f) (Host.Ts.M.pure none) :=
  AllC.pure fun _ e => by cases e

theorem AllC_some {β : Type} {f : β → St} {b : β} (h : Good s₀ (f b)) :
    AllC (OGood s₀ f) (Host.Ts.M.pure (some b)) :=
  AllC.pure fun _ e => by cases e; exact h

theorem AllC_ok {r : Ret} (h : Good s₀ s) : AllC (Res s₀) (ok s r) := AllC_some h
theorem AllC_okW {r : Ret} {ws : List (Nat × Nat × List Byte)} (h : Good s₀ s) : AllC (Res s₀) (okW s r ws) :=
  AllC_some h
theorem AllC_stuck : AllC (Res s₀) stuck := AllC_none

/-! ## Tactics -/

theorem pair_eq_fst {α β : Type} {e : α × β} {a : α} {b : β} (h : e = (a, b)) : a = e.1 := by rw [h]
theorem pair_eq_snd {α β : Type} {e : α × β} {a : α} {b : β} (h : e = (a, b)) : b = e.2 := by rw [h]

open Lean Meta Elab Tactic in
/-- Replace the components `a`, `b` of a hypothesis `e = (a, b)` (from `split` on
`let (a, b) := e`) by the projections of `e`. Fails when there is none. -/
elab "subst_pairs" : tactic => do
  let mut progress := false
  for _ in [0:64] do
    let g ← getMainGoal
    let found? ← g.withContext do
      for ld in (← getLCtx) do
        if ld.isImplementationDetail then continue
        let ty ← instantiateMVars ld.type
        if let some (_, _, rhs) := ty.eq? then
          if rhs.isAppOfArity ``Prod.mk 4 && (rhs.getArg! 2).isFVar && (rhs.getArg! 3).isFVar then
            return some ld.fvarId
      return none
    let some fv := found? | break
    let g ← g.rename fv `pair_eq_h
    replaceMainGoal [g]
    evalTactic (← `(tactic| (have hpa := pair_eq_fst $(mkIdent `pair_eq_h); have hpb := pair_eq_snd $(mkIdent `pair_eq_h); clear $(mkIdent `pair_eq_h); subst hpb; subst hpa)))
    progress := true
  unless progress do throwError "no pair equation"

open Lean Meta Elab Tactic in
/-- `Good.lit` on a goal `Good s₀ ⟨…⟩` whose state is a structure literal (a record update);
other states unify with a literal by structure eta, so the check is syntactic. -/
elab "good_lit" : tactic => do
  let t := (← instantiateMVars (← getMainTarget)).consumeMData
  unless t.isAppOfArity ``Good 2 && t.appArg!.consumeMData.isAppOf ``St.mk do throwError "not a literal state"
  evalTactic (← `(tactic| with_reducible refine Good.lit ?_ rfl rfl rfl rfl rfl (by omega)))

/-- One growth step of a state expression. -/
macro "good_step" : tactic => `(tactic| first
  | with_reducible exact Good.refl ‹_›
  | with_reducible refine Good.addNode ?_ _
  | with_reducible refine Good.newObj ?_ _
  | with_reducible refine Good.setArr ?_ _ _
  | with_reducible refine Good.freeArr ?_ _
  | with_reducible refine Good.setVec ?_ _ _
  | with_reducible refine Good.tracers _ _ _ ?_
  | with_reducible refine Good.outs _ _ _ _ _ _ ?_
  | good_lit
  | with_reducible refine Good.pop ?_ ?_ ?_
  | with_reducible refine Good.setObj ?_ (by with_reducible assumption) (by with_unfolding_all exact rfl) _)

/-- One step of a growth proof over a native computation, other than case splits. -/
macro "grow_head" : tactic => `(tactic| first
  | subst_pairs
  | with_reducible exact AllC_stuck
  | with_reducible exact AllC_none
  | with_reducible refine AllC_okW ?_
  | with_reducible refine AllC_ok ?_
  | with_reducible refine AllC_some ?_
  | with_reducible refine AllC.cond _ ?_ ?_
  | with_reducible assumption
  | good_step)

/-- One step of a growth proof over a native computation. -/
macro "grow_base" : tactic => `(tactic| first
  | grow_head
  | split
  | dsimp only)

open Lean Meta Elab Tactic in
/-- Fails unless the goal is an `AllC` goal; drops its annotations (for the dispatch tactics). -/
elab "allc_goal" : tactic => do
  let g ← getMainGoal
  let t := (← instantiateMVars (← g.getType)).consumeMData
  unless t.isAppOf ``AllC do throwError "not an AllC goal"
  replaceMainGoal [← g.replaceTargetDefEq t]

/-! ## The native computations -/

theorem opOut_g (h : Good s₀ s) (o : Arg) (p : Prim) (ins : List Nat) : AllC (Res s₀) (opOut s o p ins) := by
  unfold opOut
  repeat' (first
    | with_reducible refine AllC.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun _ => ?_
    | grow_base)

theorem leafOut_g (h : Good s₀ s) (o : Arg) (p : Prim) (sh : List Dim) (d : Nat) :
    AllC (Res s₀) (leafOut s o p sh d) := by
  unfold leafOut
  repeat' grow_base

theorem replayOrder_g (cls : Nat) : ∀ (s : St) (m : List (Nat × Nat)) (ns : List Nat), Good s₀ s →
    AllC (OGood s₀ Prod.fst) (replayOrder s cls m ns)
  | _, _, [], h => AllC_some h
  | s, m, n :: ns, h => by
    unfold replayOrder
    repeat' (first
      | with_reducible refine replayOrder_g cls _ _ ns ?_
      | with_reducible refine AllC.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun _ => ?_
      | grow_base)

theorem replay_g (h : Good s₀ s) (cls : Nat) (t : Trace) (xs : List Nat) :
    AllC (OGood s₀ Prod.fst) (replay s cls t xs) := by
  unfold replay
  refine AllC.bind (Host.Ts.Sim.NativeLawful.replayOrder_l _ _ _ _) (replayOrder_g cls s _ _ h) fun r hr => ?_
  rcases r with _ | ⟨s', m'⟩
  · exact AllC_none
  · exact AllC_some (hr _ rfl)

theorem applyDone_g (h : Good s₀ s) (cls b off slot : Nat) (t : Trace) (xs : List Nat) :
    AllC (Res s₀) (applyDone s cls b off slot t xs) := by
  unfold applyDone
  refine AllC.bind (Host.Ts.Sim.NativeLawful.replay_l _ _ _ _) (replay_g h cls t xs) fun r hr => ?_
  rcases r with _ | ⟨s', outs⟩
  · exact AllC_stuck
  · have h' : Good s₀ s' := hr _ rfl
    dsimp only
    repeat' grow_base

theorem closureApply_g (h : Good s₀ s) (o c v : Arg) : AllC (Res s₀) (closureApply s o c v) := by
  unfold closureApply
  repeat' (first
    | with_reducible refine AllC.bind' (Host.Ts.Sim.NativeLawful.findTrace_l _ _ _ _) fun _ => ?_
    | with_reducible refine applyDone_g ?_ _ _ _ _ _ _
    | grow_base)

theorem kernelApply_g (h : Good s₀ s) (o k v c : Arg) : AllC (Res s₀) (kernelApply s o k v c) := by
  unfold kernelApply
  repeat' grow_base

theorem obj_of_bind {s : St} {a : Option Nat} {k : Nat} {o : Obj}
    (e : (a.bind fun h => (s.obj? h).map (h, ·)) = some (k, o)) : s.obj? k = some o := by
  cases a with
  | none => cases e
  | some h =>
    cases hs : s.obj? h with
    | none => simp [hs] at e
    | some o' =>
      simp only [Option.bind_some, hs, Option.map_some, Option.some.injEq, Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      exact hs

theorem cfgUpdate_g (h : Good s₀ s) (c : Arg) (f : Cfg → Option Cfg) : AllC (Res s₀) (cfgUpdate s c f) := by
  unfold cfgUpdate
  split
  · rename_i heq
    have hg := obj_of_bind heq
    repeat' grow_base
  · exact AllC_stuck

theorem mapGet_g (h : Good s₀ s) (o m k : Arg) : AllC (Res s₀) (mapGet s o m k) := by
  unfold mapGet
  repeat' grow_base

theorem loadSafetensors_g (h : Good s₀ s) (a b c : Arg) : AllC (Res s₀) (loadSafetensors s a b c) := by
  unfold loadSafetensors
  repeat' grow_base

theorem traceBack_g (h : Good s₀ s) (a : Arg) : AllC (Res s₀) (traceBack s a) := by
  unfold traceBack
  repeat' (first
    | with_reducible refine applyDone_g ?_ _ _ _ _ _ _
    | grow_base)

set_option maxHeartbeats 4000000 in
/-- **Every mlx call grows the native state.** -/
theorem call_g (hi : NInv s) (name : Name) (args : List Arg) : AllC (Res s) (call s name args) := by
  have h0 : Good s s := Good.refl hi
  unfold call
  cases Host.Mlx.Ffi.symOf name with
  | none => exact AllC_stuck
  | some x =>
    dsimp only
    induction x <;> repeat' (first
      | (allc_goal; reduce_call)
      | (allc_goal; case_call)
      | contradiction
      | with_reducible exact closureApply_g h0 _ _ _
      | with_reducible exact cfgUpdate_g h0 _ _
      | with_reducible exact kernelApply_g h0 _ _ _ _
      | with_reducible exact mapGet_g h0 _ _ _
      | with_reducible exact loadSafetensors_g h0 _ _ _
      | with_reducible exact opOut_g h0 _ _ _
      | with_reducible exact leafOut_g h0 _ _ _ _
      | grow_head
      | split_small
      | dsimp only)

/-- Every trace continuation grows the native state. -/
theorem back_g (hi : NInv s) (a : Arg) : AllC (Res s) (back s a) := traceBack_g (Good.refl hi) a

end NGrowCall
end Host.Mlx.Ffi

namespace Host.Load
open Host.Ts Host.Mlx.Ffi.NGrowCall

/-- Results of a load-world native call whose mlx state grew from `y`'s. -/
def LRes (y : LSt) : Option (LSt × Ret × List (Nat × Nat × List Byte)) → Prop :=
  fun o => ∀ y' r ws, o = some (y', r, ws) → Good y.mlx y'.mlx

theorem AllC_okH {y : LSt} (hi : NInv y.mlx) (h : HostSt) (r : Ret) : AllC (LRes y) (okH y h r) :=
  AllC.pure fun _ _ _ e => by cases e; exact Good.refl hi

theorem AllC_stuckH {y : LSt} : AllC (LRes y) stuckH := AllC.pure fun _ _ _ e => by cases e

theorem hostCall_g {y : LSt} (hi : NInv y.mlx) (name : Name) (args : List Arg) :
    AllC (LRes y) (hostCall y name args) := by
  unfold hostCall pseudoCall msgSend newPtr
  repeat' (first
    | with_reducible exact AllC_okH hi _ _
    | with_reducible exact AllC_stuckH
    | with_reducible refine AllC.cond _ ?_ ?_
    | split
    | dsimp only)

theorem lift_g {y : LSt} {m : Host.Ts.M (Option (Host.Mlx.Ffi.St × Ret × List (Nat × Nat × List Byte)))}
    (hm : Host.Ts.Sim.BufSim.Lawful m) (h : AllC (Res y.mlx) m) :
    AllC (LRes y) (Host.Ts.M.bind m fun
      | some (m, r, ws) => .pure (some ({ y with mlx := m }, r, ws))
      | none => .pure none) := by
  refine AllC.bind hm h fun r hr => ?_
  rcases r with _ | ⟨m', r', ws'⟩
  · exact AllC.pure fun _ _ _ e => by cases e
  · exact AllC.pure fun _ _ _ e => by cases e; exact hr _ rfl

/-- **Every load-world native call grows the mlx state.** -/
theorem call_g {y : LSt} (hi : NInv y.mlx) (name : Name) (args : List Arg) : AllC (LRes y) (call y name args) := by
  unfold call
  exact AllC.cond _ (lift_g (Host.Ts.Sim.NativeLawful.mlx_call_l _ _ _) (Host.Mlx.Ffi.NGrowCall.call_g hi name args))
    (hostCall_g hi name args)

/-- **Every load-world trace continuation grows the mlx state.** -/
theorem back_g {y : LSt} (hi : NInv y.mlx) (a : Arg) : AllC (LRes y) (back y a) := by
  unfold back
  exact lift_g (Host.Ts.Sim.NativeLawful.traceBack_l _ _) (Host.Mlx.Ffi.NGrowCall.back_g hi a)

end Host.Load

