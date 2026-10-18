import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeBinding
import host.ts.RenameRuntimeArguments
import host.ts.RenameParametricArrayBinding

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

private theorem string_key_fields_view {NR : NumV → NumV → Prop} {R : Ren}
    (names : List Name) (keys : List PKey)
    (relation : ForestR NR R (names.map fun name => Encode.key (.str name)) (keys.map Encode.key)) :
    keys = names.map PKey.str := by
  induction names generalizing keys with
  | nil => cases keys with
    | nil => rfl
    | cons key keys => cases relation
  | cons name names ih => cases keys with
    | nil => cases relation
    | cons key keys => cases relation with | cons head tail =>
      have same : key = .str name := KeyR.eq_map head
      subst key
      rw [ih keys tail]
      rfl

theorem FrameR.objectBinding_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Nat} {patterns : List (Key × Pat)} {used : List Name} {env : Env} {mode : BindMode} {kind : DeclKind} {f : Frame}
    (h : FrameR NR R (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind)) f) :
    f = .b (.obj (.obj (R.a a)) patterns none (used.map PKey.str) (R.env env) mode kind) := by
  obtain ⟨bf',rfl,relation⟩ := h.b_view
  have tag := relation.tag_eq
  cases bf' <;> simp only [Encode.bindF,treeTag] at tag
  all_goals try contradiction
  case obj source' patterns' rest' used' env' mode' kind' =>
    cases relation with | node _ fields =>
      cases fields with | cons hs fields => cases fields with | cons hp fields =>
        cases fields with | cons hr fields => cases fields with | cons hu fields =>
          cases fields with | cons he fields => cases fields with | cons hm fields =>
            cases fields with | cons hk fields =>
              cases hs with | value hs =>
                cases hs; cases hp; cases hr; cases hm; cases hk
                obtain rfl := env_eq_map he
                have same : used' = used.map PKey.str := by
                  cases hu with | node _ fields =>
                    exact string_key_fields_view used used' (by simpa only [List.map_map,Function.comp_def] using fields)
                subst used'
                rfl

theorem FrameR.objectValueBinding_view {NR : NumV → NumV → Prop} {R : Ren}
    {a : Nat} {name : Name} {pattern : Pat} {patterns : List (Key × Pat)} {used : List Name}
    {env : Env} {mode : BindMode} {kind : DeclKind} {f : Frame}
    (h : FrameR NR R (.b (.objVal (.obj a) (.str name) pattern patterns none (used.map PKey.str) env mode kind)) f) :
    f = .b (.objVal (.obj (R.a a)) (.str name) pattern patterns none (used.map PKey.str) (R.env env) mode kind) := by
  obtain ⟨bf',rfl,relation⟩ := h.b_view
  have tag := relation.tag_eq
  cases bf' <;> simp only [Encode.bindF,treeTag] at tag
  all_goals try contradiction
  case objVal source' key' pattern' patterns' rest' used' env' mode' kind' =>
    cases relation with | node _ fields =>
      cases fields with | cons hs fields => cases fields with | cons hkey fields =>
        cases fields with | cons hp fields => cases fields with | cons hps fields =>
          cases fields with | cons hr fields => cases fields with | cons hu fields =>
            cases fields with | cons he fields => cases fields with | cons hm fields =>
              cases fields with | cons hk fields =>
                cases hs with | value hs =>
                  cases hs; cases hp; cases hps; cases hr; cases hm; cases hk
                  obtain rfl := env_eq_map he
                  have keyEq : key' = .str name := KeyR.eq_map hkey
                  subst key'
                  have same : used' = used.map PKey.str := by
                    cases hu with | node _ fields =>
                      exact string_key_fields_view used used' (by simpa only [List.map_map,Function.comp_def] using fields)
                  subst used'
                  rfl

