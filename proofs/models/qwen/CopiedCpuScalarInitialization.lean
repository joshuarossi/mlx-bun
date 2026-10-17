import models.qwen.CopiedScalarInitialization
import models.qwen.CpuScalarParsedConstruction
namespace Inference.Models.Qwen.CopiedCpuScalarInitialization
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Copy
open ResidualDeltaHighWater (Frontier Before)
open CpuScalarSourceSemantics (Host Backend)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

private theorem scalar_history_raw (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero) :
    HalfMemory.load scalar.bytes scalar.base=0 := by
  have attached := scalar.attached (0 : Fin 1)
  have zero : ArrayStorage.bits (InitialStorage.historyZero 0)=0 := by decide +kernel
  simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] using attached.trans zero

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CopiedScalarInitialization.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor))

-- The producer returns the existing prefix heap. No expected-zero scalar
-- buffer, independent initialization plan or replacement result is supplied.
theorem prefix_heap (backend : Backend) (host : Host) :
    CpuScalarParsedConstruction.executePair (CopiedScalarInitialization.scalarWorkspace frontier room) initialHeap backend host=
      some (CopiedScalarInitialization.memory (initialHeap:=initialHeap) frontier room) :=
  CpuScalarParsedConstruction.exact_heap _ _ backend host

theorem prefix_history_raw : HalfMemory.load (CopiedScalarInitialization.memory (initialHeap:=initialHeap) frontier room) frontier.cursor=0 :=
  CpuScalarParsedConstruction.history_raw (CopiedScalarInitialization.scalarWorkspace frontier room) initialHeap

theorem prefix_recurrent_raw : ByteMemory.load32 (CopiedScalarInitialization.memory (initialHeap:=initialHeap) frontier room) (frontier.cursor+4)=0 :=
  CpuScalarParsedConstruction.recurrent_raw (CopiedScalarInitialization.scalarWorkspace frontier room) initialHeap

theorem initialized_history_raw :
    HalfMemory.load (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes frontier.cursor=0 := by
  let scalar := (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).history
  have raw := scalar_history_raw scalar
  have heap := congrArg (fun memory => HalfMemory.load memory scalar.base)
    (CopiedScalarInitialization.source_heap original token frontier room parameters)
  have address := congrArg (fun base => HalfMemory.load
    (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes base)
    (CopiedScalarInitialization.history_base (p:=p) (initialHeap:=initialHeap) token frontier room)
  exact address.symm.trans (heap.symm.trans raw)

theorem initialized_recurrent_raw :
    ByteMemory.load32 (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes (frontier.cursor+4)=0 :=
  CopiedScalarInitialization.recurrent_zero original token frontier room parameters

-- This source-backed prefix feeds the already parsed history/recurrent
-- initialization kernels on their actual current heap. Native per-call array
-- identity/constant sharing and host ABI/coherence remain explicit boundaries.
structure Certificate (backend : Backend) (host : Host) : Prop where
  producerHeap : CpuScalarParsedConstruction.executePair (CopiedScalarInitialization.scalarWorkspace frontier room) initialHeap backend host=
    some (CopiedScalarInitialization.memory (initialHeap:=initialHeap) frontier room)
  initialized : InitialCacheParsedSourceConstruction.Executes p.graph.stages
    (CopiedScalarInitialization.initializationWorkspace (p:=p) frontier room).caches
    (CopiedScalarInitialization.entrySources (p:=p) (initialHeap:=initialHeap) token frontier room)
    (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room)
  historyHeap : (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).history.bytes=
    (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes
  recurrentHeap : (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).recurrent.bytes=
    (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes
  historyRaw : HalfMemory.load (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes frontier.cursor=0
  recurrentRaw : ByteMemory.load32 (CopiedScalarInitialization.initial original token frontier room parameters).memory.index.bytes (frontier.cursor+4)=0

theorem checked (backend : Backend) (host : Host) : Certificate original token frontier room parameters backend host :=
  ⟨prefix_heap (initialHeap:=initialHeap) frontier room backend host,
    CopiedScalarInitialization.checked (p:=p) (initialHeap:=initialHeap) token frontier room,
    CopiedScalarInitialization.source_heap original token frontier room parameters,
    CopiedScalarInitialization.source_recurrent_heap original token frontier room parameters,
    initialized_history_raw original token frontier room parameters,
    initialized_recurrent_raw original token frontier room parameters⟩

theorem history_read : (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).history.read 0=
    InitialStorage.historyZero 0 := ArrayStorage.BFBuffer.read_correct _ _

theorem recurrent_read : (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).recurrent.read 0=
    InitialStorage.recurrentZero 0 := ArrayStorage.FloatBuffer.read_correct _ _

end Inference.Models.Qwen.CopiedCpuScalarInitialization
