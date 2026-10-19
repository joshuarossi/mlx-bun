import host.mlx.NativeCachedRetained
import host.mlx.OrdinaryCachedStrongHost
import host.ts.RenameRuntimeSourceCut
import host.mlx.AnnotatedGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedRetained
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

private theorem literal_signature (mode : Bool) : ∀ metadata : Metadata,
    metadata.Literal → TraceSignature mode metadata metadata := by
  intro metadata
  induction metadata with
  | nil => intro _; exact .nil mode
  | cons entry rest ih => intro held; exact .literal mode entry.1 entry.2 held.1 (ih held.2)

noncomputable def initialServer := numberServer P.RestStream.micro0.micro23.S82
noncomputable def nextServer := numberServer P.RestStream.micro0.micro23.S83

/-- The source equation uses the original actual cached-call interpreter step. -/
theorem source_run (C : CSrv) : interpC (step CachedHost.F CachedHost.input).run C = some (CachedHost.output,C) := by
  rw [CachedHost.source_step]
  rfl

theorem source_step : interpS (step CachedHost.F CachedHost.input).run initialServer = some (CachedHost.output,nextServer) := by
  rw [CachedHost.source_step]
  host_kernel_rfl

/-- The existing actual three-node replay plan is reused with arbitrary framed
cache roots and all six retained inventories. Initial annotations and current
call/slot notes determine the target call and producer-policy update; the
source plan, trace selection and postconditions are not incoming obligations. -/
theorem retained_transport_servers (sourceServer resultServer : SSrv)
    (stepSource : interpS (step CachedHost.F CachedHost.input).run sourceServer = some (CachedHost.output,resultServer))
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (inst : Inst ν₀ sourceServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (CachedStrongHost.NativeRelation ν₀ ν C₀ C base objects H (fun i => CachedCall.N0 i ∨ frame i) tail host)
      R live framed before after old old' CachedHost.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live CachedHost.input s)
    (policy : ProducerAnnotations roots H (fun i => CachedCall.N0 i ∨ frame i)
      (CachedCall.roles (CachedCall.coupledRoles base)) objects)
    (signatureFrame : ¬ framed 4557) (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (targetNodes : s.ffi.mlx.nnext + CachedCall.trace.order.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole
      ((CachedFamilyHost.arguments 3126924 1354 29376).map FixedArgument.role))
    (selected : notes.buffers.owners 3126924 = some (handleSlotNotes 29377)) :
    ∃ t, interpC (step CachedHost.F CachedHost.input).run C₀ = some (CachedHost.output,C₀) ∧
      interpC (step CachedHost.F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (CachedStrongHost.NativeRelation ν₀ ν C₀ C base (CachedCall.outputObjectRoles objects) H
          (fun i => CachedCall.N3 i ∨ frame i) tail host)
        R live framed before after old old' CachedHost.output t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live CachedHost.output t ∧
      ProducerAnnotations roots H (fun i => CachedCall.N3 i ∨ frame i)
        (CachedCall.roles (CachedCall.coupledRoles base)) (CachedCall.outputObjectRoles objects) ∧
      ProducerSupport roots H (fun i => CachedCall.N3 i ∨ frame i) CachedHost.output.ffi.mlx ∧
      Inst ν₀ resultServer C₀ := by
  let roles := CachedCall.roles (CachedCall.coupledRoles base)
  let N := fun i => CachedCall.N0 i ∨ frame i
  have native := h.native.2
  have sourceSupport := policy.source native
  have inputs := sourceSupport.vector 29376 CachedCall.inputs vectorLive CachedCall.source_vector
  have weak := native.mono (fun _ _ held => held) (fun _ _ _ held => held) (fun _ _ _ held => held.base)
  obtain ⟨_,_,sourceMetadata,_⟩ := shapesOf_roles weak CachedCall.inputs CachedCall.metadata inputs CachedCall.source_real_inputs
  have literal : Metadata.Literal (inputRoles roles CachedCall.inputs) :=
    Metadata.literal_of_holds sourceMetadata ⟨⟨[1,1,10240],rfl⟩,⟨[128],rfl⟩,⟨[128],rfl⟩,True.intro⟩
  have sameRoles : inputRoles roles CachedCall.trace.ins = inputRoles roles CachedCall.inputs := by
    simp [roles,inputRoles,CachedCall.trace,CachedCall.inputs,CachedCall.roles,CachedCall.coupledRoles]
  have signature : TraceSignature false (inputRoles roles CachedCall.trace.ins) (inputRoles roles CachedCall.inputs) := by
    rw [sameRoles]
    exact literal_signature false _ literal
  have keys : listSupport (fun p : Nat × Nat => p.1 < CachedCall.s3.nnext) CachedCall.m3 := by
    change listSupport (fun p : Nat × Nat => p.1 < 22594)
      [(15257,22593),(15256,22592),(15255,22591),(15252,22590),(15253,10),(15254,11)]
    dsimp [listSupport]; decide +kernel
  have outputs : listSupport (· < CachedCall.s3.nnext) CachedCall.trace.outs := by
    change listSupport (· < 22594) [15255,15256,15257]
    dsimp [listSupport]; decide +kernel
  have sourceKind : NativeCall.calleeObject.kind = .fn (.native (.ffi .symbol)
      [.str CachedFamilyHost.symbol,.obj 4557,.str chars!"i32"]) := CachedHost.source_callee_kind
  have outputKind : CachedHost.bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 29377)) 8 0) := by
    rw [CachedHost.source_buffer_kind,CachedCall.actual_bytes]
  obtain ⟨t,left,right,post,retained,policyPost,support⟩ := CachedFamilyHost.retained_from_source
    ν₀ ν C₀ C R roles CachedCall.boundary objects H N (fun i => CachedCall.N3 i ∨ frame i) tail host
    live framed before after old old' CachedHost.input s h inventory
    4782 4557 3126924 1354 29376 29377 281474976715599 NativeCall.calleeObject CachedHost.signatureObject CachedHost.bufferObject
    chars!"i32" (.obj 4817) CachedCall.payload false CachedCall.trace CachedCall.inputs [] CachedCall.s3 CachedCall.m3
    CachedHost.source_control CachedHost.source_callee sourceKind CachedHost.source_signature CachedHost.source_signature_kind
    CachedHost.source_buffer outputKind signatureFrame closureLive vectorLive outputLive
    CachedCall.source_closure CachedCall.source_vector CachedCall.source_output_vector signature CachedCall.metadata CachedCall.metadata
    CachedCall.source_trace_inputs CachedCall.source_real_inputs ((CachedCall.plan0 (CachedCall.coupledRoles base) native.nodeMap.injective).frame frame)
    keys outputs roots policy (by change 22591+3 < 2^64; decide +kernel) targetNodes (by change 29378 < 2^64; decide +kernel)
    targetHandles (by decide +kernel) targetHeap fnRole thisRole note selected
  have source := source_run C₀
  have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
  dsimp only at same
  rw [same] at post retained support
  exact ⟨t,source,right,post,retained,policyPost,support,
    pure_step_inst CachedHost.F ν₀ sourceServer resultServer C₀ CachedHost.input CachedHost.output inst stepSource source⟩

