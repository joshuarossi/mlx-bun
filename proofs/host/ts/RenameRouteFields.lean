import host.ts.RenameParametricExpressionReturns
import host.ts.RenameParametricDescent
namespace Host.Ts.Owned.Parametric

theorem argumentState_heap {S : Type} (s : St S) (kind : Nat) (fn this : Val)
    (acc : List Val) (rest : List Elem) (env : Env) :
    (argumentState s kind fn this acc rest env).heap = s.heap := by
  induction rest generalizing acc with
  | nil => simp only [argumentState]; split <;> rfl
  | cons e rest ih => cases e with
    | expr e => rfl
    | spread e => rfl
    | hole => exact ih (.undef::acc)

theorem step_argument_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (kind : Nat) (fn₀ this₀ : Val) (acc₀ : List Val) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .c (.args kind fn₀ this₀ acc₀ rest env)::fs₀)
    (hk : kind ≤ 1) (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨fn,this,acc,hframe,_,_,_⟩ := hfr.args_view
  rw [hframe] at hf
  rw [step_argument_eq F s v kind fn this acc rest (R.env env) fs hc hf hk] at run
  have hr := congrArg Prod.fst (Option.some.inj run)
  dsimp only [M.pure,interpC_pure] at hr
  have hh := congrArg St.heap hr
  rw [argumentState_heap] at hh
  exact hh.symm

theorem step_binary_left_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (op : BinOp) (right : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .e (.binL op right env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.binL_view] at hf
  rw [step_binary_left_eq F s v op right (R.env env) fs hc hf] at run
  have hr := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap hr).symm

/-- Binary-left continuation retains the operand's exact value occurrence in
the saved frame. A later comparison can use its fixed meaning directly. -/
theorem step_binary_left_saved_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v : Val) (op : BinOp) (right : Expr) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = .e (.binL op right env)::fs₀) (hc : s.ctl = .ret v)
    (run : interpC (step F s).run C = some (result,D)) :
    ∃ fs, result.stack = .e (.binR op v)::fs ∧
      result.ctl = .ev right (R.env env) ∧ result.heap = s.heap := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.binL_view] at hf
  rw [step_binary_left_eq F s v op right (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  exact ⟨fs,(congrArg St.stack he).symm,(congrArg St.ctl he).symm,(congrArg St.heap he).symm⟩

theorem step_descent_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (d : Descent) (env : Env) (hc₀ : s₀.ctl = .ev d.whole env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  have hc := (h.control_view hc₀).ev_view
  rw [step_descent_eq F s d (R.env env) hc] at run
  have hr := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap hr).symm
end Host.Ts.Owned.Parametric
