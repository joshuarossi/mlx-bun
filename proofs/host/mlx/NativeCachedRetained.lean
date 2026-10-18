import host.mlx.NativeCachedHost
import host.mlx.NativeReplayPolicy
import host.mlx.NativeBufferSlotFrame
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- A source replay plan closes the complete original cached FFI call from
current retained call/slot notes. All six host inventories, fixed native object
payloads, and the producer policy survive the result-vector write. No target
run, operand, output role, or final producer policy is a premise. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N K : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out cls inv slot callback : Nat) (function signatureObject outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (payload : Arg) (shapeless : Bool) (trace : Host.Mlx.Ffi.Trace) (inputs oldOutputs : List Nat)
    (final : Host.Mlx.Ffi.St) (substitutions : List (Nat × Nat))
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat cls),.big (Int.ofNat inv)])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject)) (signatureKind : signatureObject.kind = .array signature)
    (outputRead : s₀.heap.get out = some (.obj outObject))
    (outputKind : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (closureLive : H cls) (inputsLive : H inv) (slotLive : H slot)
    (sourceClosure : s₀.ffi.mlx.obj? cls = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs))
    (sourceOutput : s₀.ffi.mlx.obj? slot = some (.vec oldOutputs))
    (traceSignature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles inputs))
    (traceMeta inputsMeta : List (List Dim × Nat))
    (sourceTraceMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx trace.ins = some traceMeta)
    (sourceInputsMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx inputs = some inputsMeta)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N s₀.ffi.mlx (trace.ins.zip inputs) trace.order K final substitutions)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (sourceNodes : s₀.ffi.mlx.nnext + trace.order.length < 2^64)
    (targetNodes : s.ffi.mlx.nnext + trace.order.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((arguments out cls inv).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes slot)) :
    let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions))) out 0 outObject
      (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
      symbol (callArgs out cls inv slot)
    let newObjects := objectWrite objects slot (.vec (trace.outs.map (substOf substitutions)))
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary newObjects H K tail host)
        R live framed before after old old' sourcePost t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live sourcePost t ∧
      ProducerAnnotations roots H K roles newObjects ∧ ProducerSupport roots H K sourcePost.ffi.mlx := by
  dsimp only
  have initial := policy.source h.native.2
  have inputSupport := initial.vector inv inputs inputsLive sourceInputs
  have traceSupport := initial.single_trace cls callback payload shapeless trace closureLive sourceClosure
  have argumentRoles := (inventory.runtime.native_arguments fnRole thisRole (arguments out cls inv)
    (.obj fn) receiver _ control note).2
  have slotRole := (inventory.buffers.slot_roles out slot selected).2
  obtain ⟨final',t,left,right,post,newSlot,inclusion,supported,_,_,_,_,_,outside,sourceFrame,targetFrame,returnControl⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N K tail host live framed before after old old' s₀ s h
      fn types out cls inv slot callback function signatureObject outObject returns receiver payload shapeless trace inputs oldOutputs
      final substitutions control read kind signatureRead signatureKind outputRead outputKind signatureFrame closureLive inputsLive slotLive
      sourceClosure sourceInputs sourceOutput traceSupport.inputs inputSupport traceSignature traceMeta inputsMeta sourceTraceMeta sourceInputsMeta
      plan keys outputs traceSupport.outputs argumentRoles slotRole sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  have sourceSlot := finishBuffer_slot_role ν₀ C₀ identity s₀ (resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions)))
    out slot outObject symbol (callArgs out cls inv slot) sourceHeap
  have sourceOutside : ∀ a, a ≠ out →
      (finishBuffer s₀ (resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions))) out 0 outObject
        (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
        symbol (callArgs out cls inv slot)).heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have buffersPost := inventory.buffers.native_existing_slot h.heap out slot selected sourceFrame targetFrame
    sourceSlot newSlot sourceOutside outside
  obtain ⟨runtimePost,heapPost,arraysPost,publicPost⟩ := native_status_frame_inventories inventory.runtime inventory.heapInventory
    inventory.arrays inventory.publicFields (TableExtends.refl C₀) (TableExtends.refl C) sourceFrame targetFrame rfl returnControl
  have sourceRoles : ∀ i node, K i → final.nodes.get i = some node →
      (roles i).Holds ν₀ C₀ identity node := by
    intro i node held lookup
    obtain ⟨_,_,related⟩ := post.native.2.node_view held lookup
    exact related.source
  have replayPolicy := policy.replay plan (zip_support_right trace.ins inputs inputSupport) sourceNodes sourceRoles
  have newPolicy := replayPolicy.write_object slot (.vec (trace.outs.map (substOf substitutions))) supported
  exact ⟨t,left,right,post,⟨runtimePost,heapPost.privates,heapPost.captures,arraysPost,publicPost,buffersPost⟩,
    newPolicy,newPolicy.source post.native.2⟩

end Host.Load.Run.Full.Ordinary.CachedFamilyHost
