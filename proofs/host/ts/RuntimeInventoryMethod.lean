import host.ts.RenameRuntimeCallStart
import host.ts.RenameRuntimeDispatch
import host.ts.RenamePublicInventory
import host.ts.RenameHeapInventory
import host.ts.RenameArrayInventory
import host.ts.RenameParametricRegistry
import host.ts.RenameParametricArrayMethod
import host.ts.RenameParametricNamespace
import host.ts.RenameReadStack

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem method_lookup_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (property : Option PropV) (frames : List Frame)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (path : OrdinaryLookup s₀ name 16 a property) :
    ∃ targetProperty targetFrames,
      s.stack = .c (.member (.str name) args (R.env env) optObj optCall)::targetFrames ∧
      interpC (step F s₀).run C₀ = some
        (Host.Ts.readProp F (({s₀ with stack := frames}.push (.c (.method (.obj a) args env optCall)))) (.obj a) property,C₀) ∧
      interpC (step F s).run C = some
        (Host.Ts.readProp F (({s with stack := targetFrames}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall)))) (.obj (R.a a)) targetProperty,C) ∧
      Parametric.StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F (({s₀ with stack := frames}.push (.c (.method (.obj a) args env optCall)))) (.obj a) property)
        (Host.Ts.readProp F (({s with stack := targetFrames}.push (.c (.method (.obj (R.a a)) args (R.env env) optCall)))) (.obj (R.a a)) targetProperty) ∧
      OptionRel (PropR NR R) property targetProperty := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  have support := h.stackLive
  rw [stack] at support
  have frameRole : Parametric.FrameR NR R (.c (.method (.obj a) args env optCall))
      (.c (.method (.obj (R.a a)) args (R.env env) optCall)) := by
    repeat first | exact env_roles NR R env | constructor
  have frameLive : treeSupport live (Encode.frame (.c (.method (.obj a) args env optCall))) :=
    ⟨⟨alive,True.intro,support.1.1.2.2.1,True.intro,True.intro⟩,True.intro⟩
  have popped := h.restack (.cons frameRole tailRelation) ⟨frameLive,support.2⟩
  obtain ⟨p,sourceGet,targetGet,relation,propertyLive⟩ :=
    (path.withStack (.c (.method (.obj a) args env optCall)::frames)).transport F popped.heap name alive
  refine ⟨p,targetFrames,targetStack,?_,?_,?_,relation⟩
  · rw [step_method_lookup_eq F s₀ a name args env optObj optCall property frames control stack sourceGet]; rfl
  · rw [step_method_lookup_eq F s (R.a a) name args (R.env env) optObj optCall p targetFrames targetControl targetStack targetGet]; rfl
  · cases relation with
    | none => exact popped.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    | some hp => exact popped.readProp F (.obj a) (.obj (R.a a)) (.obj a) alive _ _ hp (propertyLive _ rfl)

def methodReturnState {S : Type} (s : St S) (receiver : Nat) (args : List Elem) (env : Env)
    (optional : Bool) (frames : List Frame) (value : Val) : St S :=
  (({s with stack := frames}.push (.c (.method (.obj receiver) args env optional)))).ret value

def RuntimeNotes.methodResult (notes : RuntimeNotes) (receiver : Nat) (args : List Elem) (env : Env)
    (optional : Bool) (role : Value) (tail : List Tree) : RuntimeNotes :=
  {notes with control := returnNote role,stack := callStartFrameNote (.method optional) (.obj receiver) args env::tail}

private theorem method_return_inventory {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (frames targetFrames : List Frame) (head : Tree) (tail : List Tree) (role : Value) (value targetValue : Val)
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (targetStack : s.stack = .c (.member (.str name) args (R.env env) optObj optCall)::targetFrames)
    (stackNotes : notes.stack = head::tail)
    (sourceRole : role.Holds ν₀ C₀ identity value) (targetRole : role.Holds ν C R targetValue) :
    RuntimeInventory (notes.methodResult a args env optCall role tail) ν₀ ν C₀ C R live
      (methodReturnState s₀ a args env optCall frames value)
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames targetValue) := by
  have sourceNotes := inventory.source.stack
  have targetNotes := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  refine ⟨inventory.keyLive,⟨returnNote_holds sourceRole,.cons ?_ sourceNotes.tail,inventory.source.cells⟩,
    ⟨returnNote_holds targetRole,.cons ?_ targetNotes.tail,inventory.target.cells⟩⟩
  · simpa only [identity_environment,CallStart.frame] using callStartFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity)
      (.method optCall) (.obj a) args env (.obj a) (Value.Holds.obj a)
  · exact callStartFrameNote_holds (.method optCall) (.obj a) args env (.obj (R.a a)) (Value.Holds.obj a)

