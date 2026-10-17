import models.qwen.AttentionAffineMemory

namespace Inference.Models.Qwen.AttentionAffineConstruction
open Contracts.Mlx Layers
set_option maxRecDepth 10000

structure Weights (p : AttentionHeads.Projections) (memory : ByteMemory.Bytes) where
  q : AffineDevice.Storage p.q
  k : AffineDevice.Storage p.k
  v : AffineDevice.Storage p.v
  qShared : AffineMemory.Shared p.q q memory
  kShared : AffineMemory.Shared p.k k memory
  vShared : AffineMemory.Shared p.v v memory

structure Regions where
  q : Nat
  k : Nat
  v : Nat

def Regions.Live (r : Regions) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint r.q 24576 base size ∧
  MemoryRegions.Disjoint r.k 2048 base size ∧ MemoryRegions.Disjoint r.v 2048 base size

structure Allocation (r : Regions) (source : ArrayStorage.BFBuffer input) (w : Weights p source.bytes) : Prop where
  qAligned : r.q%2=0
  kAligned : r.k%2=0
  vAligned : r.v%2=0
  qBounded : r.q+24576 ≤ 2^64
  kBounded : r.k+2048 ≤ 2^64
  vBounded : r.v+2048 ≤ 2^64
  inputLive : r.Live source.base 10240
  qLive : AffineMemoryFrames.Protected p.q w.q r.Live
  kLive : AffineMemoryFrames.Protected p.k w.k r.Live
  vLive : AffineMemoryFrames.Protected p.v w.v r.Live
  kQ : MemoryRegions.Disjoint r.k 2048 r.q 24576
  vQ : MemoryRegions.Disjoint r.v 2048 r.q 24576
  vK : MemoryRegions.Disjoint r.v 2048 r.k 2048

theorem separate (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p)
    (h : AffineMemoryFrames.Protected p w (MemoryRegions.Disjoint base size)) :
    AffineMemory.Separate p w base size := by
  cases p <;> exact ⟨h.1,h.2.1,h.2.2⟩

theorem base_fromStorage {steps groups : Nat} (p : AffineVerifyLinear.Projection steps (4*groups))
    (input : Fin (steps*512) → ArrayStorage.BF) (w : AffineDevice.Storage p)
    (source : ArrayStorage.BFBuffer input) (shared : AffineMemory.Shared p w source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups) ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate p w base (2*(4*groups))) :
    (AffineMemory.fromStorage p input w source shared base aligned bounded inputSeparate weightsSeparate).base=base := by
  cases p <;> rfl

theorem forward_base {steps groups : Nat} {p : AffineVerifyLinear.Projection steps (4*groups)}
    {input : Fin (steps*512) → ArrayStorage.BF} (e : AffineMemory.Execution p input) :
    e.forwardBuffer.base=e.base := by cases p <;> rfl

-- A heap certificate retains bytes at every original live weight region.
structure Prefix (r : Regions) (source : ArrayStorage.BFBuffer input) where
  current : ArrayStorage.BFBuffer input
  base : current.base=source.base
  same : ∀ base size, r.Live base size → ∀ offset < size,
    current.bytes (base+offset)=source.bytes (base+offset)

def Prefix.initial (r : Regions) (source : ArrayStorage.BFBuffer input) : Prefix r source :=
  ⟨source,rfl,fun _ _ _ _ _ => rfl⟩

def Prefix.weights (heap : Prefix r source) (p : AffineVerifyLinear.Projection steps rows)
    (w : AffineDevice.Storage p) (shared : AffineMemory.Shared p w source.bytes)
    (live : AffineMemoryFrames.Protected p w r.Live) : AffineDevice.Storage p :=
  AffineMemoryFrames.reframe p w heap.current.bytes
    (AffineMemoryFrames.stable p w source.bytes heap.current.bytes shared
      (AffineMemoryFrames.protected_mono p w heap.same live))

theorem Prefix.weights_shared (heap : Prefix r source) (p : AffineVerifyLinear.Projection steps rows)
    (w : AffineDevice.Storage p) (shared : AffineMemory.Shared p w source.bytes)
    (live : AffineMemoryFrames.Protected p w r.Live) :
    AffineMemory.Shared p (heap.weights p w shared live) heap.current.bytes :=
  AffineMemoryFrames.reframe_shared p w heap.current.bytes _

def buffers (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p) :
    Kernels.Quantization.AffineLoads.Buffers :=
  match p with | .bits3 _ => w.buffers | .bits4 _ => w.buffers

theorem Prefix.weights_bases (heap : Prefix r source) (p : AffineVerifyLinear.Projection steps rows)
    (w : AffineDevice.Storage p) (shared : AffineMemory.Shared p w source.bytes)
    (live : AffineMemoryFrames.Protected p w r.Live) :
    let original := buffers p w
    let current := buffers p (heap.weights p w shared live)
    current.packedBase=original.packedBase ∧ current.scaleBase=original.scaleBase ∧
      current.biasBase=original.biasBase := by cases p <;> exact ⟨rfl,rfl,rfl⟩

theorem Prefix.weights_scale (heap : Prefix r source) (p : AffineVerifyLinear.Projection steps rows)
    (w : AffineDevice.Storage p) (shared : AffineMemory.Shared p w source.bytes)
    (live : AffineMemoryFrames.Protected p w r.Live) (row : Fin rows) (group : Fin (steps*8)) :
    Kernels.Quantization.AffineLoads.scale (buffers p (heap.weights p w shared live)) row group=
      Kernels.Quantization.AffineLoads.scale (buffers p w) row group := by
  cases p <;> exact Kernels.Quantization.AffineMemory.scale_eq
    (AffineMemoryFrames.stable _ _ _ _ shared (AffineMemoryFrames.protected_mono _ _ heap.same live)) row group

