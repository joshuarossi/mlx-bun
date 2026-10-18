import host.ts.RenameCleanupViews

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def cleanupNext {S : Type} (s : St S) (resources : List (Val × Val)) (pending : Comp) : St S :=
  match resources with
  | [] => resume s pending
  | (resource,method)::rest => (s.push (.s (.dispose rest pending))).go (.call method resource [])

theorem step_scope_cleanup_eq (F : Ffi) (s : St F.S) (pending : Comp)
    (resource method : Val) (rest : List (Val × Val)) (frames : List Frame)
    (control : s.ctl = completionControl pending)
    (stack : s.stack = .s (.scope ((resource,method)::rest))::frames) :
    step F s = M.pure (cleanupNext {s with stack := frames} ((resource,method)::rest) pending) := by
  cases pending <;> simp only [step,completionControl] at control ⊢
  · simp only [control,stepRet,stack,retStep,retSt,cleanupNext]
  · simp only [control,stepAbr,stack,abrStep,abrSt,cleanupNext]

theorem step_dispose_cleanup_eq (F : Ffi) (s : St F.S) (returned : Val) (pending : Comp)
    (resources : List (Val × Val)) (frames : List Frame)
    (control : s.ctl = .ret returned) (stack : s.stack = .s (.dispose resources pending)::frames) :
    step F s = M.pure (cleanupNext {s with stack := frames} resources pending) := by
  cases resources <;> simp only [step,control,stepRet,stack,retStep,retSt,cleanupNext]

/-- Cleanup moves the already-owned resource/method pair into the actual call
and retains the original completion independently of the disposer result. -/
theorem cleanupNext_roles {F : Ffi} {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S} (h : StateR NR FR R live framed before after old old' s₀ s)
    {resources targetResources : List (Val × Val)} {pending targetPending : Comp}
    (pairs : TreeR NR R (Encode.pairs resources) (Encode.pairs targetResources))
    (completion : TreeR NR R (Encode.comp pending) (Encode.comp targetPending))
    (pairsLive : treeSupport live (Encode.pairs resources))
    (completionLive : treeSupport live (Encode.comp pending)) :
    StateR NR FR R live framed before after old old'
      (cleanupNext s₀ resources pending) (cleanupNext s targetResources targetPending) := by
  cases resources with
  | nil =>
    obtain rfl := pairs_nil_view pairs
    simpa only [cleanupNext,resume_control] using h.go (completion_roles completion) (completion_support completionLive)
  | cons head rest =>
    rcases head with ⟨resource,method⟩
    obtain ⟨targetResource,targetMethod,targetRest,rfl,resourceRole,methodRole,restRoles⟩ := pairs_cons_view pairs
    have frameRole : FrameR NR R (.s (.dispose rest pending)) (.s (.dispose targetRest targetPending)) :=
      .node _ (.cons (.node _ (.cons restRoles (.cons completion .nil))) .nil)
    have frameLive : treeSupport live (Encode.frame (.s (.dispose rest pending))) :=
      ⟨⟨pairsLive.2,completionLive,True.intro⟩,True.intro⟩
    exact (h.restack (.cons frameRole h.stack) ⟨frameLive,h.stackLive⟩).go
      (.node _ (.cons (.value methodRole) (.cons (.value resourceRole) (.cons (.node _ .nil) .nil))))
      ⟨pairsLive.1.2.1,pairsLive.1.1,True.intro,True.intro⟩

/-- Start the source-selected nonempty scope for either normal or abrupt
completion. Target resources and completion come from the current state. -/
theorem step_scope_cleanup_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (pending : Comp) (resource method : Val) (rest : List (Val × Val)) (frames : List Frame)
    (control : s₀.ctl = completionControl pending)
    (stack : s₀.stack = .s (.scope ((resource,method)::rest))::frames) :
    ∃ targetPending targetResources targetFrames,
      s.ctl = completionControl targetPending ∧ s.stack = .s (.scope targetResources)::targetFrames ∧
      interpC (step F s₀).run C₀ = some (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending,C₀) ∧
      interpC (step F s).run C = some (cleanupNext {s with stack := targetFrames} targetResources targetPending,C) ∧
      StateR NR FR R live framed before after old old'
        (cleanupNext {s₀ with stack := frames} ((resource,method)::rest) pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) := by
  obtain ⟨targetPending,targetControl,pendingRole⟩ := completion_view (h.control_view control)
  obtain ⟨frame,targetFrames,targetStack,frameRole,tailRoles⟩ := h.stack_view stack
  obtain ⟨targetResources,frameEq,pairRoles⟩ := frameRole.scope_view
  rw [frameEq] at targetStack
  have sourceLive := h.stackLive
  rw [stack] at sourceLive
  have compLive : treeSupport live (Encode.comp pending) := by
    have held := h.controlLive
    rw [control] at held
    cases pending <;> exact held
  have post := cleanupNext_roles (h.restack tailRoles sourceLive.2) pairRoles pendingRole sourceLive.1.1.1 compLive
  obtain ⟨targetResource,targetMethod,targetRest,targetResourceEq,_,_,_⟩ := pairs_cons_view pairRoles
  refine ⟨targetPending,targetResources,targetFrames,targetControl,targetStack,?_,?_,post⟩
  · rw [step_scope_cleanup_eq F s₀ pending resource method rest frames control stack]; rfl
  · rw [targetResourceEq] at targetStack ⊢
    rw [step_scope_cleanup_eq F s targetPending targetResource targetMethod targetRest targetFrames targetControl targetStack]; rfl

/-- A completed disposer either calls the next retained pair or resumes the
saved completion. Its return value is discarded by the original interpreter. -/
theorem step_dispose_cleanup_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (returned : Val) (pending : Comp) (resources : List (Val × Val)) (frames : List Frame)
    (control : s₀.ctl = .ret returned) (stack : s₀.stack = .s (.dispose resources pending)::frames) :
    ∃ targetReturned targetPending targetResources targetFrames,
      s.ctl = .ret targetReturned ∧ s.stack = .s (.dispose targetResources targetPending)::targetFrames ∧
      interpC (step F s₀).run C₀ = some (cleanupNext {s₀ with stack := frames} resources pending,C₀) ∧
      interpC (step F s).run C = some (cleanupNext {s with stack := targetFrames} targetResources targetPending,C) ∧
      StateR NR FR R live framed before after old old'
        (cleanupNext {s₀ with stack := frames} resources pending)
        (cleanupNext {s with stack := targetFrames} targetResources targetPending) := by
  obtain ⟨targetReturned,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRole,tailRoles⟩ := h.stack_view stack
  obtain ⟨targetResources,targetPending,frameEq,pairRoles,pendingRole⟩ := frameRole.dispose_view
  rw [frameEq] at targetStack
  have sourceLive := h.stackLive
  rw [stack] at sourceLive
  have post := cleanupNext_roles (h.restack tailRoles sourceLive.2) pairRoles pendingRole sourceLive.1.1.1 sourceLive.1.1.2.1
  refine ⟨targetReturned,targetPending,targetResources,targetFrames,targetControl,targetStack,?_,?_,post⟩
  · rw [step_dispose_cleanup_eq F s₀ returned pending resources frames control stack]; rfl
  · rw [step_dispose_cleanup_eq F s targetReturned targetPending targetResources targetFrames targetControl targetStack]; rfl

end Host.Ts.Owned.Parametric
