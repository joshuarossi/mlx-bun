import models.qwen.DeltaAffineMemory

namespace Inference.Models.Qwen.DeltaAffineConstruction
open Contracts.Mlx Layers
set_option maxRecDepth 10000

structure Weights (layer : DeltaNet.Layer) (memory : ByteMemory.Bytes) where
  qkv : AffineDevice.Storage layer.qkv
  z : AffineDevice.Storage layer.z
  a : AffineDevice.Storage layer.a
  b : AffineDevice.Storage layer.b
  qkvShared : AffineMemory.Shared layer.qkv qkv memory
  zShared : AffineMemory.Shared layer.z z memory
  aShared : AffineMemory.Shared layer.a a memory
  bShared : AffineMemory.Shared layer.b b memory

structure Regions where
  qkv : Nat
  z : Nat
  a : Nat
  b : Nat

def Regions.Live (r : Regions) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint r.qkv 20480 base size ∧
  MemoryRegions.Disjoint r.z 12288 base size ∧
  MemoryRegions.Disjoint r.a 96 base size ∧
  MemoryRegions.Disjoint r.b 96 base size

structure Allocation (r : Regions) (source : ArrayStorage.BFBuffer input) (w : Weights layer source.bytes) : Prop where
  qkvAligned : r.qkv%2=0
  zAligned : r.z%2=0
  aAligned : r.a%2=0
  bAligned : r.b%2=0
  qkvBounded : r.qkv+20480 ≤ 2^64
  zBounded : r.z+12288 ≤ 2^64
  aBounded : r.a+96 ≤ 2^64
  bBounded : r.b+96 ≤ 2^64
  inputLive : r.Live source.base 10240
  qkvLive : AffineMemoryFrames.Protected layer.qkv w.qkv r.Live
  zLive : AffineMemoryFrames.Protected layer.z w.z r.Live
  aLive : AffineMemoryFrames.Protected layer.a w.a r.Live
  bLive : AffineMemoryFrames.Protected layer.b w.b r.Live
  zQkv : MemoryRegions.Disjoint r.z 12288 r.qkv 20480
  aQkv : MemoryRegions.Disjoint r.a 96 r.qkv 20480
  bQkv : MemoryRegions.Disjoint r.b 96 r.qkv 20480
  aZ : MemoryRegions.Disjoint r.a 96 r.z 12288
  bZ : MemoryRegions.Disjoint r.b 96 r.z 12288
  bA : MemoryRegions.Disjoint r.b 96 r.a 96

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

