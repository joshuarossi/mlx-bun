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
the machine, only the request protocol. -/

/-! ## Concrete server -/

structure CSrv where
  tab : List F64

def CSrv.val (c : CSrv) : NumV → Option F64
  | .lit x => some x
  | .ref i => nth? c.tab i

def interpC {α : Type} : Free α → CSrv → Option (α × CSrv)
  | .pure a, c => some (a, c)
  | .fail _, _ => none
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => interpC (k c.tab.length) ⟨c.tab ++ [F64.bin op x y]⟩
    | _, _ => none
  | .un op a k, c => match c.val a with
    | some x => interpC (k c.tab.length) ⟨c.tab ++ [F64.un op x]⟩
    | none => none
  | .test op a b k, c => match c.val a, c.val b with
    | some x, some y => interpC (k (F64.test op x y)) c
    | _, _ => none
  | .conc a k, c => match c.val a with
    | some x => interpC (k x) c
    | none => none

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

def interpS {α : Type} : Free α → SSrv → Option (α × SSrv)
  | .pure a, c => some (a, c)
  | .fail _, _ => none
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => interpS (k c.tab.length) { c with tab := c.tab ++ [.bin op x y] }
    | _, _ => none
  | .un op a k, c => match c.val a with
    | some x => interpS (k c.tab.length) { c with tab := c.tab ++ [.un op x] }
    | none => none
  | .test op a b k, c => match c.val a, c.val b, c.oracle with
    | some x, some y, q :: o => bif decide (q.op = op ∧ q.a = x ∧ q.b = y) then interpS (k q.r) { c with oracle := o } else none
    | _, _, _ => none
  | .conc a k, c => match c.val a with
    | some (.lit x) => interpS (k x) c
    | _ => none

/-! ## Runs -/

/-! Rebuild a state from the weak head normal forms of its fields. The
kernel evaluates lazily and does not reuse reductions of projection chains:
a field a step leaves unchanged would otherwise become
`St.heap (St.mk (St.heap (St.mk …)))`, re-reduced at every access, which
makes runs quadratic. Each level is a small named function: kernel
instantiation then copies a few arguments, not a nest of closures. -/
section
variable {S β : Type} (k : St S → β)

