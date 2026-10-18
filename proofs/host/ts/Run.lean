import host.ts.Machine
namespace Host.Ts

/-! # Number servers, runs, and the symbolic simulation theorem

The machine state holds numbers as `NumV.lit` (binary64 constants) or
`NumV.ref i` (entry `i` of a number table owned by a server). The machine
never reads a table: every operation with a referenced operand is a
request in `Free`. A *concrete* server keeps binary64 values and answers
by computing; a *symbolic* server keeps expressions over symbolic
positions (`SymE.var`) and answers comparisons from an oracle list,
consumed in order and checked against the query.

`run_sim`: if the symbolic run succeeds and every oracle answer is the
binary64 answer at valuation `ρ`, the concrete run from the same machine
state with the instantiated table (`map (eval ρ)`) succeeds with the same
final machine state (trace, heap, control) and the instantiated final
table. This is parametricity by construction: the proof never inspects
the machine, only the request protocol.

Kernel cost: the run loop, the servers and the state rebuild are the
per-step overhead of every check, so they are written with recursors
directly (`Nat.rec`, `Free.rec`, `Ctl.rec`, …) and closed minor premises:
unfolding one instantiates a handful of nodes, where a `match` or
structural recursion instantiates its whole body (every arm mentions the
outer variables) and `brecOn` builds `below` tuples. The code generator
does not support most recursors, so native evaluation uses the equivalent
`match` definitions (`implemented_by`); kernel checks never run them, and
the equation lemmas below are `rfl`. -/

/-! ## Concrete server -/

structure CSrv where
  tab : List F64

def CSrv.val (c : CSrv) : NumV → Option F64
  | .lit x => some x
  | .ref i => nth? c.tab i

def interpCImpl {α : Type} : Free α → CSrv → Option (α × CSrv)
  | .pure a, c => some (a, c)
  | .fail _, _ => none
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => interpCImpl (k c.tab.length) ⟨c.tab ++ [F64.bin op x y]⟩
    | _, _ => none
  | .un op a k, c => match c.val a with
    | some x => interpCImpl (k c.tab.length) ⟨c.tab ++ [F64.un op x]⟩
    | none => none
  | .test op a b k, c => match c.val a, c.val b with
    | some x, some y => interpCImpl (k (F64.test op x y)) c
    | _, _ => none
  | .conc a k, c => match c.val a with
    | some x => interpCImpl (k x) c
    | none => none

@[implemented_by interpCImpl]
def interpC {α : Type} (t : Free α) : CSrv → Option (α × CSrv) :=
  Free.rec (motive := fun _ => CSrv → Option (α × CSrv))
    (fun a c => some (a, c))
    (fun _ _ => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => ih c.tab.length ⟨c.tab ++ [F64.bin op x y]⟩
      | _, _ => none)
    (fun op a _ ih c => match c.val a with
      | some x => ih c.tab.length ⟨c.tab ++ [F64.un op x]⟩
      | none => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => ih (F64.test op x y) c
      | _, _ => none)
    (fun a _ ih c => match c.val a with
      | some x => ih x c
      | none => none) t

section
variable {α : Type}
theorem interpC_pure (a : α) (c : CSrv) : interpC (.pure a) c = some (a, c) := rfl
theorem interpC_fail (m : String) (c : CSrv) : interpC (α := α) (.fail m) c = none := rfl
theorem interpC_bin (op : NBin) (a b : NumV) (k : Nat → Free α) (c : CSrv) :
    interpC (.bin op a b k) c = match c.val a, c.val b with
      | some x, some y => interpC (k c.tab.length) ⟨c.tab ++ [F64.bin op x y]⟩
      | _, _ => none := rfl
theorem interpC_un (op : NUn) (a : NumV) (k : Nat → Free α) (c : CSrv) :
    interpC (.un op a k) c = match c.val a with
      | some x => interpC (k c.tab.length) ⟨c.tab ++ [F64.un op x]⟩
      | none => none := rfl
