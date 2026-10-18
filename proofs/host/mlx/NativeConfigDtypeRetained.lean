import host.mlx.NativeConfigDtypeHost
import host.mlx.NativeConfigIntRetained

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.ConfigDtypeInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open ConfigDtypeHost

/-- A dtype declaration uses the current handle, C-string and fixed dtype
argument notes. The original decoder preserves the current numeric servers,
all host inventories and the updated configuration's producer policy. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (fn types handle buffer dtype : Nat) (value : F64) (function signatureObject bufferObject : Host.Ts.Obj)
    (returns : Name) (receiver : Val) (bytes₀ : List Host.Ts.Byte) (name : Name)
    (control : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle),.ptr (.js buffer) 0,.num (.lit value)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array signature)
    (bufferRead : s₀.heap.get buffer = some (.obj bufferObject)) (bufferKind : bufferObject.kind = .buf bytes₀)
    (sourceName : cstrArg (.jsPtr buffer 0 bytes₀) = some name)
    (same : F64.un .int32 value = value) (sourceDtype : argNat (.num (.lit value)) = some dtype)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (configRole : Config) (sourceConfig : Cfg) (objectRole : objects handle = .config configRole)
    (configRead : s₀.ffi.mlx.obj? handle = some (.cfg sourceConfig))
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle handle,.ptr (.js buffer) 0,.literal (.lit value)])
    (sourceBound : handle < 2^64) (targetBound : R.handle handle < 2^64) :
    let updated := objectWrite objects handle (.config {configRole with dtypes := configRole.dtypes ++ [(name,dtype)]})
    ∃ bytes target,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishDtype s₀ handle buffer dtype sourceConfig name bytes₀ value,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishDtype s (R.handle handle) (R.a buffer) dtype target name bytes value,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
        R live framed before after old old' (finishDtype s₀ handle buffer dtype sourceConfig name bytes₀ value)
        (finishDtype s (R.handle handle) (R.a buffer) dtype target name bytes value) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}) ν₀ ν C₀ C R live
        (finishDtype s₀ handle buffer dtype sourceConfig name bytes₀ value)
        (finishDtype s (R.handle handle) (R.a buffer) dtype target name bytes value) ∧
      ProducerAnnotations roots H N nodes updated := by
  dsimp only
  let arguments : List Annotated.Value := [.handle handle,.ptr (.js buffer) 0,.literal (.lit value)]
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 0 (.handle handle) rfl).2
  have dtypeRole := (inventory.runtime.call_argument_role fnRole thisRole arguments (.obj fn) receiver _
    control controlNote 2 (.literal (.lit value)) rfl).2
  obtain ⟨bytes,target,left,right,post⟩ := ConfigDtypeHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s₀ s h fn types handle buffer dtype value function signatureObject bufferObject returns receiver
    bytes₀ name control functionRead functionKind signatureRead signatureKind bufferRead bufferKind sourceName same sourceDtype
    signatureFrame handleLive configRole sourceConfig objectRole configRead handleRole dtypeRole sourceBound targetBound
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishDtype s₀ handle buffer dtype sourceConfig name bytes₀ value)
      (finishDtype s (R.handle handle) (R.a buffer) dtype target name bytes value) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨bytes,target,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C),
    policy.config_write handle {configRole with dtypes := configRole.dtypes ++ [(name,dtype)]}⟩

end Host.Load.Run.Full.Ordinary.ConfigDtypeInventory
