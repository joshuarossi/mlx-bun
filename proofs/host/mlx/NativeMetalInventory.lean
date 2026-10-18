import host.mlx.NativeMetalHost
import host.mlx.NativeBufferSlotFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- Fixed current call and buffer notes discharge the native family operand
roles. Its original execution retains all five occurrence inventories and the
strong indexed node/object relation; no target operand role is assumed. -/
theorem from_inventories {notes : RuntimeNotes} {privates : PrivateNotes} {captures : NativeCaptureNotes}
    {arrayNotes : ArrayNotes} {publicNotes : PublicNotes} {bufferNotes : BufferNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out kernel inv cfg stream slot : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (name source header : Name) (nIn nOut : Nat) (inputs oldOutputs : List Nat) (config : Config) (c : Cfg)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat kernel),.big (Int.ofNat inv),
      .big (Int.ofNat cfg),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (kernelLive : H kernel) (inputsLive : H inv) (configLive : H cfg) (slotLive : H slot)
    (sourceKernel : s₀.ffi.mlx.obj? kernel = some (.kernel name source header nIn nOut))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs))
    (sourceOutput : s₀.ffi.mlx.obj? slot = some (.vec oldOutputs))
    (sourceConfig : s₀.ffi.mlx.obj? cfg = some (.cfg c)) (configRole : objects cfg = .config config)
    (inputSupport : listSupport N inputs)
    (sourceNodes : s₀.ffi.mlx.nnext + config.outs.length < 2^64)
    (targetNodes : s.ffi.mlx.nnext + config.outs.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory bufferNotes ν₀ ν C₀ C R live s₀ s)
    (fnRole thisRole : Value)
    (note : notes.control = callNote fnRole thisRole ((arguments out kernel inv cfg stream).map FixedArgument.role))
    (selected : bufferNotes.owners out = some (handleSlotNotes slot)) :
    ∃ K t, interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
          (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H K tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      (slotKindRole slot).Holds ν C R (objectKindAt t (R.a out)) ∧
      (∀ i, N i → K i) ∧ listSupport K (result s₀.ffi kernel inputs c).2 ∧ listSupport K inputs ∧
      t.next = s.next ∧ t.stack = s.stack ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧
      RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      ArrayInventory arrayNotes ν₀ ν C₀ C R live (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      PublicInventory publicNotes ν₀ ν C₀ C R live (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      BufferInventory bufferNotes ν₀ ν C₀ C R live (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t := by
  have argumentRoles := (runtime.native_arguments fnRole thisRole (arguments out kernel inv cfg stream)
    (.obj fn) receiver _ hc₀ note).2
  have outputRole := (bufferInventory.slot_roles out slot selected).2
  obtain ⟨K,t,sourceRun,targetRun,post,slotRole,inclusion,outputs,ins,next,stack,outside,sourceFrame,targetFrame,control⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
    fn types out kernel inv cfg stream slot fo signature₀ outObject returns receiver name source header nIn nOut
    inputs oldOutputs config c hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ signatureFrame kernelLive inputsLive configLive slotLive
    sourceKernel sourceInputs sourceOutput sourceConfig configRole inputSupport argumentRoles outputRole
    sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  have sourceSlot := finishBuffer_slot_role ν₀ C₀ identity s₀ (resultWorld s₀.ffi kernel inputs c slot)
    out slot outObject symbol (callArgs out kernel inv cfg stream slot) sourceHeap
  have sourceOutside : ∀ a, a ≠ out → (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)).heap.get a = s₀.heap.get a := by
    intro a different
    change (s₀.heap.set out _).get a = s₀.heap.get a
    rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
  have buffers := bufferInventory.native_existing_slot h.heap out slot selected sourceFrame targetFrame
    sourceSlot slotRole sourceOutside outside
  obtain ⟨runtimePost,heapPost,arraysPost,publicPost⟩ := native_status_frame_inventories runtime heapInventory
    arrayInventory publicInventory (TableExtends.refl C₀) (TableExtends.refl C) sourceFrame targetFrame rfl control
  exact ⟨K,t,sourceRun,targetRun,post,slotRole,inclusion,outputs,ins,next,stack,outside,
    runtimePost,heapPost,arraysPost,publicPost,buffers⟩

end Host.Load.Run.Full.Ordinary.MetalFamilyHost