private theorem object_start_eq (F : Ffi) (s : St F.S) (key : Key) (name : Name) (pattern : Pat)
    (patterns : List (Key × Pat)) (a : Nat) (o : Obj) (value : Val) (w e : Bool) (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s.ctl = .bind (.object ((key,pattern)::patterns) none) (.obj a) env mode kind)
    (keyResolved : keyOf key = some (.str name)) (object : s.heap.get a = some (.obj o)) (ordinary : o.kind = .ordinary)
    (descriptor : findProp (.str name) o.props = some (.data value w e)) :
    step F s = M.pure ((s.push (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))).ret value) := by
  funext β k
  simp only [step,control,bindStep,isNullish,Bool.cond_false,objPatNext,keyResolved,getV,lookup,getChain,
    St.obj?,St.push,object,ownGet,ordinary,descriptor,M.bind,M.pure,readProp]

private theorem object_next_eq (F : Ffi) (s : St F.S) (previous : Val) (key : Key) (name : Name) (pattern : Pat)
    (patterns : List (Key × Pat)) (a : Nat) (o : Obj) (value : Val) (w e : Bool) (used : List Name)
    (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame)
    (control : s.ctl = .ret previous)
    (stack : s.stack = .b (.obj (.obj a) ((key,pattern)::patterns) none (used.map PKey.str) env mode kind)::frames)
    (keyResolved : keyOf key = some (.str name)) (object : s.heap.get a = some (.obj o)) (ordinary : o.kind = .ordinary)
    (descriptor : findProp (.str name) o.props = some (.data value w e)) :
    step F s = M.pure (({s with stack := frames}.push
      (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))).ret value) := by
  funext β k
  simp only [step,control,stepRet,stack,retStep,retB,objPatNext,keyResolved,getV,lookup,getChain,
    St.obj?,St.push,object,ownGet,ordinary,descriptor,M.bind,M.pure,readProp,List.map_cons]

private theorem object_value_eq (F : Ffi) (s : St F.S) (value : Val) (a : Nat) (name : Name) (pattern : Pat)
    (patterns : List (Key × Pat)) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame)
    (control : s.ctl = .ret value)
    (stack : s.stack = .b (.objVal (.obj a) (.str name) pattern patterns none (used.map PKey.str) env mode kind)::frames) :
    step F s = M.pure (({s with stack := frames}.push
      (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))).go (.bind pattern value env mode kind)) := by
  simp only [step,control,stepRet,stack,retStep,retB]

private theorem object_done_eq (F : Ffi) (s : St F.S) (value : Val) (a : Nat) (used : List Name)
    (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame) (control : s.ctl = .ret value)
    (stack : s.stack = .b (.obj (.obj a) [] none (used.map PKey.str) env mode kind)::frames) :
    step F s = M.pure ({s with stack := frames}.ret .undef) := by
  simp only [step,control,stepRet,stack,retStep,retB,objPatNext,retS]

end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

def stringKeysNote (used : List Name) : Tree :=
  .node "List" (used.map fun name => .node "PKey.str" [.atom Name name])

theorem stringKeysNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (used : List Name) :
    (stringKeysNote used).Holds ν C R (Encode.seq ((used.map PKey.str).map Encode.key)) := by
  apply Tree.Holds.node
  induction used with
  | nil => exact .nil
  | cons name used ih => exact .cons (.node _ (.cons (.atom Name name) .nil)) ih

def objectBindingFrameNote (a : Nat) (patterns : List (Key × Pat)) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) : Tree :=
  .node "Frame.b" [.node "BindF.obj" [.value (.obj a),.atom (List (Key × Pat)) patterns,.atom (Option Pat) none,
    stringKeysNote used,environmentNote env,.atom BindMode mode,.atom DeclKind kind]]

