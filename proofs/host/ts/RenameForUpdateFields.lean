import host.ts.RenameParametricForControl
import host.ts.RenameClosureEffects

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem forTestState_heap {S : Type} (s : St S) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) :
    (forTestState s test update body env names labels).heap = s.heap := by
  cases test <;> rfl

theorem forUpdateState_heap {S : Type} (s : St S) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) :
    (forUpdateState s test update body env names labels).heap = s.heap := by
  cases update with
  | none => exact forTestState_heap s test none body env names labels
  | some _ => rfl

/-- The original per-iteration copy retains the incoming index occurrence in
its fresh cell. Existing addresses remain unchanged. -/
theorem step_for_update_fixed_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ value : Val) (test update : Option Expr) (body : Stmt) (env : Env) (name : Name)
    (labels : List Name) (fs₀ : List Frame) (a : Nat)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .lp (.forUpd test update body env [name] labels)::fs₀)
    (he₀ : lookupEnv name env = some a)
    (cell : s.heap.get (R.a a) = some (.cell (some value))) (bound : s.next < 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    result.heap.get s.next = some (.cell (some value)) ∧
      (∀ b, b < s.next → result.heap.get b = s.heap.get b) := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.forUpd_view] at hf
  have lookup : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  rw [step_for_update_eq F s v test update body (R.env env) name labels fs hc hf,
    nextIter_one_eq F {s with stack := fs} name (R.env env) (R.a a) value lookup cell] at run
  have stateEq := (congrArg Prod.fst (Option.some.inj run)).symm
  dsimp only at stateEq
  have heap : result.heap = (s.alloc (.cell (some value))).2.heap := by
    rw [stateEq,forUpdateState_heap]
    rfl
  refine ⟨?_,?_⟩
  · rw [heap]
    simp only [St.alloc,PTrie.get_set_u64 _ _ _ bound,ite_true]
  · intro b hb
    rw [heap]
    exact alloc_heap_below s (.cell (some value)) b hb bound

end Host.Ts.Owned.Parametric
