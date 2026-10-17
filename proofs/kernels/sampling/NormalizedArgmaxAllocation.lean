import kernels.sampling.NormalizedArgmaxMemory

namespace Inference.Kernels.Sampling.NormalizedArgmaxAllocation
open Contracts.Mlx
set_option maxRecDepth 10000

-- One fixed global workspace: BF16 normalizer at 0, FP32 tile scores at 4,
-- uint32 tile ids at 976, and the final uint32 token at 1948.
def bytes : Nat := 1952

structure Workspace (source : ArrayStorage.BFBuffer logits) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes≤2^64
  separate : MemoryRegions.Disjoint base bytes source.base 496640

theorem subregion {workspace base size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace bytes base size) (inside : offset+count≤bytes) :
    MemoryRegions.Disjoint (workspace+offset) count base size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {logits : Fin 248320 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer logits} {base size : Nat}

def Workspace.partials (w : Workspace source) : ArgmaxPairMemory.Layout 243 where
  scores := w.base+4
  ids := w.base+976
  scoreAligned := by have := w.aligned; omega
  idAligned := by have := w.aligned; omega
  scoreBounded := by have := w.bounded; dsimp [bytes] at this; omega
  idBounded := by have := w.bounded; dsimp [bytes] at this; omega
  separate := Or.inl (by omega)

theorem Workspace.normalizer_source (w : Workspace source) : MemoryRegions.Disjoint w.base 2 source.base 496640 := by
  simpa only [Nat.add_zero] using subregion (offset := 0) (count := 2) w.separate (by decide +kernel)

theorem Workspace.partials_source (w : Workspace source) : ArgmaxPairMemory.Safe w.partials source.base 496640 :=
  ⟨subregion w.separate (by decide +kernel : 4+972≤bytes),subregion w.separate (by decide +kernel : 976+972≤bytes)⟩

theorem Workspace.partials_normalizer (w : Workspace source) : ArgmaxPairMemory.Safe w.partials w.base 2 :=
  ⟨Or.inr (by dsimp [Workspace.partials]; omega),Or.inr (by dsimp [Workspace.partials]; omega)⟩

theorem Workspace.token_source (w : Workspace source) : MemoryRegions.Disjoint (w.base+1948) 4 source.base 496640 :=
  subregion w.separate (by decide +kernel : 1948+4≤bytes)

def Workspace.pipeline (w : Workspace source) (p : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    NormalizedArgmaxMemory.Pipeline p source :=
  NormalizedArgmaxMemory.Pipeline.canonical p source lseLocal w.base
    (by have := w.aligned; omega)
    (by have := w.bounded; dsimp [bytes] at this; omega)
    w.normalizer_source w.partials tileLocal finishLocal w.partials_source w.partials_normalizer
    (w.base+1948) (by have := w.aligned; omega)
    (by have := w.bounded; dsimp [bytes] at this; omega)
    (Or.inr (by dsimp [Workspace.partials]; omega))
    (Or.inr (by dsimp [Workspace.partials]; omega))
    w.token_source (Or.inr (by omega))

theorem Workspace.token_base (w : Workspace source) (p : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    (w.pipeline p lseLocal tileLocal finishLocal).selection.destination=w.base+1948 := rfl

theorem Workspace.protect (w : Workspace source) (p : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (safe : MemoryRegions.Disjoint w.base bytes base size) :
    (w.pipeline p lseLocal tileLocal finishLocal).Safe base size := by
  change MemoryRegions.Disjoint w.base 2 base size ∧
    (MemoryRegions.Disjoint (w.base+4) 972 base size ∧ MemoryRegions.Disjoint (w.base+976) 972 base size) ∧
    MemoryRegions.Disjoint (w.base+1948) 4 base size
  exact ⟨by simpa only [Nat.add_zero] using subregion (offset := 0) (count := 2) safe (by decide +kernel),
    ⟨subregion safe (by decide +kernel : 4+972≤bytes),subregion safe (by decide +kernel : 976+972≤bytes)⟩,
    subregion safe (by decide +kernel : 1948+4≤bytes)⟩

theorem Workspace.other_region (w : Workspace source) (p : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (safe : MemoryRegions.Disjoint w.base bytes base size) (offset : Nat) (bound : offset<size) :
    (w.pipeline p lseLocal tileLocal finishLocal).memory (base+offset)=source.bytes (base+offset) :=
  (w.pipeline p lseLocal tileLocal finishLocal).other_region (w.protect p lseLocal tileLocal finishLocal safe) offset bound

-- This witnesses the spatial contract whenever the logits allocation has
-- room after it. Native ownership of that space remains a separate premise.
def afterLogits (source : ArrayStorage.BFBuffer logits)
    (room : source.base+496640+1955≤2^64) : Workspace source where
  base := 4*((source.base+496640+3)/4)
  aligned := by omega
  bounded := by dsimp [bytes]; omega
  separate := Or.inr (by omega)

theorem footprint : bytes≤2048 := by decide +kernel

end Inference.Kernels.Sampling.NormalizedArgmaxAllocation
