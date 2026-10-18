import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeBinding
import host.ts.RenameRuntimeArguments

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.defaultBinding_view {NR : NumV → NumV → Prop} {R : Ren}
    {pattern : Pat} {env : Env} {mode : BindMode} {kind : DeclKind} {f : Frame}
    (h : FrameR NR R (.b (.dflt pattern env mode kind)) f) :
    f = .b (.dflt pattern (R.env env) mode kind) := by
  obtain ⟨bf',rfl,relation⟩ := h.b_view
  have tag := relation.tag_eq
  cases bf' <;> simp only [Encode.bindF,treeTag] at tag
  all_goals try contradiction
  case dflt pattern' env' mode' kind' =>
    cases relation with | node _ fields =>
      cases fields with | cons hp fields =>
        cases fields with | cons he fields =>
          cases fields with | cons hm fields =>
            cases fields with | cons hk fields =>
              cases hp; cases hm; cases hk
              obtain rfl := env_eq_map he
              rfl

private theorem default_present_eq (F : Ffi) (s : St F.S) (pattern : Pat) (fallback : Expr)
    (value : Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s.ctl = .bind (.dflt pattern fallback) value env mode kind) (present : value ≠ .undef) :
    step F s = M.pure (s.go (.bind pattern value env mode kind)) := by
  cases value <;> simp_all only [step,bindStep]
  exact False.elim (present rfl)

private theorem default_missing_eq (F : Ffi) (s : St F.S) (pattern : Pat) (fallback : Expr)
    (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s.ctl = .bind (.dflt pattern fallback) .undef env mode kind) :
    step F s = M.pure ((s.push (.b (.dflt pattern env mode kind))).go (.ev fallback env)) := by
  simp only [step,control,bindStep]

private theorem default_return_eq (F : Ffi) (s : St F.S) (pattern : Pat) (value : Val)
    (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame)
    (control : s.ctl = .ret value) (stack : s.stack = .b (.dflt pattern env mode kind)::frames) :
    step F s = M.pure ({s with stack := frames}.go (.bind pattern value env mode kind)) := by
  simp only [step,control,stepRet,stack,retStep,retB]

end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

def defaultBindingFrameNote (pattern : Pat) (env : Env) (mode : BindMode) (kind : DeclKind) : Tree :=
  .node "Frame.b" [.node "BindF.dflt" [.atom Pat pattern,environmentNote env,.atom BindMode mode,.atom DeclKind kind]]

theorem defaultBindingFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (pattern : Pat) (env : Env) (mode : BindMode) (kind : DeclKind) :
    (defaultBindingFrameNote pattern env mode kind).Holds ν C R (Encode.frame (.b (.dflt pattern (R.env env) mode kind))) :=
  .node _ (.cons (.node _ (.cons (.atom Pat pattern) (.cons (environmentNote_holds ν C R env)
    (.cons (.atom BindMode mode) (.cons (.atom DeclKind kind) .nil))))) .nil)

def RuntimeNotes.bindingResult (notes : RuntimeNotes) (pattern : Pat) (role : Value) (env : Env)
    (mode : BindMode) (kind : DeclKind) : RuntimeNotes :=
  {notes with control := bindingNote pattern role env mode kind}

def RuntimeNotes.defaultBinding (notes : RuntimeNotes) (pattern : Pat) (fallback : Expr) (env : Env)
    (mode : BindMode) (kind : DeclKind) : RuntimeNotes :=
  {notes with control := expressionNote fallback env,stack := defaultBindingFrameNote pattern env mode kind::notes.stack}

