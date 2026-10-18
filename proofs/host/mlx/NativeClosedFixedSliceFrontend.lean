import host.mlx.NativeFixedSliceFrontend
import host.mlx.NativeClosedProducer
import host.mlx.NativeClosedShapeBuffer

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command
open Parametric.Driver

private def closedSliceHeader : String := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated in\n"

/-- The fixed slice consumes reached closed expression notes. Only source
metadata and bytes determine their normalized meanings; both physical states
remain unchanged until the original one-step native call. -/
elab "host_retained_closedFixedSlice " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let some ff := f.raw.reprint | throwError "closed fixed slice: cannot print FFI"
  let some ss := s.raw.reprint | throwError "closed fixed slice: cannot print input"
  let some tt := t.raw.reprint | throwError "closed fixed slice: cannot print output"
  let some ii := initial.raw.reprint | throwError "closed fixed slice: cannot print initial server"
  let some nn := next.raw.reprint | throwError "closed fixed slice: cannot print next server"
  let errorsBefore := ((← get).messages.toList.filter (·.severity == .error)).length
  Parametric.Driver.emit s!"host_retained_fixedSlice {ff}, {ss} using {ii} to {tt} using {nn} as {name.getId}.Normalized"
  let errorsAfter := ((← get).messages.toList.filter (·.severity == .error)).length
  if errorsBefore < errorsAfter then throwAbortCommand
  let n := "_root_." ++ pre.toString
  let b := n ++ ".Normalized"
  Parametric.Driver.emit (closedSliceHeader ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {b}.F.S) (inst : Inst ν₀ {b}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {b}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {b}.input s)
      (signatureFrame : ¬ framed {b}.types) (handleLive : H {b}.handle)
      (closedShape : closedLiteralShape (roles {b}.producer).shape = true)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
      (fnRole thisRole startCount stopCount strideCount : Annotated.Value)
      (startSchema : FixedIntegerRole startCount (Int.ofNat {b}.rank)) (stopSchema : FixedIntegerRole stopCount (Int.ofNat {b}.rank))
      (strideSchema : FixedIntegerRole strideCount (Int.ofNat {b}.rank))
      (note : notes.runtime.control = callNote fnRole thisRole
        (Host.Load.Run.Full.Ordinary.SliceFamilyHost.literalSliceArgumentNotes {b}.out {b}.handle {b}.start {b}.stop {b}.stride {b}.stream startCount stopCount strideCount))
      (selected : notes.buffers.owners {b}.out = some (handleSlotNotes 0))
      (startExpressions stopExpressions strideExpressions : List SymE)
      (selectedStart : notes.buffers.owners {b}.start = some (literalShapeByteNotes startExpressions))
      (selectedStop : notes.buffers.owners {b}.stop = some (literalShapeByteNotes stopExpressions))
      (selectedStride : notes.buffers.owners {b}.stride = some (literalShapeByteNotes strideExpressions))
      (closedStart : startExpressions.all SymE.closed = true) (closedStop : stopExpressions.all SymE.closed = true)
      (closedStride : strideExpressions.all SymE.closed = true) :
      let normalizedRoles := nodeShapeRoles roles {b}.producer {b}.inputSizes
      let normalizedNotes := ((notes.normalizeShapeBuffer {b}.start {b}.first).normalizeShapeBuffer {b}.stop {b}.last).normalizeShapeBuffer {b}.stride (List.replicate {b}.inputSizes.length 1)
      let newRoles := sliceOutputRoles {b}.kind normalizedRoles {b}.input.ffi.mlx.nnext {b}.producer
        (constantShape {b}.first) (constantShape {b}.last) (constantShape (List.replicate {b}.inputSizes.length 1)) (constantShape (sliceExtents {b}.first {b}.last))
      let newObjects := objectWrite objects {b}.input.ffi.mlx.next .stream
      let newH := fun a => a = {b}.input.ffi.mlx.next ∨ H a
      let newN := {b}.kind.support {b}.input.ffi.mlx.nnext N
      ∃ result, interpC (step {b}.F {b}.input).run C₀ = some ({b}.output,C₀) ∧
        interpC (step {b}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C)
          (Host.Load.Run.Full.Ordinary.VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects newH newN tail host)
          R live framed before after old old' {b}.output result ∧
        RetainedInventory (normalizedNotes.nativeHandleResult {b}.out {b}.input.ffi.mlx.next) ν₀ ν C₀ C R live {b}.output result ∧
        ProducerAnnotations roots newH newN newRoles newObjects ∧
        ProducerSupport roots newH newN {b}.output.ffi.mlx ∧ Inst ν₀ {b}.nextServer C₀ := by
      let normalizedRoles := nodeShapeRoles roles {b}.producer {b}.inputSizes
      have supported := h.native.2.nodesOf_support [{b}.handle] [{b}.producer] ⟨handleLive,True.intro⟩ {b}.source_producers
      obtain ⟨normalizedState,_,normalizedPolicy,_⟩ := Host.Load.Run.Full.Ordinary.VectorHost.normalize_closed_producer
        h inventory {b}.producer {b}.node {b}.inputSizes supported.1 {b}.source_node {b}.source_input_shape closedShape roots policy
      let notes1 := notes.normalizeShapeBuffer {b}.start {b}.first
      let notes2 := notes1.normalizeShapeBuffer {b}.stop {b}.last
      let notes3 := notes2.normalizeShapeBuffer {b}.stride (List.replicate {b}.inputSizes.length 1)
      have inv1 := inventory.normalize_closed_shape_buffer {b}.start startExpressions {b}.first selectedStart
        {b}.startObject {b}.source_start {b}.start_kind {b}.start_exact closedStart
      have stop1 : notes1.buffers.owners {b}.stop = some (literalShapeByteNotes stopExpressions) := by
        simpa only [notes1,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_eq_right {b}.stop_ne_start] using selectedStop
      have inv2 := inv1.normalize_closed_shape_buffer {b}.stop stopExpressions {b}.last stop1
        {b}.stopObject {b}.source_stop {b}.stop_kind {b}.stop_exact closedStop
      have stride2 : notes2.buffers.owners {b}.stride = some (literalShapeByteNotes strideExpressions) := by
        simpa only [notes2,notes1,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,
          ite_eq_right {b}.stride_ne_stop,ite_eq_right {b}.stride_ne_start] using selectedStride
      have inv3 := inv2.normalize_closed_shape_buffer {b}.stride strideExpressions (List.replicate {b}.inputSizes.length 1) stride2
        {b}.strideObject {b}.source_stride {b}.stride_kind (ExactDimensions.ones _) closedStride
      have shapeSchema : (normalizedRoles {b}.producer).shape = constantShape {b}.inputSizes := by
        simp only [normalizedRoles,nodeShapeRoles,nodeWrite,ite_true]
      have out3 : notes3.buffers.owners {b}.out = some (handleSlotNotes 0) := by
        simpa only [notes3,notes2,notes1,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,
          ite_eq_right {b}.out_ne_stride,ite_eq_right {b}.out_ne_stop,ite_eq_right {b}.out_ne_start] using selected
      have start3 : notes3.buffers.owners {b}.start = some (literalShapeByteNotes (constantExpressions {b}.first)) := by
        simp only [notes3,notes2,notes1,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,
          ite_eq_right (Ne.symm {b}.stride_ne_start),ite_eq_right (Ne.symm {b}.stop_ne_start),ite_true]
      have stop3 : notes3.buffers.owners {b}.stop = some (literalShapeByteNotes (constantExpressions {b}.last)) := by
        simp only [notes3,notes2,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,
          ite_eq_right (Ne.symm {b}.stride_ne_stop),ite_true]
      have stride3 : notes3.buffers.owners {b}.stride = some (literalShapeByteNotes (constantExpressions (List.replicate {b}.inputSizes.length 1))) := by
        simp only [notes3,RetainedNotes.normalizeShapeBuffer,BufferNotes.write,ite_true]
      exact {b}.retained_transport notes3 ν₀ ν C₀ C R normalizedRoles boundary objects H N tail host live framed before after old old'
        s inst normalizedState inv3 signatureFrame handleLive shapeSchema targetNodes targetHandles targetHeap roots normalizedPolicy
        fnRole thisRole startCount stopCount strideCount startSchema stopSchema strideSchema note out3 start3 stop3 stride3")

end Host.Ts.Owned.Annotated.Driver
