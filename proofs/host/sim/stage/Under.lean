import host.ts.Chunk
namespace Host.Ts.Sim.Stage
open Host.Ts

/-! # Caller frames and native state as parameters of a run

A stage of the route is one call of our TypeScript: from the call state to the state that
returns its result to the caller. In isolation the call state has an empty stack (no caller
frames). `under s r` is `s` inside a caller whose frames are `r` (innermost first, below the
callee's own frames).

A stage template is a chain of concrete states whose caller frames and native state are
parameters (`tpl`): `tpl s m x r` keeps the heap, counter, control, jobs, trace and stores of
the chain state `s`, the callee's own `m` innermost frames, and puts the frames `r` below them
and the native state `x : S` in place of `s`'s. A stage chunk
`∀ F x r, runS F k (tpl s m x r) S = some (tpl s' m' x r, S')` is checked once by the kernel
with `F`, `x` and `r` free (`stage_rfl`): the run never reads below the callee's frames,
never reads or writes the native state and never calls the FFI, else the check is stuck on a
variable and fails. A run step whose result has no callee frame left (the return to the caller)
rebuilds its state by a recursor on the stack, which is stuck on `r`; that step is checked as a
step (`interpS (step F s).run S = …`) and closed by `runWith_one`. -/

/-- The state `s` under the caller frames `r`. -/
def under {S : Type} (s : St S) (r : List Frame) : St S := { s with stack := s.stack ++ r }

@[simp] theorem under_nil {S : Type} (s : St S) : under s [] = s := by
  cases s; simp [under]

@[simp] theorem under_ctl {S : Type} (s : St S) (r : List Frame) : (under s r).ctl = s.ctl := rfl
@[simp] theorem under_heap {S : Type} (s : St S) (r : List Frame) : (under s r).heap = s.heap := rfl
@[simp] theorem under_next {S : Type} (s : St S) (r : List Frame) : (under s r).next = s.next := rfl
@[simp] theorem under_stack {S : Type} (s : St S) (r : List Frame) : (under s r).stack = s.stack ++ r := rfl
@[simp] theorem under_aux {S : Type} (s : St S) (r : List Frame) : (under s r).aux = s.aux := rfl

theorem under_under {S : Type} (s : St S) (r r' : List Frame) : under (under s r) r' = under s (r ++ r') := by
  simp [under, List.append_assoc]

/-- A template state: chain state `s` (native state `Unit`) with its `m` innermost frames, the
caller frames `r` below them, and the native state `x`. -/
def tpl {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) : St S :=
  ⟨s.heap, s.next, s.ctl, s.stack.take m ++ r, ⟨s.jobs, x, s.trace, s.stores⟩⟩

@[simp] theorem tpl_ctl {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) : (tpl s m x r).ctl = s.ctl := rfl
@[simp] theorem tpl_heap {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).heap = s.heap := rfl
@[simp] theorem tpl_next {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).next = s.next := rfl
@[simp] theorem tpl_stack {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).stack = s.stack.take m ++ r := rfl
@[simp] theorem tpl_ffi {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) : (tpl s m x r).ffi = x := rfl
@[simp] theorem tpl_jobs {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).jobs = s.jobs := rfl
@[simp] theorem tpl_trace {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).trace = s.trace := rfl
@[simp] theorem tpl_stores {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    (tpl s m x r).stores = s.stores := rfl

/-- A template state is its isolated state under the caller frames. -/
theorem tpl_under {S : Type} (s : St Unit) (m : Nat) (x : S) (r : List Frame) :
    tpl s m x r = under (tpl s m x []) r := by
  simp [tpl, under]

/-- At the chain's own native state and caller frames, a template state is the chain state. -/
theorem tpl_self (s : St Unit) (m : Nat) (h : s.stack.take m ++ s.stack.drop m = s.stack) :
    tpl s m () (s.stack.drop m) = s := by
  obtain ⟨hp, nx, c, st, ⟨j, f, t, ss⟩⟩ := s
  simp only [tpl] at h ⊢
  rw [h]
  rfl

/-- A template state over a fixed native state: chain state `s` with its `m` innermost frames and
the caller frames `r` below them (for stages that call the FFI: the native state is the chain's). -/
def tplN {S : Type} (s : St S) (m : Nat) (r : List Frame) : St S := { s with stack := s.stack.take m ++ r }

@[simp] theorem tplN_ctl {S : Type} (s : St S) (m : Nat) (r : List Frame) : (tplN s m r).ctl = s.ctl := rfl
@[simp] theorem tplN_heap {S : Type} (s : St S) (m : Nat) (r : List Frame) : (tplN s m r).heap = s.heap := rfl
@[simp] theorem tplN_next {S : Type} (s : St S) (m : Nat) (r : List Frame) : (tplN s m r).next = s.next := rfl
@[simp] theorem tplN_aux {S : Type} (s : St S) (m : Nat) (r : List Frame) : (tplN s m r).aux = s.aux := rfl

theorem tplN_under {S : Type} (s : St S) (m : Nat) (r : List Frame) : tplN s m r = under (tplN s m []) r := by
  simp [tplN, under]

/-- At the chain's own caller frames, a template state is the chain state. -/
theorem tplN_self {S : Type} (s : St S) (m : Nat) : tplN s m (s.stack.drop m) = s := by
  obtain ⟨hp, nx, c, st, ax⟩ := s
  simp only [tplN, List.take_append_drop]

/-- One run step closed by its step equation (the state rebuild is the identity). -/
theorem runWith_one (F : Ffi) {Srv : Type} (interp : Free (St F.S) → Srv → Option (St F.S × Srv))
    {s s' : St F.S} {c c' : Srv} (hh : isHalt s.ctl = false) (h : interp (step F s).run c = some (s', c')) :
    runWith F interp 1 s c = some (s', c') := by
  rw [runWith_succ, hh]
  simp only [Bool.cond_false, h, St.rebuild_eq]
  rfl

theorem runS_one (F : Ffi) {s s' : St F.S} {S S' : SSrv} (hh : isHalt s.ctl = false)
    (h : interpS (step F s).run S = some (s', S')) : runS F 1 s S = some (s', S') :=
  runWith_one F interpS hh h

/-- A run closed by its last step. -/
theorem runS_snoc (F : Ffi) {n : Nat} {s s1 s2 : St F.S} {S S1 S2 : SSrv} (h : runS F n s S = some (s1, S1))
    (hh : isHalt s1.ctl = false) (hs : interpS (step F s1).run S1 = some (s2, S2)) :
    runS F (n + 1) s S = some (s2, S2) :=
  runS_trans F h (runS_one F hh hs)

end Host.Ts.Sim.Stage

namespace Host.Ts.Sim.Stage
open Lean Elab Command Meta

/-- `stage_rfl n : ∀ xs, a = b` proves `fun xs => Eq.refl a`, checked by the kernel alone with the
binders `xs` free (the elaborator does not reduce `a`). -/
elab "stage_rfl " n:ident " : " t:term : command => liftTermElabM do
  let ty ← Term.elabType t
  Term.synthesizeSyntheticMVarsNoPostponing
  let ty ← instantiateMVars ty
  let value ← forallTelescope ty fun xs body => do
    let some (α, a, _) := body.eq? | throwError "stage_rfl: expected an equation under the binders"
    let u ← getLevel α
    mkLambdaFVars xs (mkApp2 (mkConst ``Eq.refl [u]) α a)
  addDecl (.thmDecl { name := (← getCurrNamespace) ++ n.getId, levelParams := [], type := ty, value })

end Host.Ts.Sim.Stage
