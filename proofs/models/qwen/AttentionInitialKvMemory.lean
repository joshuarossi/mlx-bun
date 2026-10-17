import models.qwen.ResidualAttentionMemory
import state.KvInitialPairMemory

-- Direct first-token KV initialization after the actual Q/K normalization
-- and RoPE prefix. The old empty-cache concatenation route is bypassed.
namespace Inference.Models.Qwen.AttentionInitialKvMemory
open Contracts.Mlx State Kernels.Attention
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {cache : Kv.Cache Kv.BF 0}

def fromPrefix (front : ResidualAttentionMemory.Prefix layer original angle) (layout : KvRegions.Layout 1)
    (allocation : KvInitialPairMemory.Allocation layout front.keySource front.valueSource) :
    KvInitialPairMemory.Execution cache (layer.mixer.heads (layer.inputNorm.forward original) angle).key
      (layer.mixer.heads (layer.inputNorm.forward original) angle).value :=
  KvInitialPairMemory.fromSources front.memory layout front.keySource front.valueSource rfl rfl allocation

structure Read (front : ResidualAttentionMemory.Prefix layer original angle) (cache : Kv.Cache Kv.BF 0) where
  layout : KvRegions.Layout 1
  allocation : KvInitialPairMemory.Allocation layout front.keySource front.valueSource
  queries : ∀ head, (fromPrefix (cache:=cache) front layout allocation).Safe (front.query head).base 512
  gates : ∀ head, (fromPrefix (cache:=cache) front layout allocation).Safe (front.gate head).base 512

variable {front : ResidualAttentionMemory.Prefix layer original angle} (read : Read front cache)

def Read.kv := fromPrefix (cache:=cache) front read.layout read.allocation

def Read.query (head : Fin 24) : ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).query head) :=
  read.kv.bufferAfter (front.query head) (front.shared.1 head) (read.queries head)

def Read.gate (head : Fin 24) : ArrayStorage.BFBuffer ((layer.mixer.heads (layer.inputNorm.forward original) angle).gate head) :=
  read.kv.bufferAfter (front.gate head) (front.shared.2.2.1 head) (read.gates head)

def Read.input : SdpaMemory.Input (layer.mixer.heads (layer.inputNorm.forward original) angle).query
    (Kv.append cache (layer.mixer.heads (layer.inputNorm.forward original) angle).key
      (layer.mixer.heads (layer.inputNorm.forward original) angle).value) where
  cache := read.kv.after
  query := read.query
  shared := fun _ => rfl

theorem Read.gates_shared (head : Fin 24) : (read.gate head).bytes=read.input.cache.memory := rfl

theorem Read.query_eq (head : Fin 24) (i : Fin 256) :
    (read.input.query head).read i=(layer.mixer.heads (layer.inputNorm.forward original) angle).query head i :=
  ArrayStorage.BFBuffer.read_correct _ i

theorem Read.gate_eq (head : Fin 24) (i : Fin 256) :
    (read.gate head).read i=(layer.mixer.heads (layer.inputNorm.forward original) angle).gate head i :=
  ArrayStorage.BFBuffer.read_correct _ i

theorem Read.key_read (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load read.input.cache.memory (read.input.cache.layout.keyBase+2*Kv.address 256 head time.val i)=
      KvBytes.bits ((Kv.append cache (layer.mixer.heads (layer.inputNorm.forward original) angle).key
        (layer.mixer.heads (layer.inputNorm.forward original) angle).value).keys head time i) :=
  read.kv.key_read head time i

theorem Read.value_read (head : Fin 4) (time : Fin 1) (i : Fin 256) :
    HalfMemory.load read.input.cache.memory (read.input.cache.layout.valueBase+2*Kv.address 256 head time.val i)=
      KvBytes.bits ((Kv.append cache (layer.mixer.heads (layer.inputNorm.forward original) angle).key
        (layer.mixer.heads (layer.inputNorm.forward original) angle).value).values head time i) :=
  read.kv.value_read head time i

theorem Read.other_region (safe : read.kv.Safe base size) (offset : Nat) (bound : offset<size) :
    read.input.cache.memory (base+offset)=front.memory (base+offset) := read.kv.other_region safe offset bound

def Read.buffer {values : Fin width → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (shared : source.bytes=front.memory) (safe : read.kv.Safe source.base (2*width)) : ArrayStorage.BFBuffer values :=
  read.kv.bufferAfter source shared safe

def Read.parametersAfter (parameters : AttentionParameterMemory.Storage layer.mixer front.memory)
    (safe : AttentionParameterMemory.Protected parameters read.kv.Safe) :
    AttentionParameterMemory.Storage layer.mixer read.input.cache.memory :=
  AttentionParameterMemory.reframe parameters read.input.cache.memory
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => read.other_region region) safe)

end Inference.Models.Qwen.AttentionInitialKvMemory