/-- Own-data method lookup consumes the retained public field meaning.
The original method frame keeps the receiver while arguments are scheduled. -/
theorem RuntimeInventory.method_data_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (o₀ : Obj) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (value : Val) (role : Value) (w e : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data value w e))
    (entry : publics.fields a name = some role) (stackNotes : notes.stack = head::tail) :
    ∃ targetValue targetFrames,
      let t₀ := methodReturnState s₀ a args env optCall frames value
      let t := methodReturnState s (R.a a) args (R.env env) optCall targetFrames targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧
      interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.methodResult a args env optCall role tail) ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧ t₀.heap = s₀.heap ∧ t.heap = s.heap := by
  have alive := publicInventory.keyLive a name role entry
  obtain ⟨sourceValue,sourceField,sourceRole⟩ := publicInventory.source a name role entry
  have sourceEq := sourceField.unique (show PublicData s₀ a name value from ⟨o₀,w,e,object,descriptor⟩)
  subst sourceValue
  obtain ⟨targetValue,targetField,targetRole⟩ := publicInventory.target a name role entry
  obtain ⟨o,read,objectRelation,objectLive⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetObject,tw,te,targetRead,targetDescriptor⟩ := targetField
  have same := HObj.obj.inj (Option.some.inj (targetRead.symm.trans read))
  subst targetObject
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  obtain ⟨result,sourceRun,targetRun,post⟩ := step_method_data_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a o₀ name args env optObj optCall value w e frames control stack object ordinary descriptor
  have actual : interpC (step F s).run C = some
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames targetValue,C) := by
    rw [step_method_data_eq F s (R.a a) o name args (R.env env) optObj optCall targetValue tw te targetFrames
      targetControl targetStack read (objectRelation.ordinary ordinary) targetDescriptor]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetValue,targetFrames,sourceRun,actual,post,?_,?_,rfl,rfl⟩
  · exact method_return_inventory inventory a name args env optObj optCall frames targetFrames head tail role value targetValue
      stack targetStack stackNotes sourceRole targetRole
  · exact publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

/-- An inherited object method keeps the address meaning selected by the
actual source prototype path. The descriptor is initialized source metadata;
there is no target lookup or new interpretation of a returned number. -/
theorem RuntimeInventory.method_object_path_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a callee : Nat) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (w e : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (path : OrdinaryLookup s₀ name 16 a (some (.data (.obj callee) w e)))
    (stackNotes : notes.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := methodReturnState s₀ a args env optCall frames (.obj callee)
      let t := methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee))
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.methodResult a args env optCall (.obj callee) tail) ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧ t₀.heap = s₀.heap ∧ t.heap = s.heap := by
  obtain ⟨property,targetFrames,targetStack,sourceRun,targetRun,post,relation⟩ :=
    method_lookup_fields F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h
      a name args env optObj optCall _ frames control stack path
  cases relation with | some relation =>
    obtain ⟨targetValue,rfl,valueRelation⟩ := relation.data
    cases valueRelation
    refine ⟨targetFrames,sourceRun,targetRun,post,?_,?_,rfl,rfl⟩
    · exact method_return_inventory inventory a name args env optObj optCall frames targetFrames head tail (.obj callee)
        (.obj callee) (.obj (R.a callee)) stack targetStack stackNotes (.obj callee) (.obj callee)
    · exact publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

def methodGetterState {S : Type} (s : St S) (receiver getter : Nat) (args : List Elem) (env : Env)
    (optional : Bool) (frames : List Frame) : St S :=
  (({s with stack := frames}.push (.c (.method (.obj receiver) args env optional)))).go (.call (.obj getter) (.obj receiver) [])

def RuntimeNotes.methodGetter (notes : RuntimeNotes) (receiver getter : Nat) (args : List Elem) (env : Env)
    (optional : Bool) (tail : List Tree) : RuntimeNotes :=
  {notes with control := callNote (.obj getter) (.obj receiver) [],stack := callStartFrameNote (.method optional) (.obj receiver) args env::tail}

