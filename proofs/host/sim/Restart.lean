import host.sim.State
import host.ts.Rename
namespace Host.Ts.Sim

/-! # Restarting the template

A template iteration runs from its start state `s0` (server `S0`) to an end
state `s1` (server `S1`). `Shift` says that `s1` holds a copy of `s0` under a
map `σ` (the names the next iteration uses for the start's resources) whose
number references denote the start's entries substituted by `θ` (the next
iteration's values of the template variables). `restart` composes the
relation of `s1` to a target with the shift: the same target is related to
the template start under `M.after σ`, at the substituted valuation. -/

/-- The template's framed arrays hold exactly their prefix at the start and keep
their address; the end state extends them. -/
structure Shift (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (K : Ctx)
    (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → K.fr a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  framed : ∀ a pre pre', K.fr a = some (pre, pre') → σ.a a = a ∧
    ∃ o xs, s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
      s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  next : ∀ k, σ.a (s0.next + k) = s1.next + k
  grows : s0.next ≤ s1.next
  present : ∀ a, Present s0 a → Present s1 (σ.a a)
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  framedPresent : ∀ a p, K.fr a = some p → Present s0 a
  ctl : s1.ctl = σ.ctl s0.ctl
  stack : s1.stack = s0.stack.map σ.frame
  jobs : s1.jobs = s0.jobs.map σ.job
  stores : s1.stores = σ.stores s0.stores
  ffi : FS σ s0.ffi s1.ffi
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K.lo K.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

/-- The next iteration's valuation of the template variables. -/
def Shift.valuation (θ : Nat → SymE) (ν : Nat → F64) : Nat → F64 := fun j => (θ j).eval ν

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K : Ctx} {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}

/-- The framed prefixes of the target after the iteration. -/
def Shift.framedNext (M : Map) (K : Ctx) (s1 : St F.S) (a : Nat) : Option (List Val × List Val) :=
  match K.fr a with
  | none => none
  | some (pre, pre') => match s1.heap.get a with
    | some (.obj o) => match o.kind with
      | .array es => some (pre, pre' ++ M.vals (es.drop pre.length))
      | _ => some (pre, pre')
    | _ => some (pre, pre')

/-- The restart: a target related to the end of an iteration is related to the
template start under `M.after σ`, at the substituted valuation, with the target's
framed prefixes extended by the iteration's appended elements and the events of
the iteration absorbed into the bases. The native relation must compose with the
native part of the shift (`hFS`); the template's oracle must hold at the new
valuation (`hg`), and the grown counter offset must stay in range (`hroom`). -/
def RestartStatement (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (FS : Map → F.S → F.S → Prop) : Prop :=
  ∀ (M σ : Map) (ν : Nat → F64) (θ : Nat → SymE) (K : Ctx) (s0 s1 t : St F.S) (S0 S1 : SSrv) (C : CSrv),
    (∀ x y z, FS σ x y → FR M S1.tab.length y z → FR (M.after σ) S0.tab.length x z) →
    Rel F FR M ν K s1 S1 t C → Shift F FS σ θ K s0 S0 s1 S1 →
    Good (Shift.valuation θ ν) S0.oracle → t.next - s0.next < Sim.bound →
    Rel F FR (M.after σ) (Shift.valuation θ ν)
      ⟨Shift.framedNext M K s1, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩ s0 S0 t C

end
end Host.Ts.Sim