def objectValueBindingFrameNote (a : Nat) (name : Name) (pattern : Pat) (patterns : List (Key × Pat))
    (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) : Tree :=
  .node "Frame.b" [.node "BindF.objVal" [.value (.obj a),.node "PKey.str" [.atom Name name],.atom Pat pattern,
    .atom (List (Key × Pat)) patterns,.atom (Option Pat) none,stringKeysNote used,environmentNote env,.atom BindMode mode,.atom DeclKind kind]]

theorem objectBindingFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (a : Nat)
    (patterns : List (Key × Pat)) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) :
    (objectBindingFrameNote a patterns used env mode kind).Holds ν C R
      (Encode.frame (.b (.obj (.obj (R.a a)) patterns none (used.map PKey.str) (R.env env) mode kind))) :=
  .node _ (.cons (.node _ (.cons (.value (.obj a)) (.cons (.atom (List (Key × Pat)) patterns) (.cons (.atom (Option Pat) none)
    (.cons (stringKeysNote_holds ν C R used) (.cons (environmentNote_holds ν C R env)
      (.cons (.atom BindMode mode) (.cons (.atom DeclKind kind) .nil)))))))) .nil)

theorem objectValueBindingFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (a : Nat) (name : Name)
    (pattern : Pat) (patterns : List (Key × Pat)) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) :
    (objectValueBindingFrameNote a name pattern patterns used env mode kind).Holds ν C R
      (Encode.frame (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none (used.map PKey.str) (R.env env) mode kind))) :=
  .node _ (.cons (.node _ (.cons (.value (.obj a)) (.cons (.node _ (.cons (.atom Name name) .nil)) (.cons (.atom Pat pattern)
    (.cons (.atom (List (Key × Pat)) patterns) (.cons (.atom (Option Pat) none) (.cons (stringKeysNote_holds ν C R used)
      (.cons (environmentNote_holds ν C R env) (.cons (.atom BindMode mode) (.cons (.atom DeclKind kind) .nil)))))))))) .nil)

private theorem string_keys_support (live : Nat → Prop) (used : List Name) :
    treeSupport live (Encode.seq ((used.map PKey.str).map Encode.key)) := by
  induction used with
  | nil => exact True.intro
  | cons name used ih => exact ⟨⟨True.intro,True.intro⟩,ih⟩

def RuntimeNotes.objectRead (notes : RuntimeNotes) (a : Nat) (name : Name) (pattern : Pat) (patterns : List (Key × Pat))
    (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) (role : Value) : RuntimeNotes :=
  {notes with control := returnNote role,stack := objectValueBindingFrameNote a name pattern patterns used env mode kind::notes.stack}

def RuntimeNotes.objectBind (notes : RuntimeNotes) (a : Nat) (pattern : Pat) (patterns : List (Key × Pat))
    (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind) (role : Value) : RuntimeNotes :=
  {notes with control := bindingNote pattern role env mode kind,stack := objectBindingFrameNote a patterns used env mode kind::notes.stack}

