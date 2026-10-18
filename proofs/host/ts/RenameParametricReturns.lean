import host.ts.RenameParametricDefaults

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem StateR.return_values {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ v : Val)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v) :
    ValueR NR R v₀ v ∧ valueSupport live v₀ := by
  have hr := h.control
  rw [hc₀,hc] at hr
  have hl := h.controlLive
  rw [hc₀] at hl
  cases hr with | node tag hs =>
    cases hs with | cons hv hs =>
      cases hv with | value hv => exact ⟨hv,hl.1⟩

/-- The real return frames with no cleanup or asynchronous work. -/
inductive ReturnExit where
  | explicitReturn | emptyBlock | emptyScope | implicitCall

def ReturnExit.frame (env : Env) : ReturnExit → Frame
  | .explicitReturn => .s .ret
  | .emptyBlock => .s (.block [] env)
  | .emptyScope => .s (.scope [])
  | .implicitCall => .k (.fn .call)

def ReturnExit.control (v : Val) : ReturnExit → Ctl
  | .explicitReturn => .abr (.ret v)
  | .emptyScope => .ret v
  | .emptyBlock | .implicitCall => .ret .undef

theorem step_return_exit_eq (F : Ffi) (s : St F.S) (v : Val) (env : Env)
    (exit : ReturnExit) (fs : List Frame) (hc : s.ctl = .ret v)
    (hf : s.stack = exit.frame env::fs) :
    step F s = M.pure ({s with stack := fs}.go (exit.control v)) := by
  cases exit <;> simp only [step,hc,stepRet,hf,ReturnExit.frame,ReturnExit.control,
    retStep,retSt,retK,boundaryRet,retS,St.ret,St.go]

theorem step_return_exit_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (exit : ReturnExit) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = exit.frame env::fs₀)
    (hf : s.stack = exit.frame (R.env env)::fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.go (exit.control v₀),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.go (exit.control v),C) ∧
    StateR NR FR R live framed before after old old'
      ({s₀ with stack := fs₀}.go (exit.control v₀))
      ({s with stack := fs}.go (exit.control v)) := by
  obtain ⟨hv,hvl⟩ := h.return_values v₀ v hc₀ hc
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  refine ⟨?_,?_,?_⟩
  · rw [step_return_exit_eq F s₀ v₀ env exit fs₀ hc₀ hf₀]; rfl
  · rw [step_return_exit_eq F s v (R.env env) exit fs hc hf]; rfl
  · cases hfs with | cons _ htail =>
      have hh := h.restack htail hfl.2
      cases exit <;> apply hh.go
      all_goals dsimp only [ReturnExit.control,Encode.ctl,Encode.abr,Encode.val,treeSupport,forestSupport]
      all_goals repeat first | exact hv | exact hvl | constructor

theorem StateR.return_abrupt_values {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ v : Val)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hc : s.ctl = .abr (.ret v)) :
    ValueR NR R v₀ v ∧ valueSupport live v₀ := by
  have hr := h.control
  rw [hc₀,hc] at hr
  have hl := h.controlLive
  rw [hc₀] at hl
  cases hr with | node tag hs =>
    cases hs with | cons ha hs =>
      cases ha with | node tag hs =>
        cases hs with | cons hv hs =>
          cases hv with | value hv => exact ⟨hv,hl.1.1⟩

/-- The return completion passes through lexical blocks and empty scopes,
then the ordinary function boundary converts it to a returned value. -/
inductive ReturnUnwind where
  | block (remaining : List Stmt) | scope | call

def ReturnUnwind.frame (env : Env) : ReturnUnwind → Frame
  | .block ss => .s (.block ss env)
  | .scope => .s (.scope [])
  | .call => .k (.fn .call)

def ReturnUnwind.control (v : Val) : ReturnUnwind → Ctl
  | .call => .ret v
  | .block _ | .scope => .abr (.ret v)

theorem step_return_unwind_eq (F : Ffi) (s : St F.S) (v : Val) (env : Env)
    (unwind : ReturnUnwind) (fs : List Frame) (hc : s.ctl = .abr (.ret v))
    (hf : s.stack = unwind.frame env::fs) :
    step F s = M.pure ({s with stack := fs}.go (unwind.control v)) := by
  cases unwind <;> simp only [step,hc,stepAbr,hf,ReturnUnwind.frame,ReturnUnwind.control,
    abrStep,abrSt,abrK,boundaryAbr,retS,St.ret,St.go]

theorem step_return_unwind_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (unwind : ReturnUnwind) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hc : s.ctl = .abr (.ret v))
    (hf₀ : s₀.stack = unwind.frame env::fs₀)
    (hf : s.stack = unwind.frame (R.env env)::fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.go (unwind.control v₀),C₀) ∧
    interpC (step F s).run C = some ({s with stack := fs}.go (unwind.control v),C) ∧
    StateR NR FR R live framed before after old old'
      ({s₀ with stack := fs₀}.go (unwind.control v₀))
      ({s with stack := fs}.go (unwind.control v)) := by
  obtain ⟨hv,hvl⟩ := h.return_abrupt_values v₀ v hc₀ hc
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  refine ⟨?_,?_,?_⟩
  · rw [step_return_unwind_eq F s₀ v₀ env unwind fs₀ hc₀ hf₀]; rfl
  · rw [step_return_unwind_eq F s v (R.env env) unwind fs hc hf]; rfl
  · cases hfs with | cons _ htail =>
      have hh := h.restack htail hfl.2
      cases unwind <;> apply hh.go
      all_goals dsimp only [ReturnUnwind.control,Encode.ctl,Encode.abr,Encode.val,treeSupport,forestSupport]
      all_goals repeat first | exact hv | exact hvl | constructor

end Host.Ts.Owned.Parametric
