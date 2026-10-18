import host.ts.RenameParametricArrayLiteral
import host.ts.RenameParametricDescent

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_descent_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (d : Descent) (env : Env) (hc₀ : s₀.ctl = .ev d.whole env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (d.frame env)).go (.ev d.focus env),C₀) ∧
      interpC (step F s).run C = some ((s.push (d.frame (R.env env))).go (.ev d.focus (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (d.frame env)).go (.ev d.focus env))
        ((s.push (d.frame (R.env env))).go (.ev d.focus (R.env env))) :=
  step_descent_roles F NR FR R C₀ C live framed before after old old' s₀ s h d env (R.env env)
    hc₀ (h.control_view hc₀).ev_view

def callbackObject (f : Func) (env : Env) : HObj :=
  .obj ⟨.fn (.closure f env true .undef),.obj aFunctionProto,[],[],true⟩

theorem step_callback_eq (F : Ffi) (s : St F.S) (f : Func) (env : Env)
    (hc : s.ctl = .ev (.arrow f) env) :
    step F s = M.pure ((s.alloc (callbackObject f env)).2.ret (.obj s.next)) := by
  simp only [step,hc,evStep,closureObj,St.allocObj,retS,callbackObject]
  rfl

/-- A real arrow-expression allocation retains its captured live environment
and allocates the related closure at the fresh target address. -/
theorem step_callback_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (f : Func) (env : Env) (hc₀ : s₀.ctl = .ev (.arrow f) env)
    (hp : live aFunctionProto) (hpr : R.a aFunctionProto = aFunctionProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    interpC (step F s₀).run C₀ = some ((s₀.alloc (callbackObject f env)).2.ret (.obj s₀.next),C₀) ∧
      interpC (step F s).run C = some ((s.alloc (callbackObject f (R.env env))).2.ret (.obj s.next),C) ∧
      StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
        ((s₀.alloc (callbackObject f env)).2.ret (.obj s₀.next))
        ((s.alloc (callbackObject f (R.env env))).2.ret (.obj s.next)) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have hp' : ValueR NR R (.obj aFunctionProto) (.obj aFunctionProto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) aFunctionProto)
  have ho : HeapObjectR NR R (callbackObject f env) (callbackObject f (R.env env)) := by
    apply HeapObjectR.obj
    repeat first | exact env_roles NR R env | exact TreeR.value hp' | constructor
  have he := treeSupport_mono (fun a ha => Or.inl ha : ∀ a, live a → LiveAfter live s₀.next a)
    (Encode.env env) hl.2.1
  have hol : treeSupport (LiveAfter live s₀.next) (Encode.hobj (callbackObject f env)) := by
    dsimp only [callbackObject,Encode.hobj,Encode.obj,Encode.kind,Encode.code,Encode.val,Encode.atom,
      Encode.props,treeSupport,forestSupport]
    repeat first | exact he | exact Or.inl hp | constructor
  have hh := h.alloc _ _ ho hol hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have hv : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [hn] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  refine ⟨?_,?_,hh.go (.node _ (.cons (.value hv) .nil)) ⟨Or.inr rfl,True.intro⟩⟩
  · rw [step_callback_eq F s₀ f env hc₀]; rfl
  · rw [step_callback_eq F s f (R.env env) hc]; rfl

end Host.Ts.Owned.Parametric
