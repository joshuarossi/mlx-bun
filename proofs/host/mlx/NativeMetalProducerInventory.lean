import host.mlx.NativeMetalInventory
import host.mlx.NativeAnnotationSupport
import host.mlx.NativeKernelSupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The fixed producer policy derives the current input ancestry. The actual
Metal call retains precisely old support plus its output node IDs, including
all strong native annotations and host occurrence inventories. -/
theorem from_supported_inventories {notes : RuntimeNotes} {privates : PrivateNotes} {captures : NativeCaptureNotes}
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
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
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
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
          (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H (outputSupport N (result s₀.ffi kernel inputs c).2) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      (slotKindRole slot).Holds ν C R (objectKindAt t (R.a out)) ∧
      (∀ i, N i → (outputSupport N (result s₀.ffi kernel inputs c).2) i) ∧ listSupport (outputSupport N (result s₀.ffi kernel inputs c).2) (result s₀.ffi kernel inputs c).2 ∧ listSupport (outputSupport N (result s₀.ffi kernel inputs c).2) inputs ∧
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
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      ProducerSupport roots H (outputSupport N (result s₀.ffi kernel inputs c).2) (resultWorld s₀.ffi kernel inputs c slot).mlx := by
  have native := h.native.2
  have initial := policy.source native
  have inputSupport := initial.vector inv inputs inputsLive sourceInputs
  obtain ⟨K,t,sourceRun,targetRun,post,slotRole,inclusion,outputs,ins,next,stack,outside,
      runtimePost,heapPost,arraysPost,publicPost,buffers⟩ := from_inventories ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
    fn types out kernel inv cfg stream slot fo signature₀ outObject returns receiver name source header nIn nOut
    inputs oldOutputs config c hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ signatureFrame kernelLive inputsLive configLive slotLive
    sourceKernel sourceInputs sourceOutput sourceConfig configRole inputSupport
    sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
    runtime heapInventory arrayInventory publicInventory bufferInventory fnRole thisRole note selected
  let Ke := outputSupport N (result s₀.ffi kernel inputs c).2
  have retained : ∀ i, Ke i → K i := by
    intro i member
    exact member.elim (fun output => support_member _ outputs i output) (inclusion i)
  have arraySupport : ∀ a i, H a → (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)).ffi.mlx.arrs.get a = some i → Ke i := by
    intro a i held read
    change (kernelApply.outs kernel inputs c s₀.ffi.mlx 0 c.outs).1.arrs.get a = some i at read
    rw [kernel_outputs_arrs] at read
    exact Or.inr (native.arrLive a i held read)
  have narrowed : StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C
        (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
        (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H Ke tail host)
      R live framed before after old old' (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t :=
    {post with native := ⟨post.native.1,post.native.2.restrictSupport retained arraySupport⟩}
  have sourceSlotBound := Nat.lt_trans (native.liveHandleBound slot slotLive) sourceHandles
  have targetSlotBound := Nat.lt_trans (native.handleMap.bound slot (native.liveHandleBound slot slotLive)) targetHandles
  obtain ⟨_,_,_,_,_,producers,_,_⟩ := native.kernelApply_existing_supported initial
    (.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (.jsPtr (R.a out) 0 (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0))
    out 0 slot kernel inv cfg name source header nIn nOut inputs oldOutputs config c
    slotLive kernelLive inputsLive configLive rfl rfl sourceKernel sourceInputs sourceOutput sourceConfig configRole
    sourceNodes targetNodes sourceSlotBound targetSlotBound
  have supportedIns : listSupport Ke inputs := by
    have lift : ∀ xs : List Nat, listSupport N xs → listSupport Ke xs := by
      intro xs
      induction xs with
      | nil => intro _; trivial
      | cons i xs ih => intro held; exact ⟨Or.inr held.1,ih held.2⟩
    exact lift inputs inputSupport
  exact ⟨t,sourceRun,targetRun,narrowed,slotRole,outputSupport_old _,outputSupport_outputs N _,
    supportedIns,
    next,stack,outside,runtimePost,heapPost,arraysPost,publicPost,buffers,producers⟩

end Host.Load.Run.Full.Ordinary.MetalFamilyHost