theorem Prefix.weights_bias (heap : Prefix r source) (p : AffineVerifyLinear.Projection steps rows)
    (w : AffineDevice.Storage p) (shared : AffineMemory.Shared p w source.bytes)
    (live : AffineMemoryFrames.Protected p w r.Live) (row : Fin rows) (group : Fin (steps*8)) :
    Kernels.Quantization.AffineLoads.bias (buffers p (heap.weights p w shared live)) row group=
      Kernels.Quantization.AffineLoads.bias (buffers p w) row group := by
  cases p <;> exact Kernels.Quantization.AffineMemory.bias_eq
    (AffineMemoryFrames.stable _ _ _ _ shared (AffineMemoryFrames.protected_mono _ _ heap.same live)) row group

def Prefix.advance {steps groups : Nat} {input : Fin (steps*512) → ArrayStorage.BF}
    {source : ArrayStorage.BFBuffer input} (heap : Prefix r source)
    {p : AffineVerifyLinear.Projection steps (4*groups)} (e : AffineMemory.Execution p input)
    (linked : e.source=heap.current)
    (live : ∀ base size, r.Live base size → MemoryRegions.Disjoint e.base (2*(4*groups)) base size) :
    Prefix r source where
  current := AffineMemoryFrames.sourceAfter e
  base := by
    change e.source.base=source.base
    rw [linked, heap.base]
  same base size h offset bound := by
    change e.outputBuffer.bytes (base+offset)=source.bytes (base+offset)
    exact (e.other_region (live base size h) offset bound).trans
      ((congrFun (congrArg ArrayStorage.BFBuffer.bytes linked) _).trans (heap.same base size h offset bound))

def fromStorage (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights p source.bytes)
    (r : Regions) (allocation : Allocation r source w) : AttentionAffineMemory.Execution p input := by
  let p0 := Prefix.initial r source
  let w0 := p0.weights p.q w.q w.qShared allocation.qLive
  have shared0 := p0.weights_shared p.q w.q w.qShared allocation.qLive
  have safe0 : AffineMemory.Separate p.q w0 r.q 24576 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected p.q w.q p0.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.1) allocation.qLive
  have input0 : MemoryRegions.Disjoint r.q 24576 p0.current.base 10240 := by
    rw [p0.base]
    exact allocation.inputLive.1
  let e0 := AffineMemory.fromStorage (groups := 3072) p.q input w0 p0.current shared0 r.q allocation.qAligned allocation.qBounded input0 safe0
  have source0 : e0.source=p0.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base0 : e0.base=r.q := base_fromStorage _ _ _ _ _ _ _ _ _ _
  let p1 := p0.advance e0 source0 (fun _ _ h => by rw [base0]; exact h.1)
  let w1 := p1.weights p.k w.k w.kShared allocation.kLive
  have shared1 := p1.weights_shared p.k w.k w.kShared allocation.kLive
  have safe1 : AffineMemory.Separate p.k w1 r.k 2048 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected p.k w.k p1.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.2.1) allocation.kLive
  have input1 : MemoryRegions.Disjoint r.k 2048 p1.current.base 10240 := by
    rw [p1.base]
    exact allocation.inputLive.2.1
  let e1 := AffineMemory.fromStorage (groups := 256) p.k input w1 p1.current shared1 r.k allocation.kAligned allocation.kBounded input1 safe1
  have source1 : e1.source=p1.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base1 : e1.base=r.k := base_fromStorage _ _ _ _ _ _ _ _ _ _
  let p2 := p1.advance e1 source1 (fun _ _ h => by rw [base1]; exact h.2.1)
  let w2 := p2.weights p.v w.v w.vShared allocation.vLive
  have shared2 := p2.weights_shared p.v w.v w.vShared allocation.vLive
  have safe2 : AffineMemory.Separate p.v w2 r.v 2048 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected p.v w.v p2.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.2.2) allocation.vLive
  have input2 : MemoryRegions.Disjoint r.v 2048 p2.current.base 10240 := by
    rw [p2.base]
    exact allocation.inputLive.2.2
  let e2 := AffineMemory.fromStorage (groups := 256) p.v input w2 p2.current shared2 r.v allocation.vAligned allocation.vBounded input2 safe2
  have source2 : e2.source=p2.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base2 : e2.base=r.v := base_fromStorage _ _ _ _ _ _ _ _ _ _
  refine ⟨e0,e1,e2,source1,source2,?_,?_,?_⟩
  · rw [forward_base e0,base1,base0]
    exact allocation.kQ
  · rw [forward_base e0,base2,base0]
    exact allocation.vQ
  · rw [forward_base e1,base2,base1]
    exact allocation.vK

theorem fromStorage_source (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights p source.bytes)
    (r : Regions) (allocation : Allocation r source w) :
    (fromStorage p input source w r allocation).source=source := by
  unfold fromStorage AttentionAffineMemory.Execution.source
  exact AffineMemory.source_fromStorage _ _ _ _ _ _ _ _

theorem fromStorage_bases (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights p source.bytes)
    (r : Regions) (allocation : Allocation r source w) :
    let e := fromStorage p input source w r allocation
    e.q.base=r.q ∧ e.k.base=r.k ∧ e.v.base=r.v := by
  unfold fromStorage
  exact ⟨base_fromStorage _ _ _ _ _ _ _ _ _ _, base_fromStorage _ _ _ _ _ _ _ _ _ _,
    base_fromStorage _ _ _ _ _ _ _ _ _ _⟩

end Inference.Models.Qwen.AttentionAffineConstruction