theorem interpC_test (op : NTest) (a b : NumV) (k : Bool → Free α) (c : CSrv) :
    interpC (.test op a b k) c = match c.val a, c.val b with
      | some x, some y => interpC (k (F64.test op x y)) c
      | _, _ => none := rfl
theorem interpC_conc (a : NumV) (k : F64 → Free α) (c : CSrv) :
    interpC (.conc a k) c = match c.val a with
      | some x => interpC (k x) c
      | none => none := rfl
end

/-! ## Symbolic server -/

inductive SymE where
  | lit (x : F64)
  | var (i : Nat)
  | bin (op : NBin) (a b : SymE)
  | un (op : NUn) (a : SymE)
deriving DecidableEq, Repr

def SymE.eval (ρ : Nat → F64) : SymE → F64
  | .lit x => x
  | .var i => ρ i
  | .bin op a b => F64.bin op (a.eval ρ) (b.eval ρ)
  | .un op a => F64.un op (a.eval ρ)

/-- An oracle entry: the query `op a b` and its answer. -/
structure Ans where
  op : NTest
  a : SymE
  b : SymE
  r : Bool
deriving DecidableEq, Repr

structure SSrv where
  tab : List SymE
  oracle : List Ans

def SSrv.val (c : SSrv) : NumV → Option SymE
  | .lit x => some (.lit x)
  | .ref i => nth? c.tab i

/-- The oracle's next answer, if it is for query `op x y`. -/
def SSrv.answer (c : SSrv) (op : NTest) (x y : SymE) : Option (Bool × SSrv) :=
  match c.oracle with
  | q :: o => bif decide (q.op = op ∧ q.a = x ∧ q.b = y) then some (q.r, { c with oracle := o }) else none
  | [] => none