/-- Accessor lookup starts the real getter with the retained receiver and
initialized getter address. Its execution, rather than this lookup step,
determines the eventual returned method value. -/
theorem RuntimeInventory.method_getter_path_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a getter : Nat) (name : Name) (args : List Elem) (env : Env) (optObj optCall : Bool)
    (setter : Val) (e : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (path : OrdinaryLookup s₀ name 16 a (some (.acc (.obj getter) setter e)))
    (stackNotes : notes.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := methodGetterState s₀ a getter args env optCall frames
      let t := methodGetterState s (R.a a) (R.a getter) args (R.env env) optCall targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.methodGetter a getter args env optCall tail) ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧ t₀.heap = s₀.heap ∧ t.heap = s.heap := by
  obtain ⟨property,targetFrames,targetStack,sourceRun,targetRun,post,relation⟩ :=
    method_lookup_fields F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h
      a name args env optObj optCall _ frames control stack path
  cases relation with | some relation =>
    obtain ⟨targetGetter,targetSetter,rfl,getterRelation,_⟩ := relation.accessor
    cases getterRelation
    have sourceNotes := inventory.source.stack
    have targetNotes := inventory.target.stack
    rw [stackNotes,stack,List.map_cons] at sourceNotes
    rw [stackNotes,targetStack,List.map_cons] at targetNotes
    refine ⟨targetFrames,sourceRun,targetRun,post,?_,?_,rfl,rfl⟩
    · refine ⟨inventory.keyLive,⟨callNote_holds (.obj getter) (.obj a) .nil,.cons ?_ sourceNotes.tail,inventory.source.cells⟩,
        ⟨callNote_holds (.obj getter) (.obj a) .nil,.cons ?_ targetNotes.tail,inventory.target.cells⟩⟩
      · simpa only [identity_environment,CallStart.frame] using callStartFrameNote_holds (ν:=ν₀) (C:=C₀) (R:=identity)
          (.method optCall) (.obj a) args env (.obj a) (Value.Holds.obj a)
      · exact callStartFrameNote_holds (.method optCall) (.obj a) args env (.obj (R.a a)) (Value.Holds.obj a)
    · exact publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

/-- Non-index array method lookup follows the actual ordinary prototype.
The fixed callee address comes from that initialized source descriptor. -/
theorem RuntimeInventory.method_array_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a prototype callee : Nat) (o₀ p₀ : Obj) (values : List Val) (name : Name) (args : List Elem)
    (env : Env) (optObj optCall w e : Bool) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (array : o₀.kind = .array values)
    (nonindex : keyIndex (.str name) = none) (nonlength : keyEq (.str name) kLength = false)
    (absent : findProp (.str name) o₀.props = none) (parent : o₀.proto = .obj prototype)
    (prototypeObject : s₀.heap.get prototype = some (.obj p₀)) (ordinary : p₀.kind = .ordinary)
    (descriptor : findProp (.str name) p₀.props = some (.data (.obj callee) w e))
    (notFramed : ¬ framed a) (stackNotes : notes.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := methodReturnState s₀ a args env optCall frames (.obj callee)
      let t := methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee))
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.methodResult a args env optCall (.obj callee) tail) ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧ t₀.heap = s₀.heap ∧ t.heap = s.heap := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨o,read,objectRelation,objectLive⟩ := h.heap.readObject a o₀ alive notFramed object
  have kindRelation := objectRelation.kind
  rw [array] at kindRelation
  obtain ⟨targetValues,targetArray,_⟩ := kind_array kindRelation
  have targetAbsent : findProp (.str name) o.props = none := by
    have relation := objectRelation.properties.find_string name
    rw [absent] at relation
    generalize found : findProp (.str name) o.props = property at relation
    cases relation
    rfl
  have targetParent : o.proto = .obj (R.a prototype) := by
    have relation := objectRelation.prototype
    rw [parent] at relation
    generalize found : o.proto = value at relation
    cases relation
    rfl
  have parentAlive : live prototype := by have support := objectLive.2.1; rw [parent] at support; exact support
  obtain ⟨p,parentRead,parentRelation,_⟩ := h.heap.readOrdinary prototype p₀ parentAlive prototypeObject ordinary
  obtain ⟨targetValue,targetDescriptor,valueRelation⟩ := parentRelation.properties.find_data name (.obj callee) w e descriptor
  cases valueRelation
  obtain ⟨result,sourceRun,targetRun,post,_⟩ := step_array_method_from_source_fields F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a prototype o₀ p₀ values name args env optObj optCall (.obj callee) w e frames
    control stack object array nonindex nonlength absent parent prototypeObject ordinary descriptor notFramed
  have actual : interpC (step F s).run C = some
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames (.obj (R.a callee)),C) := by
    rw [step_array_method_eq F s (R.a a) (R.a prototype) o p targetValues name args (R.env env) optObj optCall (.obj (R.a callee)) w e
      targetFrames targetControl targetStack read targetArray nonindex nonlength targetAbsent targetParent parentRead
      (parentRelation.ordinary ordinary) targetDescriptor]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetFrames,sourceRun,actual,post,?_,?_,rfl,rfl⟩
  · exact method_return_inventory inventory a name args env optObj optCall frames targetFrames head tail (.obj callee)
      (.obj callee) (.obj (R.a callee)) stack targetStack stackNotes (.obj callee) (.obj callee)
  · exact publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

