import host.ts.RenameClosureEffects
import host.ts.RenameParameterBodyFrame

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem allocCells_stack {S : Type} (s : St S) (names : List Name) (env : Env) :
    (allocCells s names env).2.stack = s.stack := by
  induction names generalizing s env with
  | nil => rfl
  | cons name names ih =>
    change (allocCells (s.alloc (.cell none)).2 names ((name,s.next)::env)).2.stack = _
    rw [ih]
    rfl

/-- Actual closure entry adds its scheduler and boundary frames above the
unchanged caller stack; receiver/home/parameter allocations preserve that stack. -/
theorem enterClosure_stack_prefix (F : Ffi) (s result : St F.S) (C D : CSrv)
    (f : Func) (env : Env) (arrow : Bool) (home this : Val) (args : List Val) (b : Boundary)
    (run : interpC (enterClosure F s f env arrow home this args b).run C = some (result,D)) :
    ∃ paramsEnv, result.stack = .k (.params f (fnParams f) args paramsEnv):: .k (.fn b)::s.stack := by
  let start : Env × St F.S := bif arrow then (env,s) else
    let (cell,t) := s.alloc (.cell (some this))
    let e := (nThis,cell)::env
    match home with
    | .undef => (e,t)
    | v => let (cell2,u) := t.alloc (.cell (some v)); ((nHome,cell2)::e,u)
  have stackStart : start.2.stack = s.stack := by
    cases arrow <;> cases home <;> rfl
  have direct : enterClosure F s f env arrow home this args b =
      M.pure (parameterContinuation (allocCells start.2 (paramNames f) start.1).2 f b args
        (allocCells start.2 (paramNames f) start.1).1) := by
    cases arrow <;> cases home <;> rfl
  rw [direct] at run
  change some (parameterContinuation (allocCells start.2 (paramNames f) start.1).2 f b args
    (allocCells start.2 (paramNames f) start.1).1,C) = some (result,D) at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  refine ⟨(allocCells start.2 (paramNames f) start.1).1,?_⟩
  rw [← he]
  simp only [parameterContinuation,St.push,St.ret,allocCells_stack,stackStart]

theorem step_closure_stack_prefix (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (f : Func) (env : Env) (arrow : Bool) (home₀ this₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀) (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.closure f env arrow home₀))
    (run : interpC (step F s).run C = some (result,D)) :
    ∃ args paramsEnv, result.stack = .k (.params f (fnParams f) args paramsEnv):: .k (.fn .call)::s.stack := by
  obtain ⟨callee,this,args,hc,hcallee,_,_⟩ := (h.control_view hc₀).call_view
  cases hcallee
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,_⟩ := h.heap.readObject a o₀ ha (h.heap.function_notFramed a o₀ _ ha ho₀ hk₀) ho₀
  have hk := hor.kind
  rw [hk₀] at hk
  obtain ⟨home,hk,_⟩ := kind_closure hk
  rw [step_closure_eq F s (R.a a) o f (R.env env) arrow home this args hc ho hk] at run
  obtain ⟨paramsEnv,stack⟩ := enterClosure_stack_prefix F s result C D f (R.env env) arrow home this args .call run
  exact ⟨args,paramsEnv,stack⟩

theorem enterBlock_stack_prefix {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (inert : noInitFunctions ss = true) :
    (enterBlock s ss env).stack = .s (.block ss (hoist s ss env).1):: .s (.scope [])::s.stack := by
  have hoistStack : (hoist s ss env).2.stack = s.stack := by
    rw [hoist_inert_eq s env ss inert]
    exact allocCells_stack s (blockNames ss) env
  simp only [enterBlock,St.push,St.ret,hoistStack]

/-- Finishing the original synchronous scheduler replaces its head frame
with the body/scope frames and retains the exact caller suffix. -/
theorem step_parameter_body_stack_prefix (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (initial : Val) (name : Option Name) (params : List Pat) (ss : List Stmt) (args : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret initial)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.block ss) false false []) [] args env)::fs₀)
    (inert : noInitFunctions ss = true) (run : interpC (step F s).run C = some (result,D)) :
    ∃ bodyEnv, result.stack = .s (.block ss bodyEnv):: .s (.scope [])::s.stack.tail := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨values,hfe,_⟩ := hfr.params_view
  rw [hfe] at hf
  rw [step_parameter_body_eq F s v name params ss values (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  refine ⟨(hoist {s with stack := fs} ss (R.env env)).1,?_⟩
  rw [← he,hf]
  exact enterBlock_stack_prefix {s with stack := fs} ss (R.env env) inert

end Host.Ts.Owned.Parametric
