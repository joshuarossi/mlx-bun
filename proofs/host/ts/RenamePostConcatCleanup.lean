import host.ts.RenameParametricDescent
import host.ts.RenameParametricExpressionReturns
import host.ts.RenameParametricUndefinedBranch
import host.ts.RenameRetainedBranch
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDispatch
import host.ts.RenameRetainedUndefined
set_option Elab.async false
set_option maxHeartbeats 0

/- Logical not and a null `if` test, reusable for any source and target heap,
renaming and address counter. Negation takes the current operand. A null test
is false by JavaScript truthiness and selects the original else arm. Both
leave every other retained inventory unchanged. -/

namespace Host.Ts.Owned.Parametric

/-- Logical negation only installs its operator frame and evaluates the operand.
`typeof` of an identifier and `delete` are different source transitions. -/
theorem step_not_entry_eq (F : Ffi) (s : St F.S) (operand : Expr) (env : Env)
    (control : s.ctl = .ev (.unary .not operand) env) :
    step F s = M.pure ((s.push (.e (.unary .not))).go (.ev operand env)) := by
  simp only [step,control,evStep]

theorem unary_not_frame_roles {NR : NumV → NumV → Prop} {R : Ren} :
    FrameR NR R (.e (.unary .not)) (.e (.unary .not)) := by
  show TreeR _ _ (Encode.frame _) (Encode.frame _)
  simp only [Encode.frame,Encode.exprF,Encode.atom]
  exact .node _ (.cons (.node _ (.cons (.atom _ _) .nil)) .nil)

theorem unary_not_frame_live {live : Nat → Prop} :
    treeSupport live (Encode.frame (.e (.unary .not))) := by
  dsimp only [Encode.frame,Encode.exprF,Encode.atom,treeSupport,forestSupport]
  exact ⟨⟨True.intro,True.intro⟩,True.intro⟩

theorem FrameR.unaryNot_view {NR : NumV → NumV → Prop} {R : Ren} {f : Frame}
    (h : FrameR NR R (.e (.unary .not)) f) : f = .e (.unary .not) := by
  obtain ⟨payload,rfl,related⟩ := h.e_view
  have tag := related.tag_eq
  cases payload <;> simp only [Encode.exprF,treeTag] at tag
  all_goals try contradiction
  case unary op =>
    cases related with | node _ fields =>
      cases fields with | cons operator rest =>
        cases operator
        rfl

/-- `!boolean` flips that current bit. Heaps, native state and the address
counter stay unchanged, and the target bit is the same flip. -/
theorem step_not_bool_eq (F : Ffi) (s : St F.S) (bit : Bool) (frames : List Frame)
    (control : s.ctl = .ret (.bool bit))
    (stack : s.stack = .e (.unary .not)::frames) :
    step F s = M.pure (({s with stack := frames}).ret (.bool !bit)) := by
  cases bit <;> (
    simp only [step,control,stepRet,stack,retStep,retE,unaryOp,truthy,retS,St.ret]
    unfold M.bind M.pure
    rfl)

/-- An object is truthy, so `!object` returns `false` without reading the heap
or changing native state. The same boolean is returned on every related target. -/
theorem step_not_object_eq (F : Ffi) (s : St F.S) (address : Nat) (frames : List Frame)
    (control : s.ctl = .ret (.obj address))
    (stack : s.stack = .e (.unary .not)::frames) :
    step F s = M.pure (({s with stack := frames}).ret (.bool false)) := by
  simp only [step,control,stepRet,stack,retStep,retE,unaryOp,truthy,retS,St.ret]
  unfold M.bind M.pure
  rfl

/-- `null` is false as an `if` test. The original else arm is selected, or the
frame returns undefined when that arm is absent. -/
theorem step_if_null_eq (F : Ffi) (s : St F.S) (yes : Stmt) (no : Option Stmt)
    (env : Env) (fs : List Frame) (control : s.ctl = .ret .null)
    (stack : s.stack = .s (.if_ yes no env)::fs) :
    step F s = M.pure {s with ctl := branchCtl false yes no env,stack := fs} := by
  cases no <;> funext β k <;>
    simp only [step,control,stepRet,stack,retStep,retSt,truthy,M.bind,M.pure,
      Bool.cond_false,retS,St.ret,St.go,branchCtl]