/-- Namespace method lookup reads the initialized export cell's retained
meaning. Export mapping and the target cell read follow from the source
namespace and ownership relation. -/
theorem RuntimeInventory.method_namespace_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (publics : PublicNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publics ν₀ ν C₀ C R live s₀ s)
    (a cell : Nat) (o₀ : Obj) (exports : Env) (name : Name) (args : List Elem)
    (env : Env) (optObj optCall : Bool) (value : Val) (role : Value)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optObj optCall)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (namespaceKind : o₀.kind = .ns exports)
    (exportCell : findExport name exports = some cell) (sourceCell : s₀.heap.get cell = some (.cell (some value)))
    (entry : notes.cells.cells cell = some role) (stackNotes : notes.stack = head::tail) :
    ∃ targetValue targetFrames,
      let t₀ := methodReturnState s₀ a args env optCall frames value
      let t := methodReturnState s (R.a a) args (R.env env) optCall targetFrames targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RuntimeInventory (notes.methodResult a args env optCall role tail) ν₀ ν C₀ C R live t₀ t ∧
      PublicInventory publics ν₀ ν C₀ C R live t₀ t ∧ t₀.heap = s₀.heap ∧ t.heap = s.heap := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨o,read,targetKind,_⟩ := h.heap.read_namespace a o₀ exports alive object namespaceKind
  obtain ⟨targetValue,targetCell,_,_⟩ := h.heap.readCell cell value (inventory.keyLive cell role entry) sourceCell
  have targetExport : findExport name (R.env exports) = some (R.a cell) := by
    rw [findExport_eq_lookupEnv,lookupEnv_map,← findExport_eq_lookupEnv,exportCell]; rfl
  have sourceRole : role.Holds ν₀ C₀ identity value := by
    simpa only [cellValueAt,identity,id_eq,sourceCell] using inventory.source.cells cell role entry
  have targetRole : role.Holds ν C R targetValue := by
    simpa only [cellValueAt,targetCell] using inventory.target.cells cell role entry
  obtain ⟨result,sourceRun,targetRun,post⟩ := step_namespace_method_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a o₀ exports name args env optObj optCall cell value frames
    control stack object namespaceKind exportCell sourceCell
  have actual : interpC (step F s).run C = some
      (methodReturnState s (R.a a) args (R.env env) optCall targetFrames targetValue,C) := by
    rw [step_namespace_method_eq F s (R.a a) o (R.env exports) name args (R.env env) optObj optCall (R.a cell)
      targetValue targetFrames targetControl targetStack read targetKind targetExport targetCell]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetValue,targetFrames,sourceRun,actual,post,?_,?_,rfl,rfl⟩
  · exact method_return_inventory inventory a name args env optObj optCall frames targetFrames head tail role value targetValue
      stack targetStack stackNotes sourceRole targetRole
  · exact publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

/-- Every method lookup above leaves both heaps unchanged, including getter
dispatch before its body runs. These equalities carry all other retained
inventory families without post-state annotation premises. -/
theorem method_lookup_inventories {S : Type} {heapNotes : HeapNotes} {arrayNotes : ArrayNotes} {publicNotes : PublicNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (heap : HeapInventory heapNotes ν₀ ν C₀ C R live s₀ s)
    (arrays : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publics : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (source : t₀.heap = s₀.heap) (target : t.heap = s.heap) :
    HeapInventory heapNotes ν₀ ν C₀ C R live t₀ t ∧
      ArrayInventory arrayNotes ν₀ ν C₀ C R live t₀ t ∧ PublicInventory publicNotes ν₀ ν C₀ C R live t₀ t := by
  exact ⟨heap.frame (fun _ alive => alive) (fun _ _ => source ▸ rfl) (fun _ _ => target ▸ rfl),
    arrays.frame (fun _ alive => alive) (fun _ _ _ => source ▸ rfl) (fun _ _ _ => target ▸ rfl),
    publics.frame (fun _ alive => alive) (fun _ _ _ _ => source ▸ rfl) (fun _ _ _ _ => target ▸ rfl)⟩

end Host.Ts.Owned.Annotated