/-- Original source-server specialization, with its existing statement preserved. -/
theorem retained_transport (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop) (tail : List NumV)
    (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (inst : Inst ν₀ initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (CachedStrongHost.NativeRelation ν₀ ν C₀ C base objects H (fun i => CachedCall.N0 i ∨ frame i) tail host)
      R live framed before after old old' CachedHost.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live CachedHost.input s)
    (policy : ProducerAnnotations roots H (fun i => CachedCall.N0 i ∨ frame i)
      (CachedCall.roles (CachedCall.coupledRoles base)) objects)
    (signatureFrame : ¬ framed 4557) (closureLive : H 1354) (vectorLive : H 29376) (outputLive : H 29377)
    (targetNodes : s.ffi.mlx.nnext + CachedCall.trace.order.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole
      ((CachedFamilyHost.arguments 3126924 1354 29376).map FixedArgument.role))
    (selected : notes.buffers.owners 3126924 = some (handleSlotNotes 29377)) :
    ∃ t, interpC (step CachedHost.F CachedHost.input).run C₀ = some (CachedHost.output,C₀) ∧
      interpC (step CachedHost.F s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (CachedStrongHost.NativeRelation ν₀ ν C₀ C base (CachedCall.outputObjectRoles objects) H
          (fun i => CachedCall.N3 i ∨ frame i) tail host)
        R live framed before after old old' CachedHost.output t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live CachedHost.output t ∧
      ProducerAnnotations roots H (fun i => CachedCall.N3 i ∨ frame i)
        (CachedCall.roles (CachedCall.coupledRoles base)) (CachedCall.outputObjectRoles objects) ∧
      ProducerSupport roots H (fun i => CachedCall.N3 i ∨ frame i) CachedHost.output.ffi.mlx ∧
      Inst ν₀ nextServer C₀ := by
  exact retained_transport_servers initialServer nextServer source_step notes ν₀ ν C₀ C R
    base objects H frame roots tail host live framed before after old old' s inst h inventory policy
    signatureFrame closureLive vectorLive outputLive targetNodes targetHandles targetHeap fnRole thisRole note selected

end Host.Load.Run.Full.Ordinary.CachedRetained
