import host.ts.Rename
namespace Host.Ts.RenameCounterexample

/-! The original one-sided heap embedding permits a dangling source object to become a
function in the target. An actual `typeof` transition distinguishes the two states. -/

def identity : Ren := ⟨id, id⟩

def ffi : Ffi := ⟨Unit, fun _ _ _ => .fail "unused", fun _ _ _ _ => none,
  fun _ => 0, fun _ _ => .fail "unused"⟩

def src : St Unit :=
  ⟨.nil, aFirst, .ret (.obj 0), [.e .typeof], ⟨[], (), [], []⟩⟩

def dst : St Unit :=
  { src with heap := src.heap.set 0 (.obj ⟨.fn (.native (.fn .noop) []), .null, [], [], true⟩) }

def srcAfter : St Unit := { src with ctl := .ret (.str chars!"object"), stack := [] }
def dstAfter : St Unit := { dst with ctl := .ret (.str chars!"function"), stack := [] }

/-- This is exactly the old one-sided heap condition, together with its bounds, control,
stack, jobs, stores and trace conditions for these states. -/
theorem old_embedding :
    (∀ a h, src.heap.get a = some h → dst.heap.get (identity.a a) = some (identity.hobj h)) ∧
    (∀ a, a < src.next → identity.a a < dst.next) ∧
    (∀ a b, a < src.next → b < src.next → identity.a a = identity.a b → a = b) ∧
    (∀ a, a < aFirst → identity.a a = a) ∧
    (∀ k, identity.a (src.next + k) = dst.next + k) ∧
    dst.ctl = identity.ctl src.ctl ∧
    dst.stack = src.stack.map identity.frame ∧
    dst.aux.jobs = src.aux.jobs.map identity.job ∧
    dst.aux.stores = identity.stores src.aux.stores ∧
    dst.aux.ffi = src.aux.ffi ∧ dst.aux.trace = src.aux.trace := by
  refine ⟨?_, ?_, ?_, ?_, ?_, rfl, rfl, rfl, rfl, rfl, rfl⟩
  · intro a h ha
    change (none : Option HObj) = some h at ha
    cases ha
  · intro a ha; exact ha
  · intro a b _ _ h; exact h
  · intro a _; rfl
  · intro k; rfl

theorem source_step : interpS (step ffi src).run ⟨[], []⟩ = some (srcAfter, ⟨[], []⟩) := rfl

theorem target_step : interpS (step ffi dst).run ⟨[], []⟩ = some (dstAfter, ⟨[], []⟩) := rfl

theorem steps_do_not_commute : dstAfter.ctl ≠ identity.ctl srcAfter.ctl := by
  intro h
  cases h

/-- Exact heap lookup correspondence rejects this pair before any step is attempted. -/
theorem repaired_relation_rejects (FR : Ren → Unit → Unit → Prop) :
    ¬ Renamed FR identity [] [] src dst := by
  intro h
  have hh := h.heap 0 (by decide)
  change some _ = none at hh
  cases hh

end Host.Ts.RenameCounterexample
