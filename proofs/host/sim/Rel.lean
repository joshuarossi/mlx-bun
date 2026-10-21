import host.sim.Support
import host.sim.Num
namespace Host.Ts.Sim

/-- The bound on source counters the checked runs enforce; with the offset `D < bound`
every target address stays below `2 ^ 62` (the stores' addressing range). -/
def bound : Nat := 2 ^ 61

/-! # The cross-iteration state relation

`Rel` relates a source (template) state `s` under the symbolic server `S` to
a target state `t` under the concrete server `C`: every heap entry present
in the source has its image at the mapped address of the target (the
target may hold more: garbage of earlier iterations), and control, stack,
jobs, stores and the events since the bases are images. Arrays at `framed`
addresses (output arrays a loop only appends to) keep their own prefixes on
each side; only the elements appended since the bases correspond.

The source is closed: its data mentions only present addresses and
allocated number references, so extending the map at fresh references or
addresses leaves every image unchanged. -/

def Present {S : Type} (s : St S) (a : Nat) : Prop := (s.heap.get a).isSome = true

/-- A framed array: both prefixes are fixed, the suffix appended since then corresponds. -/
def FramedObj (M : Map) (pre pre' : List Val) (o o' : Obj) : Prop :=
  ∃ xs, o.kind = .array (pre ++ xs) ∧ o' = { M.obj o with kind := .array (pre' ++ M.vals xs) }

/-- A heap entry of the target corresponding to a present source entry. -/
def SlotOK (M : Map) (fr : Nat → Option (List Val × List Val)) (a : Nat) (h : HObj) (h' : Option HObj) : Prop :=
  match fr a with
  | none => h' = some (M.hobj h)
  | some (pre, pre') => ∃ o o', h = .obj o ∧ h' = some (.obj o') ∧ FramedObj M pre pre' o o'

/-- The fixed parameters of a run's relation: framed arrays with their two prefixes,
the event bases, the counter offset and the band `[lo, hi)` of renamed native handles. -/
structure Ctx where
  fr : Nat → Option (List Val × List Val)
  base : List Event
  base' : List Event
  D : Nat
  lo : Nat
  hi : Nat

/-- Bigints the map fixes: negative, below the renamed handle band, or between the
band and the pointer integers (`ptrInt` values are at least `2 ^ 56`). -/
def BigFixed (lo hi : Nat) (i : Int) : Prop :=
  i < 0 ∨ (0 ≤ i ∧ i < lo) ∨ ((hi : Int) ≤ i ∧ i < 2 ^ 56)

structure Rel (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop where
  srv : Srv M ν S C
  heap : ∀ a h, s.heap.get a = some h → SlotOK M K.fr a h (t.heap.get (M.a a))
  /-- Fresh addresses continue in order; allocated ones map injectively below the target's next. -/
  next : ∀ k, M.a (s.next + k) = t.next + k
  /-- Both sides allocate in lockstep: a constant offset of the counters. -/
  offset : t.next = s.next + K.D
  room : K.D < bound
  /-- Ordinary bigints keep their values; pointer integers follow their memory. -/
  bigFixed : ∀ i, BigFixed K.lo K.hi i → M.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → M.big (ptrInt (.ext r) off) = ptrInt (.ext (M.region r)) off
  band : K.hi ≤ 2 ^ 56
  /-- Intrinsic objects (prototypes, globals: addresses below `aFirst`) are shared. -/
  intr : ∀ a, a < aFirst → M.a a = a
  bound : ∀ a, Present s a → M.a a < t.next
  inj : ∀ a b, Present s a → Present s b → M.a a = M.a b → a = b
  presentBound : ∀ a, Present s a → a < s.next
  framedPresent : ∀ a p, K.fr a = some p → Present s a
  ctl : t.ctl = M.ctl s.ctl
  stack : t.stack = s.stack.map M.frame
  jobs : t.jobs = s.jobs.map M.job
  stores : t.stores = M.stores s.stores
  /-- The native relation, given the number of allocated references (its closedness bound). -/
  ffi : FR M S.tab.length s.ffi t.ffi
  trace : ∃ fresh, s.trace = fresh ++ K.base ∧ t.trace = fresh.map M.event ++ K.base'
  /-- Closedness of the source. -/
  heapSupp : ∀ a h, s.heap.get a = some h → Supp.hobj (Present s) S.tab.length h
  ctlSupp : Supp.ctl (Present s) S.tab.length s.ctl
  stackSupp : ∀ f ∈ s.stack, Supp.frame (Present s) S.tab.length f
  jobsSupp : ∀ j ∈ s.jobs, Supp.job (Present s) S.tab.length j
  storesSupp : Supp.stores (Present s) S.tab.length s.stores
  traceSupp : ∃ fresh, s.trace = fresh ++ K.base ∧ ∀ e ∈ fresh, Supp.event (Present s) S.tab.length e

end Host.Ts.Sim
