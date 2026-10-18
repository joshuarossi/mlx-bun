import host.mlx.OrdinaryShapelessPlan
import host.mlx.OrdinaryShapelessCut
import host.mlx.NativeCachedRetained
import host.mlx.ReplayFrame
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro36 86 4782 as Ordinary.ShapelessHost.functionObject
host_transport_object P.RestStream.micro0.micro36 86 4557 as Ordinary.ShapelessHost.signatureObject
host_transport_object P.RestStream.micro0.micro36 86 3127055 as Ordinary.ShapelessHost.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ShapelessHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F := CachedFamilyHost.F
noncomputable def input : Host.Ts.St LSt := P.RestStream.micro0.micro36.s86
noncomputable def output : Host.Ts.St LSt := P.RestStream.micro0.micro36.s87
noncomputable def initialServer := numberServer P.RestStream.micro0.micro36.S86
noncomputable def nextServer := numberServer P.RestStream.micro0.micro36.S87
noncomputable def payload : Arg := match ShapelessCall.source.obj? 18194 with
  | some (.clo (.compiled _ payload _ _)) => payload
  | _ => .null

theorem source_control : input.ctl = .call (.obj 4782) (.obj 4817)
    [.ptr (.js 3127055) 0,.big (Int.ofNat 18194),.big (Int.ofNat 29382)] := by host_kernel_rfl
theorem source_function : input.heap.get 4782 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .symbol)
    [.str CachedFamilyHost.symbol,.obj 4557,.str chars!"i32"]) := by host_kernel_rfl
theorem source_signature : input.heap.get 4557 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array CachedFamilyHost.signature := by host_kernel_rfl
theorem source_buffer : input.heap.get 3127055 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 29383)) 8 0) := by host_kernel_rfl
theorem source_closure : ShapelessCall.source.obj? 18194 =
    some (.clo (.compiled 281474976715599 payload true [ShapelessCall.trace])) := by host_kernel_rfl
theorem source_vector : ShapelessCall.source.obj? 29382 = some (.vec ShapelessCall.inputs) := by host_kernel_rfl
theorem source_output : ShapelessCall.source.obj? 29383 = some (.vec []) := by host_kernel_rfl

def metadata : List (List Dim × Nat) := literalMetadata [([48],12),([1,1,48],12),([48],12)]
theorem source_captured_meta : shapesOf ShapelessCall.source ShapelessCall.trace.ins = some metadata := by host_kernel_rfl
theorem source_input_meta : shapesOf ShapelessCall.source ShapelessCall.inputs = some metadata := by host_kernel_rfl

theorem source_native_step : step F input = M.pure output := by host_kernel_rfl

theorem source_run (C : CSrv) : interpC (step F input).run C = some (output,C) := by
  rw [source_native_step]
  rfl

theorem source_step : interpS (step F input).run initialServer = some (output,nextServer) := by
  rw [source_native_step]
  host_kernel_rfl

/-- The real ordinary call3686 uses an existing vector slot. Its checked
source plan and shapeless matching are derived here from current producer
annotations. All six inventories, strong native annotations, producer policy
and the concrete number-server instantiation survive the original host step. -/
theorem retained_transport (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (leading : Shape) (objects : Nat → Object) (H frame roots : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (inst : Inst ν₀ initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C (ShapelessCall.roles base leading) ShapelessCall.boundary objects H
        (fun i => ShapelessCall.N0 i ∨ frame i) tail host) R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (policy : ProducerAnnotations roots H (fun i => ShapelessCall.N0 i ∨ frame i) (ShapelessCall.roles base leading) objects)
    (signatureFrame : ¬ framed 4557) (closureLive : H 18194) (vectorLive : H 29382) (outputLive : H 29383)
    (targetNodes : s.ffi.mlx.nnext + ShapelessCall.trace.order.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((CachedFamilyHost.arguments 3127055 18194 29382).map FixedArgument.role))
    (selected : notes.buffers.owners 3127055 = some (handleSlotNotes 29383)) :
    ∃ t, interpC (step F input).run C₀ = some (output,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C (ShapelessCall.roles base leading) ShapelessCall.boundary
          (objectWrite objects 29383 (.vec [22601])) H (fun i => ShapelessCall.N8 i ∨ frame i) tail host)
        R live framed before after old old' output t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live output t ∧
      ProducerAnnotations roots H (fun i => ShapelessCall.N8 i ∨ frame i) (ShapelessCall.roles base leading)
        (objectWrite objects 29383 (.vec [22601])) ∧
      ProducerSupport roots H (fun i => ShapelessCall.N8 i ∨ frame i) output.ffi.mlx ∧ Inst ν₀ nextServer C₀ := by
  have native := h.native.2
  have signature := policy.shapeless_signature native 18194 281474976715599 29382 payload ShapelessCall.trace ShapelessCall.inputs
    closureLive vectorLive source_closure source_vector metadata metadata source_captured_meta source_input_meta rfl
  have keys : listSupport (fun p : Nat × Nat => p.1 < ShapelessCall.s8.nnext) ShapelessCall.m8 := by
    change listSupport (fun p : Nat × Nat => p.1 < 22602)
      [(15272,22601),(15271,22600),(15270,22599),(15268,22598),(15267,22597),(15266,22596),(15265,22595),(15262,1330),(15263,22586),(15264,1331)]
    dsimp [listSupport]; decide +kernel
  have outputs : listSupport (· < ShapelessCall.s8.nnext) ShapelessCall.trace.outs := by change 15272 < 22602 ∧ True; decide +kernel
  obtain ⟨t,left,right,post,retained,policyPost,support⟩ := CachedFamilyHost.retained_from_source
    ν₀ ν C₀ C R (ShapelessCall.roles base leading) ShapelessCall.boundary objects H
    (fun i => ShapelessCall.N0 i ∨ frame i) (fun i => ShapelessCall.N8 i ∨ frame i) tail host live framed before after old old' input s h inventory
    4782 4557 3127055 18194 29382 29383 281474976715599 functionObject signatureObject bufferObject chars!"i32" (.obj 4817)
    payload true ShapelessCall.trace ShapelessCall.inputs [] ShapelessCall.s8 ShapelessCall.m8
    source_control source_function source_kind source_signature source_signature_kind source_buffer source_buffer_kind
    signatureFrame closureLive vectorLive outputLive source_closure source_vector source_output signature metadata metadata source_captured_meta source_input_meta
    ((ShapelessCall.plan0 base leading).frame frame) keys outputs roots policy
    (by change 22595+8 < 2^64; decide +kernel) targetNodes (by change 29384 < 2^64; decide +kernel)
    targetHandles (by decide +kernel) targetHeap fnRole thisRole note selected
  have source := source_run C₀
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
  dsimp only at same
  rw [same] at post retained support
  have outputNodes : ShapelessCall.trace.outs.map (substOf ShapelessCall.m8) = [22601] := by rfl
  rw [outputNodes] at post policyPost
  exact ⟨t,source,right,post,retained,policyPost,support,pure_step_inst F ν₀ initialServer nextServer C₀ input output inst source_step source⟩

end Host.Load.Run.Full.Ordinary.ShapelessHost
