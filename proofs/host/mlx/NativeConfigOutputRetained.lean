import host.mlx.NativeConfigOutputHost
import host.mlx.NativeConfigIntRetained
import host.mlx.NativeShapeBufferInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigOutputInventory
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open ConfigOutputHost

/-- Output configuration dimensions follow the current coherent shape-byte
annotations. Pure exact-integer meanings determine both decoded shapes; no
target shape or target decoder result is an entry premise. -/
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
    (fn types handle buffer dtype : Nat) (dtypeValue : F64)
    (function signatureObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (expressions : List SymE) (integers₀ integers : List Int)
    (sourceDimensions : LiteralDimensions ν₀ (expressions.map Dimension.literal) integers₀)
    (targetDimensions : LiteralDimensions ν (expressions.map Dimension.literal) integers)
    (control : s₀.ctl = .call (.obj fn) receiver
      [.big (Int.ofNat handle),.ptr (.js buffer) 0,.big (Int.ofNat expressions.length),.num (.lit dtypeValue)])
    (functionRead : s₀.heap.get fn = some (.obj function))
    (functionKind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array signature)
    (sameDtype : F64.un .int32 dtypeValue = dtypeValue)
    (sourceDtype : argNat (.num (.lit dtypeValue)) = some dtype)
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (configRole : Config) (sourceConfig : Cfg) (objectRole : objects handle = .config configRole)
    (configRead : s₀.ffi.mlx.obj? handle = some (.cfg sourceConfig))
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle handle,.ptr (.js buffer) 0,.ordinaryBig (Int.ofNat expressions.length),.literal (.lit dtypeValue)])
    (selected : notes.buffers.owners buffer = some (literalShapeByteNotes expressions))
    (sourceBound : handle < 2^64) (targetBound : R.handle handle < 2^64) :
    let updated := objectWrite objects handle (.config {configRole with outs := configRole.outs ++ [(expressions.map Dimension.literal,dtype)]})
    ∃ bytes targetShape target,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishOutput s₀ handle buffer expressions.length dtype sourceConfig (shapeBytes (integers₀.map Dim.lit)) (integers₀.map Dim.lit) dtypeValue,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some
        (finishOutput s (R.handle handle) (R.a buffer) expressions.length dtype target bytes targetShape dtypeValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary updated H N tail host)
        R live framed before after old old'
        (finishOutput s₀ handle buffer expressions.length dtype sourceConfig (shapeBytes (integers₀.map Dim.lit)) (integers₀.map Dim.lit) dtypeValue)
        (finishOutput s (R.handle handle) (R.a buffer) expressions.length dtype target bytes targetShape dtypeValue) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote nativeStatusRole}) ν₀ ν C₀ C R live
        (finishOutput s₀ handle buffer expressions.length dtype sourceConfig (shapeBytes (integers₀.map Dim.lit)) (integers₀.map Dim.lit) dtypeValue)
        (finishOutput s (R.handle handle) (R.a buffer) expressions.length dtype target bytes targetShape dtypeValue) ∧
      ProducerAnnotations roots H N nodes updated := by
  dsimp only
  obtain ⟨sourceBuffer,targetBuffer,bytes₀,bytes,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.buffers.selected buffer (literalShapeByteNotes expressions) selected
  have sourceBytes := literal_shape_bytes_exact expressions integers₀ bytes₀ sourceDimensions sourceRoles
  rw [sourceBytes] at sourceKind
  have targetShape := (inventory.buffers.target buffer (literalShapeByteNotes expressions) selected).literal_shape expressions integers targetDimensions
  let argumentRoles : List Annotated.Value := [.handle handle,.ptr (.js buffer) 0,.ordinaryBig (Int.ofNat expressions.length),.literal (.lit dtypeValue)]
  have handleRole := (inventory.runtime.call_argument_role fnRole thisRole argumentRoles (.obj fn) receiver _
    control controlNote 0 (.handle handle) rfl).2
  have countRole := (inventory.runtime.call_argument_role fnRole thisRole argumentRoles (.obj fn) receiver _
    control controlNote 2 (.ordinaryBig (Int.ofNat expressions.length)) rfl).2
  have dtypeRole := (inventory.runtime.call_argument_role fnRole thisRole argumentRoles (.obj fn) receiver _
    control controlNote 3 (.literal (.lit dtypeValue)) rfl).2
  obtain ⟨bytes,targetShape,target,left,right,post⟩ := ConfigOutputHost.from_source ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s₀ s h fn types handle buffer dtype dtypeValue function signatureObject sourceBuffer returns receiver
    (expressions.map Dimension.literal) (integers₀.map Dim.lit) (literal_shape_decodable expressions)
    (by simpa only [List.length_map] using control) functionRead functionKind signatureRead signatureKind sourceRead sourceKind (sourceDimensions.holds C₀)
    sameDtype sourceDtype signatureFrame handleLive configRole sourceConfig objectRole configRead handleRole
    (by simpa only [List.length_map] using countRole) dtypeRole
    targetShape sourceBound targetBound
  simp only [List.length_map] at left right post
  have runtime : RuntimeInventory {notes.runtime with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishOutput s₀ handle buffer expressions.length dtype sourceConfig (shapeBytes (integers₀.map Dim.lit)) (integers₀.map Dim.lit) dtypeValue)
      (finishOutput s (R.handle handle) (R.a buffer) expressions.length dtype target bytes targetShape dtypeValue) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨bytes,targetShape,target,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C),
    policy.config_write handle {configRole with outs := configRole.outs ++ [(expressions.map Dimension.literal,dtype)]}⟩

end Host.Load.Run.Full.Ordinary.ConfigOutputInventory
