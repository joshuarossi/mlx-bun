import host.ts.RenameWellKnownLookup
import host.ts.RenameUsingScope

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_using_object_eq (F : Ffi) (s : St F.S) (a method : Nat)
    (pattern : Pat) (rest : List (Pat × Option Expr)) (env : Env) (frames registered : List Frame) (w e : Bool)
    (control : s.ctl = .ret (.obj a)) (stack : s.stack = .s (.decl .using pattern rest env)::frames)
    (lookup : getChain F {s with stack := frames} (.sym symDispose) 16 a = M.pure (some (.data (.obj method) w e)))
    (registration : addUsing (.obj a,.obj method) frames = some registered) :
    step F s = M.pure (declarationValue {s with stack := registered} .using pattern rest env (.obj a)) := by
  simp only [control] at lookup
  funext β k
  simp only [step,control,stepRet,stack,retStep,retSt,isUsing,Bool.cond_true,dataOf,Host.Ts.lookup]
  rw [lookup]
  simp only [M.bind,M.pure,registration,Option.map_some]
  rfl

/-- The existing source prototype path determines the disposal method, and
registration updates the nearest scope in both runs without touching the heap. -/
theorem step_using_object_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a method : Nat) (pattern : Pat) (rest : List (Pat × Option Expr)) (env : Env) (frames : List Frame)
    (w e : Bool) (index : Nat)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = .s (.decl .using pattern rest env)::frames)
    (path : OrdinarySymbolLookup s₀ symDispose 16 a (some (.data (.obj method) w e)))
    (scope : ScopeAt frames index) :
    ∃ targetFrames registered targetRegistered,
      s.stack = .s (.decl .using pattern rest (R.env env))::targetFrames ∧
      addUsing (.obj (R.a a),.obj (R.a method)) targetFrames = some targetRegistered ∧
      addUsing (.obj a,.obj method) frames = some registered ∧
      interpC (step F s₀).run C₀ = some (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a),C₀) ∧
      interpC (step F s).run C = some (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a)),C) ∧
      StateR NR FR R live framed before after old old'
        (declarationValue {s₀ with stack := registered} .using pattern rest env (.obj a))
        (declarationValue {s with stack := targetRegistered} .using pattern rest (R.env env) (.obj (R.a a))) := by
  obtain ⟨value,targetControl,valueRoles⟩ := (h.control_view control).ret_view
  cases valueRoles
  obtain ⟨frame,targetFrames,targetStack,headRole,framesRoles⟩ := h.stack_view stack
  rw [headRole.decl_view] at targetStack
  have sourceLive := h.stackLive
  rw [stack] at sourceLive
  have envLive : treeSupport live (Encode.env env) := sourceLive.1.1.2.2.2.1
  have aLive : live a := by have held := h.controlLive; rw [control] at held; exact held.1
  have base := h.restack framesRoles sourceLive.2
  obtain ⟨property,leftLookup,rightLookup,propertyRole,propertyLive⟩ :=
    (path.withStack frames).transport F base.heap symDispose (by decide +kernel) aLive
  cases propertyRole with | some selected =>
    obtain ⟨methodValue,rfl,methodRole⟩ := selected.data
    cases methodRole
    have methodLive : live method := (propertyLive _ rfl).1
    obtain ⟨registered,targetRegistered,registeredEq,targetRegisteredEq,registeredRole,registeredLive⟩ :=
      addUsing_roles (.obj a) (.obj method) aLive methodLive frames targetFrames index scope framesRoles sourceLive.2
    have newFrame : FrameR NR R (.s (.declNext .using rest env)) (.s (.declNext .using rest (R.env env))) :=
      .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons (env_roles NR R env) .nil)))) .nil)
    have newLive : treeSupport live (Encode.frame (.s (.declNext .using rest env))) :=
      ⟨⟨True.intro,True.intro,envLive,True.intro⟩,True.intro⟩
    refine ⟨targetFrames,registered,targetRegistered,targetStack,targetRegisteredEq,registeredEq,?_,?_,
      (h.restack (.cons newFrame registeredRole) ⟨newLive,registeredLive⟩).go
        (.node _ (.cons (.atom _ _) (.cons (.value (.obj a)) (.cons (env_roles NR R env)
          (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))
        ⟨True.intro,aLive,envLive,True.intro,True.intro,True.intro⟩⟩
    · rw [step_using_object_eq F s₀ a method pattern rest env frames registered w e control stack leftLookup registeredEq]; rfl
    · rw [step_using_object_eq F s (R.a a) (R.a method) pattern rest (R.env env) targetFrames targetRegistered w e
        targetControl targetStack rightLookup targetRegisteredEq]; rfl

end Host.Ts.Owned.Parametric