def rb6 (h : Trie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (j : List Job) (f : S) (t : List Event) :
    List (Nat × Val) → β
  | [] => k ⟨h, nx, c, st, ⟨j, f, t, []⟩⟩
  | a :: r => k ⟨h, nx, c, st, ⟨j, f, t, a :: r⟩⟩

def rb5 (h : Trie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (j : List Job) (f : S) (ss : List (Nat × Val)) :
    List Event → β
  | [] => rb6 k h nx c st j f [] ss
  | a :: r => rb6 k h nx c st j f (a :: r) ss

def rb4 (h : Trie HObj) (nx : Nat) (c : Ctl) (st : List Frame) (f : S) (t : List Event) (ss : List (Nat × Val)) :
    List Job → β
  | [] => rb5 k h nx c st [] f ss t
  | a :: r => rb5 k h nx c st (a :: r) f ss t

def rb3 (h : Trie HObj) (nx : Nat) (c : Ctl) (ax : Aux S) : List Frame → β
  | [] => rb4 k h nx c [] ax.ffi ax.trace ax.stores ax.jobs
  | a :: r => rb4 k h nx c (a :: r) ax.ffi ax.trace ax.stores ax.jobs

def rb2 (h : Trie HObj) (c : Ctl) (st : List Frame) (ax : Aux S) : Nat → β
  | 0 => rb3 k h 0 c ax st
  | n + 1 => rb3 k h (Nat.succ n) c ax st

def rb1 (nx : Nat) (c : Ctl) (st : List Frame) (ax : Aux S) : Trie HObj → β
  | .nil => rb2 k .nil c st ax nx
  | .node v l r => rb2 k (.node v l r) c st ax nx

def rb0 (nx : Nat) (st : List Frame) (h : Trie HObj) (ax : Aux S) : Ctl → β
  | .ev e env => rb1 k nx (.ev e env) st ax h
  | .ex x env => rb1 k nx (.ex x env) st ax h
  | .ret v => rb1 k nx (.ret v) st ax h
  | .abr a => rb1 k nx (.abr a) st ax h
  | .call f t as => rb1 k nx (.call f t as) st ax h
  | .construct f as nt => rb1 k nx (.construct f as nt) st ax h
  | .bind p v e m d => rb1 k nx (.bind p v e m d) st ax h
  | .short => rb1 k nx .short st ax h
  | .halt c => rb1 k nx (.halt c) st ax h

def St.rebuild (s : St S) : β := rb0 k s.next s.stack s.heap s.aux s.ctl

theorem St.rebuild_eq (s : St S) : s.rebuild k = k s := by
  obtain ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := s
  have e6 : ∀ h nx c st j f t ss, rb6 k h nx c st j f t ss = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st j f t ss; cases ss <;> rfl
  have e5 : ∀ h nx c st j f ss t, rb5 k h nx c st j f ss t = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st j f ss t; cases t <;> simp only [rb5, e6]
  have e4 : ∀ h nx c st f t ss j, rb4 k h nx c st f t ss j = k ⟨h, nx, c, st, ⟨j, f, t, ss⟩⟩ := by
    intro h nx c st f t ss j; cases j <;> simp only [rb4, e5]
  have e3 : ∀ h nx c ax st, rb3 k h nx c ax st = k ⟨h, nx, c, st, ax⟩ := by
    intro h nx c ax st; cases st <;> simp only [rb3, e4]
  have e2 : ∀ h c st ax nx, rb2 k h c st ax nx = k ⟨h, nx, c, st, ax⟩ := by
    intro h c st ax nx; cases nx <;> simp only [rb2, e3] <;> rfl
  have e1 : ∀ nx c st ax h, rb1 k nx c st ax h = k ⟨h, nx, c, st, ax⟩ := by
    intro nx c st ax h; cases h <;> simp only [rb1, e2]
  have e0 : ∀ nx st h ax c, rb0 k nx st h ax c = k ⟨h, nx, c, st, ax⟩ := by
    intro nx st h ax c; cases c <;> simp only [rb0, e1]
  exact e0 _ _ _ _ _

end

def isHalt : Ctl → Bool
  | .halt _ => true
  | _ => false

/-- Run with a number server (`interp`), at most `n` steps. -/
def runWith (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv)) :
    Nat → St F.S → Srv → Option (St F.S × Srv)
  | 0, s, c => some (s, c)
  | n + 1, s, c => bif isHalt s.ctl then some (s, c) else
    match interp (step F s).run c with
    | some (s', c') => s'.rebuild fun s' => runWith F interp n s' c'
    | none => none

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

theorem interp_sim {α : Type} (ρ : Nat → F64) (t : Free α) :
    ∀ (S : SSrv) (C : CSrv) (a : α) (S' : SSrv), Inst ρ S C → interpS t S = some (a, S') →
      ∃ C', interpC t C = some (a, C') ∧ Inst ρ S' C' := by
  induction t with
  | pure x =>
    intro S C a S' hi h
    simp only [interpS, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨C, rfl, hi⟩
  | fail m => intro S C a S' _ h; simp [interpS] at h
  | bin op x y k ih =>
    intro S C a S' hi h
    have hlen : C.tab.length = S.tab.length := by rw [hi.1, List.length_map]
    match hx : S.val x, hy : S.val y with
    | some ex, some ey =>
      simp only [interpS, hx, hy] at h
      obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ (push_inst hi (.bin op ex ey)) h
      refine ⟨C', ?_, h2⟩
      simp only [interpC, val_inst hi.1, hx, hy, Option.map_some, hlen]
      simpa [SymE.eval] using h1
    | none, _ => simp [interpS, hx] at h
    | some _, none => simp [interpS, hx, hy] at h
  | un op x k ih =>
    intro S C a S' hi h
    have hlen : C.tab.length = S.tab.length := by rw [hi.1, List.length_map]
    match hx : S.val x with
    | some ex =>
      simp only [interpS, hx] at h
      obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ (push_inst hi (.un op ex)) h
      refine ⟨C', ?_, h2⟩
      simp only [interpC, val_inst hi.1, hx, Option.map_some, hlen]
      simpa [SymE.eval] using h1
    | none => simp [interpS, hx] at h
  | test op x y k ih =>
    intro S C a S' hi h
    match hx : S.val x, hy : S.val y, ho : S.oracle with
    | none, _, _ => simp [interpS, hx] at h
    | some _, none, _ => simp [interpS, hx, hy] at h
    | some _, some _, [] => simp [interpS, hx, hy, ho] at h
    | some ex, some ey, q :: o =>
    simp only [interpS, hx, hy, ho] at h
    by_cases hq : q.op = op ∧ q.a = ex ∧ q.b = ey
    · simp only [hq, and_self, decide_true, Bool.cond_true] at h
      have hg := hi.2 q (by rw [ho]; exact List.mem_cons_self ..)
      obtain ⟨h1, h2, h3⟩ := hq
      have ho' : Good ρ o := fun q' m => hi.2 q' (by rw [ho]; exact List.mem_cons_of_mem _ m)
      obtain ⟨C', hc1, hc2⟩ := ih q.r { S with oracle := o } C a S' ⟨hi.1, ho'⟩ h
      refine ⟨C', ?_, hc2⟩
      simp only [interpC, val_inst hi.1, hx, hy, Option.map_some]
      rw [← h1, ← h2, ← h3, hg]
      exact hc1
    · simp [hq] at h
  | conc x k ih =>
    intro S C a S' hi h
    cases hx : S.val x with
    | none => simp [interpS, hx] at h
    | some e =>
      cases e with
      | lit v =>
        simp only [interpS, hx] at h
        obtain ⟨C', h1, h2⟩ := ih _ _ _ _ _ hi h
        exact ⟨C', by simp only [interpC, val_inst hi.1, hx, Option.map_some, SymE.eval]; exact h1, h2⟩
      | _ => simp [interpS, hx] at h

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
    simp only [runS, runWith, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨C, rfl, hi⟩
  | succ n ih =>
    intro s s' S S' C hi h
    cases hh : isHalt s.ctl
    · simp only [runS, runWith, hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        obtain ⟨C1, hc, hi1⟩ := interp_sim ρ _ S C s1 S1 hi hs
        obtain ⟨C', h1, h2⟩ := ih s1 s' S1 S' C1 hi1 h
        exact ⟨C', by simp only [runC, runWith, hh, Bool.cond_false, hc, St.rebuild_eq]; exact h1, h2⟩
    · simp only [runS, runWith, hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨C, by simp [runC, runWith, hh], hi⟩

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