def fromStorage (layer : DeltaNet.Layer) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights layer source.bytes)
    (r : Regions) (allocation : Allocation r source w) : DeltaAffineMemory.Execution layer input := by
  let p0 := Prefix.initial r source
  let w0 := p0.weights layer.qkv w.qkv w.qkvShared allocation.qkvLive
  have shared0 := p0.weights_shared layer.qkv w.qkv w.qkvShared allocation.qkvLive
  have safe0 : AffineMemory.Separate layer.qkv w0 r.qkv 20480 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected layer.qkv w.qkv p0.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.1) allocation.qkvLive
  have input0 : MemoryRegions.Disjoint r.qkv 20480 p0.current.base 10240 := by
    rw [p0.base]
    exact allocation.inputLive.1
  let e0 := AffineMemory.fromStorage (groups := 2560) layer.qkv input w0 p0.current shared0 r.qkv allocation.qkvAligned allocation.qkvBounded input0 safe0
  have source0 : e0.source=p0.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base0 : e0.base=r.qkv := base_fromStorage _ _ _ _ _ _ _ _ _ _
  let p1 := p0.advance e0 source0 (fun _ _ h => by rw [base0]; exact h.1)
  let w1 := p1.weights layer.z w.z w.zShared allocation.zLive
  have shared1 := p1.weights_shared layer.z w.z w.zShared allocation.zLive
  have safe1 : AffineMemory.Separate layer.z w1 r.z 12288 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected layer.z w.z p1.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.2.1) allocation.zLive
  have input1 : MemoryRegions.Disjoint r.z 12288 p1.current.base 10240 := by
    rw [p1.base]
    exact allocation.inputLive.2.1
  let e1 := AffineMemory.fromStorage (groups := 1536) layer.z input w1 p1.current shared1 r.z allocation.zAligned allocation.zBounded input1 safe1
  have source1 : e1.source=p1.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base1 : e1.base=r.z := base_fromStorage _ _ _ _ _ _ _ _ _ _
  let p2 := p1.advance e1 source1 (fun _ _ h => by rw [base1]; exact h.2.1)
  let w2 := p2.weights layer.a w.a w.aShared allocation.aLive
  have shared2 := p2.weights_shared layer.a w.a w.aShared allocation.aLive
  have safe2 : AffineMemory.Separate layer.a w2 r.a 96 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected layer.a w.a p2.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.2.2.1) allocation.aLive
  have input2 : MemoryRegions.Disjoint r.a 96 p2.current.base 10240 := by
    rw [p2.base]
    exact allocation.inputLive.2.2.1
  let e2 := AffineMemory.fromStorage (groups := 12) layer.a input w2 p2.current shared2 r.a allocation.aAligned allocation.aBounded input2 safe2
  have source2 : e2.source=p2.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base2 : e2.base=r.a := base_fromStorage _ _ _ _ _ _ _ _ _ _
  let p3 := p2.advance e2 source2 (fun _ _ h => by rw [base2]; exact h.2.2.1)
  let w3 := p3.weights layer.b w.b w.bShared allocation.bLive
  have shared3 := p3.weights_shared layer.b w.b w.bShared allocation.bLive
  have safe3 : AffineMemory.Separate layer.b w3 r.b 96 := by
    apply separate
    apply (AffineMemoryFrames.reframe_protected layer.b w.b p3.current.bytes _ _).mpr
    exact AffineMemoryFrames.protected_mono _ _ (fun _ _ h => h.2.2.2) allocation.bLive
  have input3 : MemoryRegions.Disjoint r.b 96 p3.current.base 10240 := by
    rw [p3.base]
    exact allocation.inputLive.2.2.2
  let e3 := AffineMemory.fromStorage (groups := 12) layer.b input w3 p3.current shared3 r.b allocation.bAligned allocation.bBounded input3 safe3
  have source3 : e3.source=p3.current := AffineMemory.source_fromStorage _ _ _ _ _ _ _ _
  have base3 : e3.base=r.b := base_fromStorage _ _ _ _ _ _ _ _ _ _
  refine ⟨e0,e1,e2,e3,source1,source2,source3,?_,?_,?_,?_,?_,?_⟩
  · rw [forward_base e0]
    rw [base1,base0]
    exact allocation.zQkv
  · rw [forward_base e0]
    rw [base2,base0]
    exact allocation.aQkv
  · rw [forward_base e0]
    rw [base3,base0]
    exact allocation.bQkv
  · rw [forward_base e1]
    rw [base2,base1]
    exact allocation.aZ
  · rw [forward_base e1]
    rw [base3,base1]
    exact allocation.bZ
  · rw [forward_base e2]
    rw [base3,base2]
    exact allocation.bA

theorem fromStorage_source (layer : DeltaNet.Layer) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights layer source.bytes)
    (r : Regions) (allocation : Allocation r source w) :
    (fromStorage layer input source w r allocation).source=source := by
  unfold fromStorage DeltaAffineMemory.Execution.source
  exact AffineMemory.source_fromStorage _ _ _ _ _ _ _ _

theorem fromStorage_bases (layer : DeltaNet.Layer) (input : Fin 5120 → ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : Weights layer source.bytes)
    (r : Regions) (allocation : Allocation r source w) :
    let e := fromStorage layer input source w r allocation
    e.qkv.base=r.qkv ∧ e.z.base=r.z ∧ e.a.base=r.a ∧ e.b.base=r.b := by
  unfold fromStorage
  exact ⟨base_fromStorage _ _ _ _ _ _ _ _ _ _, base_fromStorage _ _ _ _ _ _ _ _ _ _,
    base_fromStorage _ _ _ _ _ _ _ _ _ _, base_fromStorage _ _ _ _ _ _ _ _ _ _⟩

end Inference.Models.Qwen.DeltaAffineConstruction