/-- The observed SSM `{q,k,v}` pattern reads initialized object-valued data
descriptors. Ownership fixes the selected object address on both sides. -/
theorem RetainedInventory.object_binding_object_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (key : Key) (name : Name) (pattern : Pat) (patterns : List (Key × Pat)) (a field : Nat) (o₀ : Obj)
    (w e : Bool) (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s₀.ctl = .bind (.object ((key,pattern)::patterns) none) (.obj a) env mode kind)
    (keyResolved : keyOf key = some (.str name)) (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data (.obj field) w e)) :
    let t₀ := (s₀.push (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))).ret (.obj field)
    let t := (s.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none [.str name] (R.env env) mode kind))).ret (.obj (R.a field))
    interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.objectRead a name pattern patterns [name] env mode kind (.obj field))) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).bind_view
  cases valueRelation
  have support := h.controlLive
  rw [control] at support
  have alive : live a := support.2.1
  obtain ⟨o,targetObject,objectRelation,objectLive⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetField,targetDescriptor,fieldRelation⟩ := objectRelation.properties.find_data name (.obj field) w e descriptor
  cases fieldRelation
  have fieldLive : live field := (PropsR.support_find objectLive.2.2.1 name descriptor).1
  have identityOwner : identity.a a = a := rfl
  have sourceFrame : (objectValueBindingFrameNote a name pattern patterns [name] env mode kind).Holds ν₀ C₀ identity
      (Encode.frame (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))) := by
    simpa only [identity_environment,identityOwner,List.map_cons,List.map_nil] using
      objectValueBindingFrameNote_holds ν₀ C₀ identity a name pattern patterns [name] env mode kind
  have targetFrame := objectValueBindingFrameNote_holds ν C R a name pattern patterns [name] env mode kind
  have frameLive : treeSupport live (Encode.frame (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))) := by
    dsimp only [Encode.frame,Encode.bindF,Encode.val,Encode.key,Encode.atom,Encode.seq,treeSupport,forestSupport,valueSupport,List.map_cons,List.map_nil]
    repeat first | exact alive | exact support.2.2.1 | constructor
  have post := (h.restack (.cons (Tree.paired sourceFrame targetFrame) h.stack) ⟨frameLive,h.stackLive⟩).go
    (c:=.ret (.obj field)) (c':=.ret (.obj (R.a field))) (.node _ (.cons (.value (.obj field)) .nil)) ⟨fieldLive,True.intro⟩
  have sourceEq := object_start_eq F s₀ key name pattern patterns a o₀ (.obj field) w e env mode kind control keyResolved object ordinary descriptor
  have targetEq := object_start_eq F s key name pattern patterns (R.a a) o (.obj (R.a field)) w e (R.env env) mode kind targetControl keyResolved targetObject
    (objectRelation.ordinary ordinary) targetDescriptor
  have sourceRun : interpC (step F s₀).run C₀ = some ((s₀.push (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))).ret (.obj field),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some ((s.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none [.str name] (R.env env) mode kind))).ret (.obj (R.a field)),C) := by rw [targetEq]; rfl
  have runtime : RuntimeInventory (notes.runtime.objectRead a name pattern patterns [name] env mode kind (.obj field)) ν₀ ν C₀ C R live
      ((s₀.push (.b (.objVal (.obj a) (.str name) pattern patterns none [.str name] env mode kind))).ret (.obj field))
      ((s.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none [.str name] (R.env env) mode kind))).ret (.obj (R.a field))) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (.obj field),.cons sourceFrame inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj field),.cons targetFrame inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- Continuing an object pattern reads the next real own data descriptor.
