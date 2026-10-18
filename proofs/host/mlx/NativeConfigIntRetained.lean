import host.mlx.NativeConfigIntHost
import host.mlx.NativeAnnotationSupport
import host.mlx.NativeBufferInventory
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- The host occurrence determines the native numeric annotation before the
ABI cast. A general numeric occurrence does not assert a reference layout. -/
inductive ConfigIntegerArgument : Owned.Annotated.Value → Number → Prop where
  | numeric (meaning : SymE) : ConfigIntegerArgument (.num meaning) (.any meaning)
  | literal (meaning : SymE) : ConfigIntegerArgument (.literal meaning) (.literal meaning)

theorem ConfigIntegerArgument.number {ν : Nat → F64} {C : CSrv} {R : Ren}
    {role : Owned.Annotated.Value} {number : Number} {value : NumV}
    (schema : ConfigIntegerArgument role number) (held : role.Holds ν C R (.num value)) :
    number.Holds ν C value := by
  cases schema <;> cases held
  · exact .any _ _ (by assumption)
  · exact .literal _ _ (by assumption)

theorem ConfigIntegerArgument.value {ν : Nat → F64} {C : CSrv} {R : Ren}
    {role : Owned.Annotated.Value} {number : Number} {value : Val}
    (schema : ConfigIntegerArgument role number) (held : role.Holds ν C R value) :
    number.ValueHolds ν C value := by
  cases schema <;> cases held
  · exact ⟨_,rfl,.any _ _ (by assumption)⟩
  · exact ⟨_,rfl,.literal _ _ (by assumption)⟩

/-- Configuration fields contain no producer references. Updating only their
fixed annotation preserves the existing graph and object dependency policy. -/
theorem ProducerAnnotations.config_write {roots H N : Nat → Prop}
    {nodes : Nat → GraphNode} {objects : Nat → Object}
    (policy : ProducerAnnotations roots H N nodes objects) (handle : Nat) (config : Config) :
    ProducerAnnotations roots H N nodes (objectWrite objects handle (.config config)) := by
  constructor
  · intro i held
    by_cases same : i = handle
    · subst i; simp only [objectWrite,ite_true,Object.Supported]
    · simpa only [objectWrite,ite_eq_right same] using policy.objects i held
  · exact policy.roots
  · exact policy.nodes

end Host.Mlx.Ffi.Annotated

namespace Host.Load.Run.Full.Ordinary.ConfigIntInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open ConfigIntHost

/-- The actual configuration setter consumes the current handle, pointer and
numeric occurrence notes, performs the original i32 cast and appends that
fixed decoded meaning to the configuration. All six host inventories and the
strong indexed native relation survive; producer closure follows from the
updated policy. Independent numeric-table extensions are retained. -/
theorem retained_int_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (fn types handle buffer : Nat) (value₀ : NumV) (function signatureObject bufferObject : Host.Ts.Obj)
    (returns : Name) (receiver : Val) (bytes₀ : List Host.Ts.Byte) (name : Name)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle),.ptr (.js buffer) 0,.num value₀])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str ConfigIntHost.symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array ConfigIntHost.signature)
    (bufferRead : s₀.heap.get buffer = some (.obj bufferObject)) (bufferKind : bufferObject.kind = .buf bytes₀)
    (sourceName : cstrArg (.jsPtr buffer 0 bytes₀) = some name)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (configRole : Config) (sourceConfig : Cfg)
    (objectRole : objects handle = .config configRole)
    (configRead : s₀.ffi.mlx.obj? handle = some (.cfg sourceConfig))
    (valueRole fnRole thisRole : Annotated.Value) (numberRole : Number)
    (numeric : ConfigIntegerArgument valueRole numberRole)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle handle,.ptr (.js buffer) 0,valueRole])
    (sourceBound : handle < 2^64) (targetBound : R.handle handle < 2^64) :
    let updated := objectWrite objects handle (.config {configRole with ints := configRole.ints ++ [(name,numberRole.decoded .i32)]})
    ∃ value₀' value' bytes target D₀ D,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishInt s₀ handle buffer sourceConfig name bytes₀ value₀',D₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishInt s (R.handle handle) (R.a buffer) target name bytes value',D) ∧
      Parametric.StateR (NumberRoles ν₀ ν D₀ D)
        (VectorHost.NativeRelation ν₀ ν D₀ D nodes boundary updated H N tail host)
        R live framed before after old old'
        (finishInt s₀ handle buffer sourceConfig name bytes₀ value₀')
        (finishInt s (R.handle handle) (R.a buffer) target name bytes value') ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}) ν₀ ν D₀ D R live
        (finishInt s₀ handle buffer sourceConfig name bytes₀ value₀')
        (finishInt s (R.handle handle) (R.a buffer) target name bytes value') ∧
      ProducerAnnotations roots H N nodes updated ∧
      ProducerSupport roots H N (finishInt s₀ handle buffer sourceConfig name bytes₀ value₀').ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i)) (resourceImage R.handle H) (resourceImage R.node N)
        (finishInt s (R.handle handle) (R.a buffer) target name bytes value').ffi.mlx ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  dsimp only
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole
    [.handle handle,.ptr (.js buffer) 0,valueRole] (.obj fn) receiver _ control controlNote 0 (.handle handle) rfl).2
  obtain ⟨sourceValue,targetValue⟩ := inventory.runtime.call_argument_role fnRole thisRole
    [.handle handle,.ptr (.js buffer) 0,valueRole] (.obj fn) receiver _ control controlNote 2 valueRole rfl
  have sourceNumber : numberRole.Holds ν₀ C₀ value₀ := numeric.number
    (by simpa only [control,callArgument,Host.Ts.arg,nthD] using sourceValue)
  obtain ⟨value₀',value',bytes,target,D₀,D,left,right,post,sourceExtension,targetExtension⟩ := ConfigIntHost.from_source
    ν₀ ν C₀ C R nodes boundary objects H N tail host live framed before after old old' s₀ s h
    fn types handle buffer value₀ function signatureObject bufferObject returns receiver bytes₀ name
    control functionRead functionKind signatureRead signatureKind bufferRead bufferKind sourceName signatureFrame handleLive
    configRole sourceConfig objectRole configRead numberRole sourceNumber handleRole (numeric.value targetValue) sourceBound targetBound
  have current := inventory.runtime.mono sourceExtension targetExtension
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν D₀ D R live
      (finishInt s₀ handle buffer sourceConfig name bytes₀ value₀')
      (finishInt s (R.handle handle) (R.a buffer) target name bytes value') :=
    ⟨current.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ D₀ identity),current.source.stack,current.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν D R),current.target.stack,current.target.cells⟩⟩
  have retained := inventory.heap_step runtime rfl rfl sourceExtension targetExtension
  have updatedPolicy := policy.config_write handle {configRole with ints := configRole.ints ++ [(name,numberRole.decoded .i32)]}
  exact ⟨value₀',value',bytes,target,D₀,D,left,right,post,retained,updatedPolicy,
    updatedPolicy.source post.native.2,updatedPolicy.target post.native.2,sourceExtension,targetExtension⟩

end Host.Load.Run.Full.Ordinary.ConfigIntInventory
