import kernels.attention.MlxSdpaTwoPassMemory

namespace Inference.Kernels.Attention.MlxSdpaTwoPassQueryGeometry
open Contracts.Mlx State MlxSdpaTwoPassSyntax MlxSdpaTwoPassMemory

-- Native array descriptor attachment remains an explicit contiguous-head premise.
def registers (memory : ByteMemory.Bytes) (base blocks : Nat) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) : SdpaQueryMemory.Registers :=
  fun item => HalfMemory.load memory (base+2*(MlxSdpaVectorSyntax.eval
    (environment 0 blocks head block lane) queryPointer.offset+item.val))

theorem address (blocks : Nat) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaVectorSyntax.eval (environment 0 blocks head block lane) queryPointer.offset+item.val=
      head.val*256+(SdpaScore.index lane item).val := by
  simp only [environment,queryPointer,MlxSdpaVectorSyntax.queryPointer,MlxSdpaVectorSyntax.eval,SdpaScore.index]
  omega

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

theorem native_registers (input : SdpaMemory.Input query cache) (base blocks : Nat)
    (contiguous : ∀ head, (input.query head).base=base+2*(head.val*256))
    (head : Fin 24) (block : Fin blocks) (lane : Fin 32) :
    registers input.cache.memory base blocks head block lane=queryRegisters input head lane := by
  funext item
  unfold registers queryRegisters
  rw [address,contiguous]
  congr 1
  omega

theorem captured (input : SdpaMemory.Input query cache) (base blocks : Nat)
    (contiguous : ∀ head, (input.query head).base=base+2*(head.val*256))
    (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    registers input.cache.memory base blocks head block lane item=
      ArrayStorage.bits (query head (SdpaScore.index lane item)) := by
  rw [native_registers input base blocks contiguous]
  exact query_registers input head lane item

end Inference.Kernels.Attention.MlxSdpaTwoPassQueryGeometry
