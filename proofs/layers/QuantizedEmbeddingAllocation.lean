import layers.QuantizedEmbeddingMemory

namespace Inference.Layers.QuantizedEmbeddingAllocation
open Contracts.Mlx
set_option maxRecDepth 10000

-- Gather the packed row, scales and biases before writing the BF16 row.
-- All four actual global outputs fit one aligned workspace.
def bytes : Nat := 13120

structure Workspace (storage : QuantizedEmbeddingDevice.Storage layer) (tokenBuffer : State.TokenStorage.Buffer token) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes≤2^64
  packedSafe : MemoryRegions.Disjoint base bytes storage.packedBase (4*(248320*640))
  scalesSafe : MemoryRegions.Disjoint base bytes storage.scales.base (2*(248320*80))
  biasesSafe : MemoryRegions.Disjoint base bytes storage.biases.base (2*(248320*80))
  tokenSafe : MemoryRegions.Disjoint base bytes tokenBuffer.base 4

theorem subregion {workspace other size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace bytes other size) (inside : offset+count≤bytes) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {layer : QuantizedEmbedding.Layer} {token : Fin 248320}
  {storage : QuantizedEmbeddingDevice.Storage layer} {tokenBuffer : State.TokenStorage.Buffer token}
  {other size : Nat}

def Workspace.regions (w : Workspace storage tokenBuffer) : QuantizedEmbeddingMemory.Regions :=
  ⟨w.base,w.base+2560,w.base+2720,w.base+2880⟩

theorem Workspace.live (w : Workspace storage tokenBuffer) (safe : MemoryRegions.Disjoint w.base bytes other size) :
    w.regions.Live other size :=
  ⟨by simpa only [Workspace.regions,Nat.add_zero] using subregion (offset := 0) (count := 2560) safe (by decide +kernel),
    subregion safe (by decide +kernel : 2560+160≤bytes),subregion safe (by decide +kernel : 2720+160≤bytes),
    subregion safe (by decide +kernel : 2880+10240≤bytes)⟩

theorem Workspace.allocation (w : Workspace storage tokenBuffer) : QuantizedEmbeddingMemory.Allocation storage tokenBuffer w.regions where
  packedAligned := w.aligned
  scalesAligned := by have := w.aligned; change (w.base+2560)%2=0; omega
  biasesAligned := by have := w.aligned; change (w.base+2720)%2=0; omega
  outputAligned := by have := w.aligned; change (w.base+2880)%2=0; omega
  packedBounded := by have := w.bounded; change w.base+2560≤2^64; dsimp [bytes] at this; omega
  scalesBounded := by have := w.bounded; change w.base+2560+160≤2^64; dsimp [bytes] at this; omega
  biasesBounded := by have := w.bounded; change w.base+2720+160≤2^64; dsimp [bytes] at this; omega
  outputBounded := by have := w.bounded; change w.base+2880+10240≤2^64; dsimp [bytes] at this; omega
  packedLive := w.live w.packedSafe
  scalesLive := w.live w.scalesSafe
  biasesLive := w.live w.biasesSafe
  tokenLive := w.live w.tokenSafe
  scalesPacked := Or.inr (by dsimp [Workspace.regions]; omega)
  biasesPacked := Or.inr (by dsimp [Workspace.regions]; omega)
  biasesScales := Or.inr (by dsimp [Workspace.regions]; omega)
  outputPacked := Or.inr (by dsimp [Workspace.regions]; omega)
  outputScales := Or.inr (by dsimp [Workspace.regions]; omega)
  outputBiases := Or.inr (by dsimp [Workspace.regions]; omega)

def Workspace.execution (w : Workspace storage tokenBuffer) (shared : QuantizedEmbeddingMemory.Shared storage tokenBuffer) :
    QuantizedEmbeddingMemory.Execution layer token :=
  QuantizedEmbeddingMemory.fromStorage storage tokenBuffer shared w.regions w.allocation

theorem Workspace.input_linked (w : Workspace storage tokenBuffer) (shared : QuantizedEmbeddingMemory.Shared storage tokenBuffer) :
    (w.execution shared).tokenBuffer=tokenBuffer := rfl

theorem Workspace.parameters_linked (w : Workspace storage tokenBuffer) (shared : QuantizedEmbeddingMemory.Shared storage tokenBuffer) :
    (w.execution shared).storage=storage := rfl

theorem Workspace.output_base (w : Workspace storage tokenBuffer) (shared : QuantizedEmbeddingMemory.Shared storage tokenBuffer) :
    (w.execution shared).forwardBuffer.base=w.base+2880 := (w.execution shared).forward_base

theorem Workspace.other_region (w : Workspace storage tokenBuffer) (shared : QuantizedEmbeddingMemory.Shared storage tokenBuffer)
    (safe : MemoryRegions.Disjoint w.base bytes other size) (offset : Nat) (bound : offset<size) :
    (w.execution shared).forwardBuffer.bytes (other+offset)=tokenBuffer.bytes (other+offset) :=
  (congrFun (w.execution shared).buffers_shared.1 _).trans ((w.execution shared).other_region (w.live safe) offset bound)

theorem footprint : bytes=2560+160+160+10240 := by decide +kernel

end Inference.Layers.QuantizedEmbeddingAllocation
