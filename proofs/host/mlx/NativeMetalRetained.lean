import host.mlx.NativeMetalProducerInventory
import host.mlx.NativeAnnotationPolicy
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

private theorem output_role_length {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (held : ListR rel xs ys) : xs.length = ys.length := by
  induction held with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

/-- A Metal application consumes the retained call and output-slot notes,
preserves all six inventories, and returns the updated pure producer policy.
The next call can reuse this policy without a new ancestry assumption. -/
theorem retained_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn types out kernel inv cfg stream slot : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (name source header : Name) (nIn nOut : Nat) (inputs oldOutputs : List Nat) (config : Config) (c : Cfg)
    (control : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat kernel),.big (Int.ofNat inv),
      .big (Int.ofNat cfg),.big (Int.ofNat stream)])
    (read : s₀.heap.get fn = some (.obj fo))
    (kind : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signature₀)) (signatureKind : signature₀.kind = .array signature)
    (outputRead : s₀.heap.get out = some (.obj outObject))
    (outputKind : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
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
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole ((arguments out kernel inv cfg stream).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes slot)) :
    let sourcePost := finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
      (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
      symbol (callArgs out kernel inv cfg stream slot)
    let newRoles := kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs
    let newObjects := objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)
    let newSupport := outputSupport N (result s₀.ffi kernel inputs c).2
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects H newSupport tail host)
        R live framed before after old old' sourcePost t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live sourcePost t ∧
      ProducerAnnotations roots H newSupport newRoles newObjects ∧
      ProducerSupport roots H newSupport sourcePost.ffi.mlx := by
  dsimp only
  have native := h.native.2
  have initial := policy.source native
  have supportedInputs := initial.vector inv inputs inputsLive sourceInputs
  obtain ⟨_,_,configHeld,_⟩ := native.config_view_roles cfg configLive config c configRole sourceConfig
  have outputPolicy := policy.kernel_outputs kernel inputs config c config.outs c.outs
    (output_role_length configHeld.output) roles objects N s₀.ffi.mlx 0 supportedInputs
  have newPolicy := outputPolicy.write_object slot (.vec (result s₀.ffi kernel inputs c).2)
    (outputSupport_outputs N (result s₀.ffi kernel inputs c).2)
  obtain ⟨t,sourceRun,targetRun,post,_,_,_,_,_,_,_,runtimePost,heapPost,arraysPost,publicPost,buffersPost,producers⟩ :=
    from_supported_inventories ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
      fn types out kernel inv cfg stream slot fo signature₀ outObject returns receiver name source header nIn nOut
      inputs oldOutputs config c control read kind signatureRead signatureKind outputRead outputKind
      signatureFrame kernelLive inputsLive configLive slotLive sourceKernel sourceInputs sourceOutput sourceConfig configRole
      roots policy sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
      inventory.runtime inventory.heapInventory inventory.arrays inventory.publicFields inventory.buffers fnRole thisRole note selected
  exact ⟨t,sourceRun,targetRun,post,
    ⟨runtimePost,heapPost.privates,heapPost.captures,arraysPost,publicPost,buffersPost⟩,newPolicy,producers⟩

end Host.Load.Run.Full.Ordinary.MetalFamilyHost
