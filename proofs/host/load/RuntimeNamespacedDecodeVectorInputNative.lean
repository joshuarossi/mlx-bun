import host.mlx.OrdinaryVectorInputHost
import host.mlx.NativeVectorDataRetained
import host.load.RuntimeNamespacedDecodePlan1770

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.Vector2336
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def input := VectorInputCall.input
noncomputable def output := VectorInputCall.output
noncomputable def initialServer := numberServer
  (P.RestStream.micro0.micro23.S36.substitute LoopVariables.oracleVariables)
noncomputable def nextServer := numberServer
  (P.RestStream.micro0.micro23.S37.substitute LoopVariables.oracleVariables)

theorem source_step : interpS (step P.F input).run initialServer = some (output,nextServer) := by host_kernel_rfl
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual compiled-input vector consumes the three current handle-byte
annotations. Its target execution and fresh vector follow from those notes
and current native ownership, with no post-execution buffer premise. -/
theorem retained_transport (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (signatureFrame : ¬ framed 4411)
    (owned : listSupport H [29375,40,41]) (targetBound : s.ffi.mlx.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countRole : Value) (countSchema : FixedIntegerRole countRole (Int.ofNat 3))
    (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js 3126910) 0,countRole])
    (selected : notes.buffers.owners 3126910 = some (handleArrayBytes [29375,40,41])) :
    ∃ result, interpC (step P.F input).run C₀ = some (output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
          (objectWrite objects 29376 (.vec [22590,10,11]))
          (fun a => a = 29376 ∨ H a) N tail host)
        R live framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.handle 29376),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live output result ∧
      Inst ν₀ nextServer C₀ ∧
      ProducerAnnotations roots (fun a => a = 29376 ∨ H a) N roles
        (objectWrite objects 29376 (.vec [22590,10,11])) ∧
      ProducerSupport roots (fun a => a = 29376 ∨ H a) N output.ffi.mlx := by
  have kind := VectorInputCall.source_kind
  rw [VectorInputCall.source_caps] at kind
  obtain ⟨left,right,post,retained,newPolicy,support⟩ := VectorDataHost.retained_from_source
    ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old'
    input s h inventory 4709 4411 3126910 VectorInputCall.calleeObject
    VectorInputCall.signatureObject VectorInputCall.returns (.obj 4817) [29375,40,41] [22590,10,11]
    VectorInputCall.source_control VectorInputCall.source_callee kind
    VectorInputCall.source_signature VectorInputCall.source_signature_kind signatureFrame owned
    VectorInputCall.source_nodes (by change VectorInputCall.input.ffi.mlx.next < 2^64; rw [VectorInputCall.source_counter]; decide +kernel)
    targetBound roots policy fnRole thisRole countRole countSchema note selected
  have counter : input.ffi.mlx.next = 29376 := VectorInputCall.source_counter
  rw [counter] at left post retained newPolicy support
  have endpoint : finishBig input (VectorDataHost.resultWorld input.ffi [22590,10,11])
      chars!"mlx_vector_array_new_data" [.jsPtr 3126910 0 (VectorBuffer.bytes [29375,40,41]),
        .big (Int.ofNat 3)] (Int.ofNat 29376) = output := by
    host_kernel_rfl
  simp only [List.length_cons,List.length_nil] at left post retained support
  rw [endpoint] at left post retained support
  exact ⟨_,left,right,post,retained,pure_step_inst P.F ν₀ initialServer nextServer C₀
    input output inst source_step (source_run C₀),newPolicy,support⟩

host_retained_theorem entry := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (signatureFrame : ¬ framed 4411)
    (owned : listSupport H [29375,40,41]) (targetBound : s.ffi.mlx.next < 2^64)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countRole : Value) (countSchema : FixedIntegerRole countRole (Int.ofNat 3))
    (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js 3126910) 0,countRole])
    (selected : notes.buffers.owners 3126910 = some (handleArrayBytes [29375,40,41])) => by
  host_retained_chain P.F, [retained_transport] using h, inventory, inst
host_assert_retained_schema entry, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema entry, 2

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_vector : Host.Mlx.Ffi.nodesOf input.ffi.mlx [29375,40,41] = some [22590,11,10] := by host_kernel_rfl",
      "theorem wrong_endpoint : output.ctl = .ret (.big (Int.ofNat 29377)) := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "compiled input negative did not reach its intended kernel rejection: {claim}"
end Host.Load.Run.Full.Ordinary.NamespacedDecode.Vector2336