/-- A present default operand retains the exact meaning already stored in
binding control; skipping its fallback cannot select a new role. -/
theorem RetainedInventory.default_binding_present_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (pattern : Pat) (fallback : Expr) (value : Val) (role : Value) (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s₀.ctl = .bind (.dflt pattern fallback) value env mode kind) (present : value ≠ .undef)
    (controlNote : notes.runtime.control = bindingNote (.dflt pattern fallback) role env mode kind) :
    ∃ targetValue,
      let t₀ := s₀.go (.bind pattern value env mode kind)
      let t := s.go (.bind pattern targetValue (R.env env) mode kind)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.bindingResult pattern role env mode kind)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).bind_view
  have targetPresent : targetValue ≠ .undef := fun same => present (valueRelation.undef_iff.mpr same)
  have sourceControl := inventory.runtime.source.control
  have targetControlRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := bindingNote_view sourceControl
  have targetRole := bindingNote_view targetControlRole
  have sourceNew : (bindingNote pattern role env mode kind).Holds ν₀ C₀ identity (Encode.ctl (.bind pattern value env mode kind)) := by
    simpa only [identity_environment] using bindingNote_holds pattern env mode kind sourceRole
  have targetNew := bindingNote_holds pattern env mode kind targetRole
  have support := h.controlLive
  rw [control] at support
  have post := h.go (c:=.bind pattern value env mode kind) (c':=.bind pattern targetValue (R.env env) mode kind)
    (Tree.paired sourceNew targetNew) ⟨True.intro,support.2.1,support.2.2.1,True.intro,True.intro,True.intro⟩
  have sourceEq := default_present_eq F s₀ pattern fallback value env mode kind control present
  have targetEq := default_present_eq F s pattern fallback targetValue (R.env env) mode kind targetControl targetPresent
  have sourceRun : interpC (step F s₀).run C₀ = some (s₀.go (.bind pattern value env mode kind),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some (s.go (.bind pattern targetValue (R.env env) mode kind),C) := by rw [targetEq]; rfl
  have runtime : RuntimeInventory (notes.runtime.bindingResult pattern role env mode kind) ν₀ ν C₀ C R live
      (s₀.go (.bind pattern value env mode kind)) (s.go (.bind pattern targetValue (R.env env) mode kind)) :=
    ⟨inventory.runtime.keyLive,⟨sourceNew,inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨targetNew,inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetValue,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- A missing operand schedules the original fallback expression and retains
its real binding continuation and all heap annotations. -/
theorem RetainedInventory.default_binding_missing_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (pattern : Pat) (fallback : Expr) (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s₀.ctl = .bind (.dflt pattern fallback) .undef env mode kind) :
    let t₀ := (s₀.push (.b (.dflt pattern env mode kind))).go (.ev fallback env)
    let t := (s.push (.b (.dflt pattern (R.env env) mode kind))).go (.ev fallback (R.env env))
    interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.defaultBinding pattern fallback env mode kind)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).bind_view
  cases valueRelation
  have sourceFrame : (defaultBindingFrameNote pattern env mode kind).Holds ν₀ C₀ identity
      (Encode.frame (.b (.dflt pattern env mode kind))) := by
    simpa only [identity_environment] using defaultBindingFrameNote_holds ν₀ C₀ identity pattern env mode kind
  have targetFrame := defaultBindingFrameNote_holds ν C R pattern env mode kind
  have support := h.controlLive
  rw [control] at support
  have frameLive : treeSupport live (Encode.frame (.b (.dflt pattern env mode kind))) :=
    ⟨⟨True.intro,support.2.2.1,True.intro,True.intro,True.intro⟩,True.intro⟩
  have post := (h.restack (.cons (Tree.paired sourceFrame targetFrame) h.stack) ⟨frameLive,h.stackLive⟩).go
    (c:=.ev fallback env) (c':=.ev fallback (R.env env))
    (Tree.paired (expressionNote_source ν₀ C₀ fallback env) (expressionNote_holds ν C R fallback env))
    ⟨True.intro,support.2.2.1,True.intro⟩
  have sourceEq := default_missing_eq F s₀ pattern fallback env mode kind control
  have targetEq := default_missing_eq F s pattern fallback (R.env env) mode kind targetControl
  have sourceRun : interpC (step F s₀).run C₀ = some ((s₀.push (.b (.dflt pattern env mode kind))).go (.ev fallback env),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some ((s.push (.b (.dflt pattern (R.env env) mode kind))).go (.ev fallback (R.env env)),C) := by rw [targetEq]; rfl
  have runtime : RuntimeInventory (notes.runtime.defaultBinding pattern fallback env mode kind) ν₀ ν C₀ C R live
      ((s₀.push (.b (.dflt pattern env mode kind))).go (.ev fallback env))
      ((s.push (.b (.dflt pattern (R.env env) mode kind))).go (.ev fallback (R.env env))) :=
    ⟨inventory.runtime.keyLive,⟨expressionNote_source ν₀ C₀ fallback env,.cons sourceFrame inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R fallback env,.cons targetFrame inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- Once fallback evaluation returns, its retained value meaning is passed to
the original binding control and the saved default frame is removed. -/
theorem RetainedInventory.default_binding_return_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (pattern : Pat) (value : Val) (role : Value) (env : Env) (mode : BindMode) (kind : DeclKind)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .b (.dflt pattern env mode kind)::frames)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetValue targetFrames,
      let t₀ := {s₀ with stack := frames}.go (.bind pattern value env mode kind)
      let t := {s with stack := targetFrames}.go (.bind pattern targetValue (R.env env) mode kind)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.bindingResult pattern role env mode kind)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.defaultBinding_view] at targetStack
  have sourceControl := inventory.runtime.source.control
  have targetControlRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceNew : (bindingNote pattern role env mode kind).Holds ν₀ C₀ identity (Encode.ctl (.bind pattern value env mode kind)) := by
    simpa only [identity_environment] using bindingNote_holds pattern env mode kind sourceRole
  have targetNew := bindingNote_holds pattern env mode kind targetRole
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have support := h.stackLive
  rw [stack] at support
  have valueLive := (h.return_values value targetValue control targetControl).2
  have post := (h.restack tailRelation support.2).go
    (c:=.bind pattern value env mode kind) (c':=.bind pattern targetValue (R.env env) mode kind)
    (Tree.paired sourceNew targetNew) ⟨True.intro,valueLive,support.1.1.2.1,True.intro,True.intro,True.intro⟩
  have sourceEq := default_return_eq F s₀ pattern value env mode kind frames control stack
  have targetEq := default_return_eq F s pattern targetValue (R.env env) mode kind targetFrames targetControl targetStack
  have sourceRun : interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.go (.bind pattern value env mode kind),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some ({s with stack := targetFrames}.go (.bind pattern targetValue (R.env env) mode kind),C) := by rw [targetEq]; rfl
  have runtime : RuntimeInventory ({notes.runtime with stack := tail}.bindingResult pattern role env mode kind) ν₀ ν C₀ C R live
      ({s₀ with stack := frames}.go (.bind pattern value env mode kind))
      ({s with stack := targetFrames}.go (.bind pattern targetValue (R.env env) mode kind)) :=
    ⟨inventory.runtime.keyLive,⟨sourceNew,sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨targetNew,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetValue,targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