The selected object's meaning is its initialized owner address. -/
theorem RetainedInventory.object_binding_next_object_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (previous : Val) (key : Key) (name : Name) (pattern : Pat) (patterns : List (Key × Pat))
    (a field : Nat) (o₀ : Obj) (w e : Bool) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret previous)
    (stack : s₀.stack = .b (.obj (.obj a) ((key,pattern)::patterns) none (used.map PKey.str) env mode kind)::frames)
    (stackNotes : notes.runtime.stack = head::tail)
    (keyResolved : keyOf key = some (.str name)) (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (descriptor : findProp (.str name) o₀.props = some (.data (.obj field) w e)) :
    ∃ targetFrames,
      let t₀ := ({s₀ with stack := frames}.push (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))).ret (.obj field)
      let t := ({s with stack := targetFrames}.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none ((name::used).map PKey.str) (R.env env) mode kind))).ret (.obj (R.a field))
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.objectRead a name pattern patterns (name::used) env mode kind (.obj field))) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetPrevious,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.objectBinding_view] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have alive : live a := support.1.1.1
  have envLive : treeSupport live (Encode.env env) := support.1.1.2.2.2.2.1
  obtain ⟨o,targetObject,objectRelation,objectLive⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetField,targetDescriptor,fieldRelation⟩ := objectRelation.properties.find_data name (.obj field) w e descriptor
  cases fieldRelation
  have fieldLive : live field := (PropsR.support_find objectLive.2.2.1 name descriptor).1
  have identityOwner : identity.a a = a := rfl
  have sourceFrame : (objectValueBindingFrameNote a name pattern patterns (name::used) env mode kind).Holds ν₀ C₀ identity
      (Encode.frame (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))) := by
    simpa only [identity_environment,identityOwner] using
      objectValueBindingFrameNote_holds ν₀ C₀ identity a name pattern patterns (name::used) env mode kind
  have targetFrame := objectValueBindingFrameNote_holds ν C R a name pattern patterns (name::used) env mode kind
  have frameLive : treeSupport live (Encode.frame (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))) := by
    dsimp only [Encode.frame,Encode.bindF,Encode.val,Encode.key,Encode.atom,Encode.seq,treeSupport,forestSupport,valueSupport]
    repeat first | exact alive | exact envLive | exact string_keys_support live (name::used) | constructor
  have post := (h.restack (.cons (Tree.paired sourceFrame targetFrame) tailRelation) ⟨frameLive,support.2⟩).go
    (c:=.ret (.obj field)) (c':=.ret (.obj (R.a field))) (.node _ (.cons (.value (.obj field)) .nil)) ⟨fieldLive,True.intro⟩
  have sourceEq := object_next_eq F s₀ previous key name pattern patterns a o₀ (.obj field) w e used env mode kind frames control stack keyResolved object ordinary descriptor
  have targetEq := object_next_eq F s targetPrevious key name pattern patterns (R.a a) o (.obj (R.a field)) w e used (R.env env) mode kind targetFrames targetControl targetStack keyResolved targetObject
    (objectRelation.ordinary ordinary) targetDescriptor
  have sourceRun : interpC (step F s₀).run C₀ = some (({s₀ with stack := frames}.push (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))).ret (.obj field),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some (({s with stack := targetFrames}.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none ((name::used).map PKey.str) (R.env env) mode kind))).ret (.obj (R.a field)),C) := by rw [targetEq]; rfl
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory ({notes.runtime with stack := tail}.objectRead a name pattern patterns (name::used) env mode kind (.obj field)) ν₀ ν C₀ C R live
      (({s₀ with stack := frames}.push (.b (.objVal (.obj a) (.str name) pattern patterns none ((name::used).map PKey.str) env mode kind))).ret (.obj field))
      (({s with stack := targetFrames}.push (.b (.objVal (.obj (R.a a)) (.str name) pattern patterns none ((name::used).map PKey.str) (R.env env) mode kind))).ret (.obj (R.a field))) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds (.obj field),.cons sourceFrame sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj field),.cons targetFrame targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- A selected field retains its current return meaning while the original