theorem step_if_null_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (yes : Stmt) (no : Option Stmt) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret .null) (stack : s₀.stack = .s (.if_ yes no env)::frames) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with ctl := branchCtl false yes no env,stack := frames},C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        {s₀ with ctl := branchCtl false yes no env,stack := frames} result ∧ result.heap = s.heap := by
  obtain ⟨_,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨_,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.if_view] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have environmentLive : treeSupport live (Encode.env env) := support.1.1.2.2.1
  have post : StateR NR FR R live framed before after old old'
      {s₀ with ctl := branchCtl false yes no env,stack := frames}
      {s with ctl := branchCtl false yes no (R.env env),stack := targetFrames} := by
    have restacked := h.restack tailRelation support.2
    cases no <;> dsimp only [branchCtl]
    · exact restacked.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    · exact restacked.go (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil)))
        ⟨True.intro,environmentLive,True.intro⟩
  refine ⟨_,?_,?_,post,rfl⟩
  · rw [step_if_null_eq F s₀ yes no env frames control stack]; rfl
  · rw [step_if_null_eq F s yes no (R.env env) targetFrames targetControl targetStack]; rfl

theorem step_not_entry_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (operand : Expr) (env₀ env : Env)
    (sourceControl : s₀.ctl = .ev (.unary .not operand) env₀)
    (targetControl : s.ctl = .ev (.unary .not operand) env) :
    let source := (s₀.push (.e (.unary .not))).go (.ev operand env₀)
    let target := (s.push (.e (.unary .not))).go (.ev operand env)
    interpC (step F s₀).run C₀ = some (source,C₀) ∧
      interpC (step F s).run C = some (target,C) ∧
      StateR NR FR R live framed before after old old' source target := by
  have environment : TreeR NR R (Encode.env env₀) (Encode.env env) := by
    have related := h.control
    rw [sourceControl,targetControl] at related
    cases related with | node _ fields =>
      cases fields with | cons _ fields =>
        cases fields with | cons environment _ => exact environment
  have environmentLive : treeSupport live (Encode.env env₀) := by
    have support := h.controlLive
    rw [sourceControl] at support
    exact support.2.1
  have restacked := h.restack (.cons unary_not_frame_roles h.stack) ⟨unary_not_frame_live,h.stackLive⟩
  refine ⟨?_,?_,restacked.go (.node _ (.cons (.atom _ _) (.cons environment .nil)))
    ⟨True.intro,environmentLive,True.intro⟩⟩
  · rw [step_not_entry_eq F s₀ operand env₀ sourceControl]; rfl
  · rw [step_not_entry_eq F s operand env targetControl]; rfl

end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

def unaryFrameNote (op : UnOp) : Tree :=
  .node "Frame.e" [.node "ExprF.unary" [.atom UnOp op]]

theorem unaryFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (op : UnOp) :
    (unaryFrameNote op).Holds ν C R (Encode.frame (.e (.unary op))) := by
  exact .node _ (.cons (.node _ (.cons (.atom UnOp op) .nil)) .nil)

def RuntimeNotes.notDescent (notes : RuntimeNotes) (operand : Expr) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote operand env,stack := unaryFrameNote .not::notes.stack}