def interpSImpl {α : Type} : Free α → SSrv → Option (α × SSrv)
  | .pure a, c => some (a, c)
  | .fail _, _ => none
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => interpSImpl (k c.tab.length) { c with tab := c.tab ++ [.bin op x y] }
    | _, _ => none
  | .un op a k, c => match c.val a with
    | some x => interpSImpl (k c.tab.length) { c with tab := c.tab ++ [.un op x] }
    | none => none
  | .test op a b k, c => match c.val a, c.val b with
    | some x, some y => match c.answer op x y with
      | some (r, c') => interpSImpl (k r) c'
      | none => none
    | _, _ => none
  | .conc a k, c => match c.val a with
    | some (.lit x) => interpSImpl (k x) c
    | _ => none

@[implemented_by interpSImpl]
def interpS {α : Type} (t : Free α) : SSrv → Option (α × SSrv) :=
  Free.rec (motive := fun _ => SSrv → Option (α × SSrv))
    (fun a c => some (a, c))
    (fun _ _ => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => ih c.tab.length { c with tab := c.tab ++ [.bin op x y] }
      | _, _ => none)
    (fun op a _ ih c => match c.val a with
      | some x => ih c.tab.length { c with tab := c.tab ++ [.un op x] }
      | none => none)
    (fun op a b _ ih c => match c.val a, c.val b with
      | some x, some y => match c.answer op x y with
        | some (r, c') => ih r c'
        | none => none
      | _, _ => none)
    (fun a _ ih c => match c.val a with
      | some (.lit x) => ih x c
      | _ => none) t

section
variable {α : Type}
theorem interpS_pure (a : α) (c : SSrv) : interpS (.pure a) c = some (a, c) := rfl
theorem interpS_fail (m : String) (c : SSrv) : interpS (α := α) (.fail m) c = none := rfl
theorem interpS_bin (op : NBin) (a b : NumV) (k : Nat → Free α) (c : SSrv) :
    interpS (.bin op a b k) c = match c.val a, c.val b with
      | some x, some y => interpS (k c.tab.length) { c with tab := c.tab ++ [.bin op x y] }
      | _, _ => none := rfl
theorem interpS_un (op : NUn) (a : NumV) (k : Nat → Free α) (c : SSrv) :
    interpS (.un op a k) c = match c.val a with
      | some x => interpS (k c.tab.length) { c with tab := c.tab ++ [.un op x] }
      | none => none := rfl
theorem interpS_test (op : NTest) (a b : NumV) (k : Bool → Free α) (c : SSrv) :
    interpS (.test op a b k) c = match c.val a, c.val b with
      | some x, some y => match c.answer op x y with
        | some (r, c') => interpS (k r) c'
        | none => none
      | _, _ => none := rfl
theorem interpS_conc (a : NumV) (k : F64 → Free α) (c : SSrv) :
    interpS (.conc a k) c = match c.val a with
      | some (.lit x) => interpS (k x) c
      | _ => none := rfl
end

/-! ## Runs -/

/-! Rebuild a state from the weak head normal forms of its fields. The
kernel evaluates lazily and does not reuse reductions of projection chains:
a field a step leaves unchanged would otherwise become
`St.heap (St.mk (St.heap (St.mk …)))`, re-reduced at every access, which
makes runs quadratic. Each level forces one field with its recursor and
passes the rest on as arguments to closed minor premises, so kernel
instantiation copies a few arguments, not a nest of closures. Natively a
rebuild is the identity. -/
section
variable {S β : Type}

noncomputable def rb6 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (j : List Job) (f : S) (t : List Event)
    (ss : List (Nat × Val)) (k : St S → β) : β :=
  List.rec (motive := fun _ => PTrie HObj → Nat → Ctl → List Frame → List Job → S → List Event → (St S → β) → β)
    (fun h nx c st j f t k => k ⟨h, nx, c, st, ⟨j, f, t, []⟩⟩)
    (fun a r _ h nx c st j f t k => k ⟨h, nx, c, st, ⟨j, f, t, a :: r⟩⟩) ss h nx c st j f t k

noncomputable def rb5 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (j : List Job) (f : S) (t : List Event)
    (ss : List (Nat × Val)) (k : St S → β) : β :=
  List.rec (motive := fun _ => PTrie HObj → Nat → Ctl → List Frame → List Job → S → List (Nat × Val) → (St S → β) → β)
    (fun h nx c st j f ss k => rb6 h nx c st j f [] ss k)
    (fun a r _ h nx c st j f ss k => rb6 h nx c st j f (a :: r) ss k) t h nx c st j f ss k

noncomputable def rb4 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (j : List Job) (f : S) (t : List Event)
    (ss : List (Nat × Val)) (k : St S → β) : β :=
  List.rec (motive := fun _ => PTrie HObj → Nat → Ctl → List Frame → S → List Event → List (Nat × Val) → (St S → β) → β)
    (fun h nx c st f t ss k => rb5 h nx c st [] f t ss k)
    (fun a r _ h nx c st f t ss k => rb5 h nx c st (a :: r) f t ss k) j h nx c st f t ss k

noncomputable def rb3 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  List.rec (motive := fun _ => PTrie HObj → Nat → Ctl → Aux S → (St S → β) → β)
    (fun h nx c ax k => rb4 h nx c [] ax.jobs ax.ffi ax.trace ax.stores k)
    (fun a r _ h nx c ax k => rb4 h nx c (a :: r) ax.jobs ax.ffi ax.trace ax.stores k) st h nx c ax k

noncomputable def rb2 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  Nat.rec (motive := fun _ => PTrie HObj → Ctl → List Frame → Aux S → (St S → β) → β)
    (fun h c st ax k => rb3 h 0 c st ax k)
    (fun n _ h c st ax k => rb3 h (Nat.succ n) c st ax k) nx h c st ax k

def rb1Impl (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  k ⟨h, nx, c, st, ax⟩

@[implemented_by rb1Impl]
def rb1 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  PTrie.rec (motive := fun _ => Nat → Ctl → List Frame → Aux S → (St S → β) → β)
    (fun r nx c st ax k => Trie.rec (motive := fun _ => Nat → Ctl → List Frame → Aux S → (St S → β) → β)
      (fun nx c st ax k => rb2 ⟨.nil⟩ nx c st ax k)
      (fun v a b c2 d _ _ _ _ nx c st ax k => rb2 ⟨.node v a b c2 d⟩ nx c st ax k) r nx c st ax k) h nx c st ax k

def rb0Impl (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  k ⟨h, nx, c, st, ax⟩

@[implemented_by rb0Impl]
def rb0 (h : PTrie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) (k : St S → β) : β :=
  Ctl.rec (motive := fun _ => PTrie HObj → Nat → List Frame → Aux S → (St S → β) → β)
    (fun e env h nx st ax k => rb1 h nx (.ev e env) st ax k)
    (fun x env h nx st ax k => rb1 h nx (.ex x env) st ax k)
    (fun v h nx st ax k => rb1 h nx (.ret v) st ax k)
    (fun a h nx st ax k => rb1 h nx (.abr a) st ax k)
    (fun f t as h nx st ax k => rb1 h nx (.call f t as) st ax k)
    (fun f as nt h nx st ax k => rb1 h nx (.construct f as nt) st ax k)
    (fun p v e m d h nx st ax k => rb1 h nx (.bind p v e m d) st ax k)
    (fun h nx st ax k => rb1 h nx .short st ax k)
    (fun x h nx st ax k => rb1 h nx (.halt x) st ax k) c h nx st ax k

def St.rebuild (s : St S) (k : St S → β) : β := rb0 s.heap s.next s.ctl s.stack s.aux k

theorem St.rebuild_eq (s : St S) (k : St S → β) : s.rebuild k = k s := by
  obtain ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := s
  have e6 : ∀ h nx c st j f t ss, rb6 h nx c st j f t ss k = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st j f t ss; cases ss <;> rfl
  have e5 : ∀ h nx c st j f t ss, rb5 h nx c st j f t ss k = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st j f t ss; cases t <;> exact e6 ..
  have e4 : ∀ h nx c st j f t ss, rb4 h nx c st j f t ss k = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st j f t ss; cases j <;> exact e5 ..
  have e3 : ∀ h nx c st ax, rb3 h nx c st ax k = k ⟨h, nx, c, st, ax⟩ := by
    intro h nx c st ax; cases st <;> exact e4 ..
  have e2 : ∀ h nx c st ax, rb2 h nx c st ax k = k ⟨h, nx, c, st, ax⟩ := by
    intro h nx c st ax; cases nx <;> exact e3 ..
  have e1 : ∀ h nx c st ax, rb1 h nx c st ax k = k ⟨h, nx, c, st, ax⟩ := by
    intro h nx c st ax; obtain ⟨r⟩ := h; cases r <;> exact e2 ..
  have e0 : ∀ h nx c st ax, rb0 h nx c st ax k = k ⟨h, nx, c, st, ax⟩ := by
    intro h nx c st ax; cases c <;> exact e1 ..
  exact e0 _ _ _ _ _

end

def isHaltImpl : Ctl → Bool
  | .halt _ => true
  | _ => false

@[implemented_by isHaltImpl]
def isHalt (c : Ctl) : Bool :=
  Ctl.rec (motive := fun _ => Bool) (fun _ _ => false) (fun _ _ => false) (fun _ => false) (fun _ => false)
    (fun _ _ _ => false) (fun _ _ _ => false) (fun _ _ _ _ _ => false) false (fun _ => true) c

theorem isHalt_halt (c : Comp) : isHalt (.halt c) = true := rfl

/-- One step of a run: stop at `halt`, else step and rebuild. -/
def runStep (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv))
    (ih : St F.S → Srv → Option (St F.S × Srv)) (s : St F.S) (c : Srv) : Option (St F.S × Srv) :=
  bif isHalt s.ctl then some (s, c) else
    match interp (step F s).run c with
    | some (s', c') => s'.rebuild fun s' => ih s' c'
    | none => none

/-- Run with a number server (`interp`), at most `n` steps. -/
def runWith (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv)) (n : Nat) :
    St F.S → Srv → Option (St F.S × Srv) :=
  Nat.rec (motive := fun _ => St F.S → Srv → Option (St F.S × Srv)) (fun s c => some (s, c))
    (fun _ ih => runStep F interp ih) n

section
variable (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv))
theorem runWith_zero (s : St F.S) (c : Srv) : runWith F interp 0 s c = some (s, c) := rfl
theorem runWith_succ (n : Nat) (s : St F.S) (c : Srv) :
    runWith F interp (n + 1) s c = bif isHalt s.ctl then some (s, c) else
      match interp (step F s).run c with
      | some (s', c') => s'.rebuild fun s' => runWith F interp n s' c'
      | none => none := rfl
end

def runC (F : Ffi) : Nat → St F.S → CSrv → Option (St F.S × CSrv) := runWith F interpC
def runS (F : Ffi) : Nat → St F.S → SSrv → Option (St F.S × SSrv) := runWith F interpS

/-! ## Simulation -/

/-- Every oracle answer is the binary64 answer at `ρ`. -/
def Good (ρ : Nat → F64) (o : List Ans) : Prop :=
  ∀ q ∈ o, F64.test q.op (q.a.eval ρ) (q.b.eval ρ) = q.r

/-- The concrete table instantiates the symbolic one, and the oracle is
correct at `ρ`. -/
def Inst (ρ : Nat → F64) (S : SSrv) (C : CSrv) : Prop :=
  C.tab = S.tab.map (SymE.eval ρ) ∧ Good ρ S.oracle

theorem nth?_map {α β : Type} (f : α → β) : ∀ (l : List α) (i : Nat), nth? (l.map f) i = (nth? l i).map f
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: l, i + 1 => nth?_map f l i

theorem val_inst {ρ : Nat → F64} {S : SSrv} {C : CSrv} (h : C.tab = S.tab.map (SymE.eval ρ)) (a : NumV) :
    C.val a = (S.val a).map (SymE.eval ρ) := by
  cases a with
  | lit x => rfl
  | ref i => simp only [CSrv.val, SSrv.val, h, nth?_map]

theorem push_inst {ρ : Nat → F64} {S : SSrv} {C : CSrv} (hi : Inst ρ S C) (e : SymE) :
    Inst ρ { S with tab := S.tab ++ [e] } ⟨C.tab ++ [e.eval ρ]⟩ :=
  ⟨by simp [hi.1], hi.2⟩

/-- A correct oracle answer is the binary64 answer, and the rest stays correct. -/
theorem answer_inst {ρ : Nat → F64} {S S' : SSrv} {C : CSrv} {op : NTest} {x y : SymE} {r : Bool}
    (hi : Inst ρ S C) (h : S.answer op x y = some (r, S')) :
    F64.test op (x.eval ρ) (y.eval ρ) = r ∧ Inst ρ S' C := by
  unfold SSrv.answer at h
  match ho : S.oracle, h with
  | [], h => simp at h
  | q :: o, h =>
    by_cases hq : q.op = op ∧ q.a = x ∧ q.b = y
    · simp only [hq, and_self, decide_true, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      have hg := hi.2 q (by rw [ho]; exact List.mem_cons_self ..)
      obtain ⟨h1, h2, h3⟩ := hq
      refine ⟨by rw [← h1, ← h2, ← h3, hg], hi.1, fun q' m => hi.2 q' (by rw [ho]; exact List.mem_cons_of_mem _ m)⟩
    · simp [hq] at h

theorem interp_sim {α : Type} (ρ : Nat → F64) (t : Free α) :
    ∀ (S : SSrv) (C : CSrv) (a : α) (S' : SSrv), Inst ρ S C → interpS t S = some (a, S') →
      ∃ C', interpC t C = some (a, C') ∧ Inst ρ S' C' := by
  induction t with
  | pure x =>
    intro S C a S' hi h
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨C, rfl, hi⟩
  | fail m => intro S C a S' _ h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S C a S' hi h
    have hlen : C.tab.length = S.tab.length := by rw [hi.1, List.length_map]
    match hx : S.val x, hy : S.val y with
    | some ex, some ey =>
      simp only [interpS_bin, hx, hy] at h
      obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ (push_inst hi (.bin op ex ey)) h
      refine ⟨C', ?_, h2⟩
      simp only [interpC_bin, val_inst hi.1, hx, hy, Option.map_some, hlen]
      simpa [SymE.eval] using h1
    | none, _ => simp [interpS_bin, hx] at h
    | some _, none => simp [interpS_bin, hx, hy] at h
  | un op x k ih =>
    intro S C a S' hi h
    have hlen : C.tab.length = S.tab.length := by rw [hi.1, List.length_map]
    match hx : S.val x with
    | some ex =>
      simp only [interpS_un, hx] at h
      obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ (push_inst hi (.un op ex)) h
      refine ⟨C', ?_, h2⟩
      simp only [interpC_un, val_inst hi.1, hx, Option.map_some, hlen]
      simpa [SymE.eval] using h1
    | none => simp [interpS_un, hx] at h
  | test op x y k ih =>
    intro S C a S' hi h
    match hx : S.val x, hy : S.val y with
    | none, _ => simp [interpS_test, hx] at h
    | some _, none => simp [interpS_test, hx, hy] at h
    | some ex, some ey =>
      simp only [interpS_test, hx, hy] at h
      match ha : S.answer op ex ey with
      | none => simp [ha] at h
      | some (r, S1) =>
        simp only [ha] at h
        obtain ⟨hr, hi1⟩ := answer_inst hi ha
        obtain ⟨C', hc1, hc2⟩ := ih r S1 C a S' hi1 h
        refine ⟨C', ?_, hc2⟩
        simp only [interpC_test, val_inst hi.1, hx, hy, Option.map_some, hr]
        exact hc1
  | conc x k ih =>
    intro S C a S' hi h
    cases hx : S.val x with
    | none => simp [interpS_conc, hx] at h
    | some e =>
      cases e with
      | lit v =>
        simp only [interpS_conc, hx] at h
        obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ hi h
        exact ⟨C', by simp only [interpC_conc, val_inst hi.1, hx, Option.map_some, SymE.eval]; exact h1, h2⟩
      | _ => simp [interpS_conc, hx] at h

/-- **Simulation.** A symbolic run whose oracle answers are correct at `ρ`
is the concrete run on the instantiated table: same fuel, same final
machine state (control, heap, FFI state and trace), instantiated table. -/
theorem run_sim (F : Ffi) (ρ : Nat → F64) :
    ∀ (n : Nat) (s s' : St F.S) (S S' : SSrv) (C : CSrv), Inst ρ S C → runS F n s S = some (s', S') →
      ∃ C', runC F n s C = some (s', C') ∧ Inst ρ S' C' := by
  intro n
  induction n with
  | zero =>
    intro s s' S S' C hi h
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨C, rfl, hi⟩
  | succ n ih =>
    intro s s' S S' C hi h
    cases hh : isHalt s.ctl
    · simp only [runS, runWith_succ, hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        obtain ⟨C1, hc, hi1⟩ := interp_sim ρ _ S C s1 S1 hi hs
        obtain ⟨C', h1, h2⟩ := ih s1 s' S1 S' C1 hi1 h
        exact ⟨C', by simp only [runC, runWith_succ, hh, Bool.cond_false, hc, St.rebuild_eq]; exact h1, h2⟩
    · simp only [runS, runWith_succ, hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨C, by simp [runC, runWith_succ, hh], hi⟩

end Host.Ts

namespace Host.Ts

/-- `run_sim` from a booted (optional) initial state. -/
theorem boot_sim (F : Ffi) (ρ : Nat → F64) (b : Option (St F.S)) (n : Nat) (S0 : SSrv) (C0 : CSrv)
    (hi : Inst ρ S0 C0) (s' : St F.S) (S' : SSrv) :
    (b.bind fun s => runS F n s S0) = some (s', S') →
      ∃ C', (b.bind fun s => runC F n s C0) = some (s', C') ∧ Inst ρ S' C' := by
  cases b with
  | none => intro h; simp [Option.bind] at h
  | some s0 => intro h; exact run_sim F ρ n s0 s' S0 S' C0 hi h

end Host.Ts
