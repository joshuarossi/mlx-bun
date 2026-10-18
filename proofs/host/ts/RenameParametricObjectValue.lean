import host.ts.RenameParametricObjectNext
import host.ts.RenameParametricArrayLiteral
import host.ts.RenameParametricPropWrites
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.objectValue_view {NR : NumV → NumV → Prop} {R : Ren}
    {owner : Nat} {name : Name} {properties : List Property} {env : Env} {frame : Frame}
    (h : FrameR NR R (.l (.objVal owner (.str name) properties env)) frame) :
    frame = .l (.objVal (R.a owner) (.str name) properties (R.env env)) := by
  obtain ⟨literal,rfl,relation⟩ := h.l_view
  have tag := relation.tag_eq
  cases literal <;> simp only [Encode.litF,treeTag] at tag
  all_goals try contradiction
  case objVal targetOwner targetKey targetProperties targetEnv =>
    cases relation with | node _ fields =>
      cases fields with | cons ownerRole fields =>
        cases fields with | cons keyRole fields =>
          cases fields with | cons propertiesRole fields =>
            cases fields with | cons environmentRole fields =>
              cases ownerRole
              cases propertiesRole
              rw [KeyR.eq_map keyRole]
              obtain rfl := env_eq_map environmentRole
              rfl

def objectValueState {S : Type} (s : St S) (owner : Nat) (o : Obj) (name : Name) (value : Val)
    (frames : List Frame) (env : Env) (action : ObjectAction) : St S :=
  action.advance ({s with stack := frames}.setObj owner
    {o with props := setPropL (.str name) (.data value true true) o.props}) owner env

theorem step_object_value_eq (F : Ffi) (s : St F.S) (owner : Nat) (name : Name) (value : Val)
    (o : Obj) (frames : List Frame) (env : Env) (action : ObjectAction)
    (valid : action.valid) (control : s.ctl = .ret value)
    (stack : s.stack = .l (.objVal owner (.str name) action.properties env)::frames)
    (object : s.heap.get owner = some (.obj o)) (ordinary : o.kind = .ordinary) :
    step F s = M.pure (objectValueState s owner o name value frames env action) := by
  simp only [step,control,stepRet,stack,retStep,retL,defineData,St.obj?,object,ordinary]
  rw [objNext_action_eq F _ owner env action valid]
  simp only [objectValueState,ObjectAction.advance,St.go,St.setObj,ordinary]

/-- The original object-literal continuation installs its current value as
an own writable/enumerable field and runs the original next-field scheduler. -/
theorem step_object_value_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (value : Val) (o₀ : Obj) (frames : List Frame) (env : Env)
    (action : ObjectAction) (valid : action.valid) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .l (.objVal owner (.str name) action.properties env)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue targetObject targetFrames,
      s.heap.get (R.a owner) = some (.obj targetObject) ∧
      interpC (step F s₀).run C₀ = some (objectValueState s₀ owner o₀ name value frames env action,C₀) ∧
      interpC (step F s).run C = some (objectValueState s (R.a owner) targetObject name targetValue targetFrames (R.env env) action,C) ∧
      StateR NR FR R live framed before after old old'
        (objectValueState s₀ owner o₀ name value frames env action)
        (objectValueState s (R.a owner) targetObject name targetValue targetFrames (R.env env) action) := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.objectValue_view] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.1
  have envLive : treeSupport live (Encode.env env) := support.1.1.2.2.2.1
  have valueLive : valueSupport live value := by have hl := h.controlLive; rw [control] at hl; exact hl.1
  have sourceWord : owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord : R.a owner < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  obtain ⟨o,targetRead,objectRelation,objectLive⟩ := h.heap.readOrdinary owner o₀ alive object ordinary
  have propertyRole : PropR NR R (.data value true true) (.data targetValue true true) :=
    .node _ (.cons (.value valueRelation) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
  have propertySupport := props_support_set objectLive.2.2.1 name (.data value true true)
    ⟨valueLive,True.intro,True.intro,True.intro⟩
  have newSupport : treeSupport live (Encode.obj {o₀ with props := setPropL (.str name) (.data value true true) o₀.props}) :=
    ⟨objectLive.1,objectLive.2.1,propertySupport,objectLive.2.2.2⟩
  have stored := (h.restack tailRelation support.2).setObject owner _ _ alive
    (h.heap.ordinary_notFramed owner o₀ alive object ordinary)
    (objectRelation.with_props _ _ (objectRelation.properties.set_string name _ _ propertyRole))
    newSupport sourceWord targetWord
  exact ⟨targetValue,o,targetFrames,targetRead,
    by rw [step_object_value_eq F s₀ owner name value o₀ frames env action valid control stack object ordinary]; rfl,
    by rw [step_object_value_eq F s (R.a owner) name targetValue o targetFrames (R.env env) action valid
      targetControl targetStack targetRead (objectRelation.ordinary ordinary)]; rfl,
    action.advance_roles stored owner env alive envLive⟩
end Host.Ts.Owned.Parametric