theorem RetainedInventory.not_entry_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (operand : Expr) (env : Env) (control : s₀.ctl = .ev (.unary .not operand) env) :
    let source := (s₀.push (.e (.unary .not))).go (.ev operand env)
    let target := (s.push (.e (.unary .not))).go (.ev operand (R.env env))
    interpC (step F s₀).run C₀ = some (source,C₀) ∧
      interpC (step F s).run C = some (target,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
      RetainedInventory (notes.withRuntime (notes.runtime.notDescent operand env)) ν₀ ν C₀ C R live source target := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_not_entry_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h operand env (R.env env) control (h.control_view control).ev_view
  have runtime : RuntimeInventory (notes.runtime.notDescent operand env) ν₀ ν C₀ C R live
      ((s₀.push (.e (.unary .not))).go (.ev operand env))
      ((s.push (.e (.unary .not))).go (.ev operand (R.env env))) :=
    ⟨inventory.runtime.keyLive,
      ⟨expressionNote_source ν₀ C₀ operand env,
        .cons (by simpa only [identity_environment] using unaryFrameNote_holds ν₀ C₀ identity .not)
          inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R operand env,
        .cons (unaryFrameNote_holds ν C R .not) inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨sourceRun,targetRun,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

theorem RetainedInventory.not_bool_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (bit : Bool) (frames : List Frame) (control : s₀.ctl = .ret (.bool bit))
    (stack : s₀.stack = .e (.unary .not)::frames) :
    ∃ targetFrames,
      let source := ({s₀ with stack := frames}).ret (.bool !bit)
      let target := ({s with stack := targetFrames}).ret (.bool !bit)
      interpC (step F s₀).run C₀ = some (source,C₀) ∧
        interpC (step F s).run C = some (target,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
        RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool !bit) notes.runtime.stack.tail))
          ν₀ ν C₀ C R live source target := by
  obtain ⟨_,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨_,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.unaryNot_view] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackRoles := inventory.runtime.target.stack
  rw [stack,List.map_cons] at sourceStack
  rw [targetStack,List.map_cons] at targetStackRoles
  have sourceTail : ForestHolds ν₀ C₀ identity notes.runtime.stack.tail (List.map Encode.frame frames) := by
    simpa only [List.tail_cons] using sourceStack.tails
  have targetTail : ForestHolds ν C R notes.runtime.stack.tail (List.map Encode.frame targetFrames) := by
    simpa only [List.tail_cons] using targetStackRoles.tails
  have runtime : RuntimeInventory (notes.runtime.binaryResult (.bool !bit) notes.runtime.stack.tail)
      ν₀ ν C₀ C R live (({s₀ with stack := frames}).ret (.bool !bit))
      (({s with stack := targetFrames}).ret (.bool !bit)) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.bool !bit),sourceTail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.bool !bit),targetTail,inventory.runtime.target.cells⟩⟩
  have support := h.stackLive
  rw [stack] at support
  exact ⟨targetFrames,
    by rw [step_not_bool_eq F s₀ bit frames control stack]; rfl,
    by rw [step_not_bool_eq F s bit targetFrames targetControl targetStack]; rfl,
    (h.restack tailRelation support.2).go (c := .ret (.bool !bit)) (c' := .ret (.bool !bit))
      (.node _ (.cons (.value (.bool !bit)) .nil)) ⟨True.intro,True.intro⟩,
    inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

theorem RetainedInventory.not_object_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (address : Nat) (frames : List Frame) (control : s₀.ctl = .ret (.obj address))
    (stack : s₀.stack = .e (.unary .not)::frames) :
    ∃ targetFrames,
      let source := ({s₀ with stack := frames}).ret (.bool false)
      let target := ({s with stack := targetFrames}).ret (.bool false)
      interpC (step F s₀).run C₀ = some (source,C₀) ∧
        interpC (step F s).run C = some (target,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
        RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail))
          ν₀ ν C₀ C R live source target := by
  obtain ⟨_,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.unaryNot_view] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackRoles := inventory.runtime.target.stack
  rw [stack,List.map_cons] at sourceStack
  rw [targetStack,List.map_cons] at targetStackRoles
  have sourceTail : ForestHolds ν₀ C₀ identity notes.runtime.stack.tail (List.map Encode.frame frames) := by
    simpa only [List.tail_cons] using sourceStack.tails
  have targetTail : ForestHolds ν C R notes.runtime.stack.tail (List.map Encode.frame targetFrames) := by
    simpa only [List.tail_cons] using targetStackRoles.tails
  have runtime : RuntimeInventory (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail)
      ν₀ ν C₀ C R live (({s₀ with stack := frames}).ret (.bool false))
      (({s with stack := targetFrames}).ret (.bool false)) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.bool false),sourceTail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.bool false),targetTail,inventory.runtime.target.cells⟩⟩
  have support := h.stackLive
  rw [stack] at support
  exact ⟨targetFrames,
    by rw [step_not_object_eq F s₀ address frames control stack]; rfl,
    by rw [step_not_object_eq F s (R.a address) targetFrames targetControl targetStack]; rfl,
    (h.restack tailRelation support.2).go (c := .ret (.bool false)) (c' := .ret (.bool false))
      (.node _ (.cons (.value (.bool false)) .nil)) ⟨True.intro,True.intro⟩,
    inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

theorem RetainedInventory.if_null_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (yes : Stmt) (no : Option Stmt) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret .null)
    (stack : s₀.stack = .s (.if_ yes no env)::frames) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with ctl := branchCtl false yes no env,stack := frames}
      let t := {s with ctl := branchCtl false yes no (R.env env),stack := targetFrames}
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨branchControlNote false yes no env,tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨_,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨_,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.if_view] at targetStack
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  obtain ⟨_,left,right,post,_⟩ := step_if_null_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h yes no env frames control stack
  have actual : interpC (step F s).run C =
      some ({s with ctl := branchCtl false yes no (R.env env),stack := targetFrames},C) := by
    rw [step_if_null_eq F s yes no (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have runtime : RuntimeInventory ⟨branchControlNote false yes no env,tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      {s₀ with ctl := branchCtl false yes no env,stack := frames}
      {s with ctl := branchCtl false yes no (R.env env),stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,
      ⟨by simpa only [identity_environment] using branchControlNote_holds ν₀ C₀ identity false yes no env,
        sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨branchControlNote_holds ν C R false yes no env,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,left,actual,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