object-pattern continuation schedules the nested binding. -/
theorem RetainedInventory.object_binding_value_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (a : Nat) (name : Name) (pattern : Pat) (patterns : List (Key × Pat)) (used : List Name)
    (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .b (.objVal (.obj a) (.str name) pattern patterns none (used.map PKey.str) env mode kind)::frames)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetValue targetFrames,
      let t₀ := ({s₀ with stack := frames}.push (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))).go (.bind pattern value env mode kind)
      let t := ({s with stack := targetFrames}.push (.b (.obj (.obj (R.a a)) patterns none (used.map PKey.str) (R.env env) mode kind))).go (.bind pattern targetValue (R.env env) mode kind)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.objectBind a pattern patterns used env mode kind role)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.objectValueBinding_view] at targetStack
  have sourceControl := inventory.runtime.source.control
  have targetControlRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceNew : (bindingNote pattern role env mode kind).Holds ν₀ C₀ identity (Encode.ctl (.bind pattern value env mode kind)) := by
    simpa only [identity_environment] using bindingNote_holds pattern env mode kind sourceRole
  have targetNew := bindingNote_holds pattern env mode kind targetRole
  have identityOwner : identity.a a = a := rfl
  have sourceFrame : (objectBindingFrameNote a patterns used env mode kind).Holds ν₀ C₀ identity
      (Encode.frame (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))) := by
    simpa only [identity_environment,identityOwner] using objectBindingFrameNote_holds ν₀ C₀ identity a patterns used env mode kind
  have targetFrame := objectBindingFrameNote_holds ν C R a patterns used env mode kind
  have support := h.stackLive
  rw [stack] at support
  have alive : live a := support.1.1.1
  have envLive : treeSupport live (Encode.env env) := support.1.1.2.2.2.2.2.2.1
  have frameLive : treeSupport live (Encode.frame (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))) := by
    dsimp only [Encode.frame,Encode.bindF,Encode.val,Encode.atom,Encode.seq,treeSupport,forestSupport,valueSupport]
    repeat first | exact alive | exact envLive | exact string_keys_support live used | constructor
  have valueLive := (h.return_values value targetValue control targetControl).2
  have post := (h.restack (.cons (Tree.paired sourceFrame targetFrame) tailRelation) ⟨frameLive,support.2⟩).go
    (c:=.bind pattern value env mode kind) (c':=.bind pattern targetValue (R.env env) mode kind)
    (Tree.paired sourceNew targetNew) ⟨True.intro,valueLive,envLive,True.intro,True.intro,True.intro⟩
  have sourceEq := object_value_eq F s₀ value a name pattern patterns used env mode kind frames control stack
  have targetEq := object_value_eq F s targetValue (R.a a) name pattern patterns used (R.env env) mode kind targetFrames targetControl targetStack
  have sourceRun : interpC (step F s₀).run C₀ = some (({s₀ with stack := frames}.push (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))).go (.bind pattern value env mode kind),C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some (({s with stack := targetFrames}.push (.b (.obj (.obj (R.a a)) patterns none (used.map PKey.str) (R.env env) mode kind))).go (.bind pattern targetValue (R.env env) mode kind),C) := by rw [targetEq]; rfl
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory ({notes.runtime with stack := tail}.objectBind a pattern patterns used env mode kind role) ν₀ ν C₀ C R live
      (({s₀ with stack := frames}.push (.b (.obj (.obj a) patterns none (used.map PKey.str) env mode kind))).go (.bind pattern value env mode kind))
      (({s with stack := targetFrames}.push (.b (.obj (.obj (R.a a)) patterns none (used.map PKey.str) (R.env env) mode kind))).go (.bind pattern targetValue (R.env env) mode kind)) :=
    ⟨inventory.runtime.keyLive,⟨sourceNew,.cons sourceFrame sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨targetNew,.cons targetFrame targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetValue,targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- Exhausting an object pattern removes only its saved continuation. -/
theorem RetainedInventory.object_binding_done_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (a : Nat) (used : List Name) (env : Env) (mode : BindMode) (kind : DeclKind)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .b (.obj (.obj a) [] none (used.map PKey.str) env mode kind)::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with stack := frames}.ret .undef
      let t := {s with stack := targetFrames}.ret .undef
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote .undef,stack := tail}) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.objectBinding_view] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have post := (h.restack tailRelation support.2).go (c:=.ret .undef) (c':=.ret .undef)
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
  have sourceEq := object_done_eq F s₀ value a used env mode kind frames control stack
  have targetEq := object_done_eq F s targetValue (R.a a) used (R.env env) mode kind targetFrames targetControl targetStack
  have sourceRun : interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret .undef,C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some ({s with stack := targetFrames}.ret .undef,C) := by rw [targetEq]; rfl
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory {notes.runtime with control := returnNote .undef,stack := tail} ν₀ ν C₀ C R live
      ({s₀ with stack := frames}.ret .undef) ({s with stack := targetFrames}.ret .undef) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds .undef,sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds .undef,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
