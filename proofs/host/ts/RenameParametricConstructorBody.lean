import host.ts.RenameParametricClassEntry
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def constructorParameterArgument : List Frame → Val
  | .k (.params _ _ args _)::_ => nthD .undef args 0
  | _ => .undef

theorem enterClosure_first_parameter (F : Ffi) (s result : St F.S) (C D : CSrv)
    (f : Func) (env : Env) (arrow : Bool) (home this : Val) (args : List Val) (b : Boundary)
    (run : interpC (enterClosure F s f env arrow home this args b).run C = some (result,D)) :
    constructorParameterArgument result.stack = nthD .undef args 0 := by
  cases arrow <;> cases home
  all_goals simp only [enterClosure,Bool.cond_true,Bool.cond_false] at run
  all_goals
    have he := congrArg Prod.fst (Option.some.inj run)
    dsimp only at he
    rw [← he]
    rfl

theorem FrameR.constructorBody_view {NR : NumV → NumV → Prop} {R : Ren}
    {receiver : Val} {fn : Func} {env : Env} {args : List Val} {f : Frame}
    (h : FrameR NR R (.k (.ctorBody receiver fn env args)) f) :
    ∃ receiver' args', f = .k (.ctorBody receiver' fn (R.env env) args') ∧
      ValueR NR R receiver receiver' ∧ ListR (ValueR NR R) args args' := by
  obtain ⟨fn',rfl,hf⟩ := h.k_view
  have ht := hf.tag_eq
  cases fn' <;> simp only [Encode.fnF,treeTag] at ht
  all_goals try contradiction
  case ctorBody receiver' fn' env' args' =>
    cases hf with | node tag hs =>
      cases hs with | cons hr hs =>
        cases hs with | cons hfn hs =>
          cases hs with | cons he hs =>
            cases hs with | cons ha hs =>
              cases hfn
              obtain rfl := env_eq_map he
              cases hr with | value hr => exact ⟨receiver',args',rfl,hr,vals_roles_of ha⟩

theorem step_constructor_body_eq (F : Ffi) (s : St F.S) (v receiver : Val)
    (f : Func) (env : Env) (args : List Val) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.ctorBody receiver f env args)::fs) :
    step F s = enterClosure F {s with stack := fs} f env false .undef receiver args (.ctor receiver) := by
  simp only [step,hc,stepRet,hf,retStep,retK]

def ConstructorBodyLive (live : Nat → Prop) (start : Nat) (fn : Func) : Nat → Prop :=
  CellsLive (LiveAfter live start) (start+1) (paramNames fn)

/-- The actual constructor-body continuation enters its original closure with
its real receiver, captured environment, argument list and constructor boundary.
Allocation and the first supplied value are derived, not supplied as target steps. -/
theorem step_constructor_body_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ receiver₀ : Val) (f : Func) (env : Env) (args₀ : List Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .k (.ctorBody receiver₀ f env args₀)::fs₀)
    (sourceBound : s₀.next+1+(paramNames f).length ≤ 2^64)
    (targetBound : s.next+1+(paramNames f).length ≤ 2^64) :
    ∃ result₀ result, interpC (step F s₀).run C₀ = some (result₀,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (ConstructorBodyLive live s₀.next f) framed before after old old' result₀ result ∧
      constructorParameterArgument result.stack = classBodyArgument s.stack := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨frame,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨receiver,args,hframe,hr,hargs⟩ := hfr.constructorBody_view
  rw [hframe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have receiverLive : valueSupport live receiver₀ := hl.1.1.1
  have envLive : treeSupport live (Encode.env env) := hl.1.1.2.2.1
  have argsLive := vals_support_of args₀ hl.1.1.2.2.2.1
  have boundary : TreeR NR R (Encode.bnd (.ctor receiver₀)) (Encode.bnd (.ctor receiver)) := .node _ (.cons (.value hr) .nil)
  have boundaryLive : treeSupport live (Encode.bnd (.ctor receiver₀)) := ⟨receiverLive,True.intro⟩
  have popped := h.restack htail hl.2
  obtain ⟨r₀,r,hr₀,run,hs⟩ := enterClosure_plain_roles F NR FR R C₀ C live framed before after old old'
    {s₀ with stack := fs₀} {s with stack := fs} popped f env receiver₀ receiver args₀ args (.ctor receiver₀) (.ctor receiver)
    hr receiverLive boundary hargs boundaryLive argsLive envLive sourceBound targetBound
  have firstArg := enterClosure_first_parameter F {s with stack := fs} r C C f (R.env env) false .undef receiver args (.ctor receiver) run
  refine ⟨r₀,r,?_,?_,hs,?_⟩
  · rw [step_constructor_body_eq F s₀ v₀ receiver₀ f env args₀ fs₀ hc₀ hf₀]; exact hr₀
  · rw [step_constructor_body_eq F s v receiver f (R.env env) args fs hc hf]; exact run
  · rw [hf]; exact firstArg

end Host.Ts.Owned.Parametric
